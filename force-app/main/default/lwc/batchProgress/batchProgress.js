import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import startBatch from '@salesforce/apex/BatchProgressController.startBatch';

export default class BatchProgress extends LightningElement {

    channelName = '/event/Batch_Progress__e';
    @track recordsProcessed = 0;
    totalRecords = 100;
    subscription = {};
    
    get processedPercent() {
        return this.recordsProcessed / this.totalRecords * 100
    }

    connectedCallback() {
        this.handleSubscribe();    
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            // Response contains the payload of the new message received
            this.updateRecordValue(response.data.payload.Count__c);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
            // this.toggleSubscribeButton(true);
        });
    }

    updateRecordValue(count) {
        this.recordsProcessed = count;
    }

    handleUnsubscribe() {
        // this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    startBatch() {
        startBatch({})
        .then((result) => {
            console.log('batch job started = ');
            console.log(JSON.stringify(result));
        })
    }
}