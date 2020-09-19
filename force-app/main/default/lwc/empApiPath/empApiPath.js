import { api, LightningElement, track, wire} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

import { publish, MessageContext } from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/shoppingMessageChannel__c';

export default class EmpApiPath extends LightningElement {
    @api recordId;

    @track defaultValue
    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    order;

    @track myOptions = [
        'Draft','Submitted To Customers','Ordered By Customers','Shipped',
    ]

    channelName = '/data/OrderChangeEvent';

    handleSelect(event) {
        console.log('selected option = ', event.detail)

        if(event.detail === 'Submitted To Customers') {
            const message = {
                type: 'submitProducts'
            };
            publish(this.messageContext, SAMPLEMC, message);
        }
        
    }

    // set status(val) {
    //     this.defaultValue = val
    //     console.log('im inside set', val)
    // }

    get status() {
        console.log('this.defaultValue', this.defaultValue)
        this.defaultValue = getFieldValue(this.order.data, STATUS_FIELD)
        
        console.log('this.defaultValue2', this.defaultValue)
        // this.refreshChild(this.defaultValue)
        return this.defaultValue
    }

    connectedCallback() {
        this.handleSubscribe()
    }

    disconnectedCallback() {
        this.handleUnsubscribe()
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    refreshChild(val) {
        if (this.template.querySelectorAll('c-basepath')[0])
            this.template.querySelectorAll('c-basepath')[0].makeClassList(val, true)
        this.defaultValue = val
    }

    handleSubscribe() {
        const messageCallback = function(response) {
            console.log('New message received: ', JSON.stringify(response));
            if (response.data.payload.ChangeEventHeader.changedFields.includes('Status')) {
                console.log('before ')
                this.defaultValue = response.data.payload['Status']
                this.refreshChild(this.defaultValue)
            }
        }.bind(this);

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
}