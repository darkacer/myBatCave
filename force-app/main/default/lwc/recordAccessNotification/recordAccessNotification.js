import { api, LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import init from '@salesforce/apex/RecordAccessNotify.init';
import attendance from '@salesforce/apex/RecordAccessNotify.attendance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class RecordAccessNotification extends LightningElement {
    @api recordId;
    channelName = '/event/Record_accessed__e';
    subscription = {};
    componentId = ''
    numberOfOtherComponents = 0

    connectedCallback() {
        this.componentId = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)

        console.log(this.componentId);
        this.registerErrorListener();
        this.handleSubscribe()
        this.initCall(true)

        window.onbeforeunload = this.confirmExit()
    }

    confirmExit() {
        return "You have attempted to leave this page. Are you sure?";
    }

    disconnectedCallback() {
        this.initCall(false)
        this.handleUnsubscribe()
    }

    async initCall(recordOpened) {
        let result = await init({recordId: this.recordId, componentId: this.componentId, recordOpened: recordOpened})
        console.log('result = ', result);
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = function(response) {
            console.log('New message received:######### ', JSON.stringify(response));

            // Response contains the payload of the new message received
            console.log(response.data.payload !== undefined , response.data.payload.Record_Id__c , thisReference.recordId);
            
            thisReference.processResponse(response, thisReference)
            
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    processResponse(response, thisReference) {
        if(response.data.payload !== undefined && response.data.payload.Record_Id__c === thisReference.recordId) {
            console.log('response payload is present');
            if(
                response.data.payload.Reply_back__c 
            ) {
                console.log('inside replyback true');
                if(response.data.payload.Record_Opened__c) {
                    console.log('inside rec opened');
                    attendance({recordId: thisReference.recordId, componentId: thisReference.componentId})
                    .then(result => console.log('result', result))
                    .catch(error => console.log('error', error))
                }
                else {
                    thisReference.numberOfOtherComponents += -1
                    thisReference.showToast()
                }
            } else {
                console.log('inside replyback false');
                if(response.data.payload.UUID__c === thisReference.componentId) {

                } else {
                    thisReference.numberOfOtherComponents += 1
                    thisReference.showToast()
                }
            }
        }
    }

    // async registerAttendance() {
    //     await attendance({recordId: this.recordId, componentId: this.componentId})
    // }

    showToast() {
        // this.numberOfOtherComponents += newNumberOfHosts
        const event = new ShowToastEvent({
            title: 'Number of other instances ' + this.numberOfOtherComponents,
            message: '',
        });
        this.dispatchEvent(event);
    }
}