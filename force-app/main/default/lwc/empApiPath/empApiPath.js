import { api, LightningElement, track, wire} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

import { publish, MessageContext } from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/shoppingMessageChannel__c';

export default class EmpApiPath extends LightningElement {
    @api recordId;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    order;

    @track myOptions = [
        'Draft','Submitted To Customers','Ordered By Customers','Shipped',
    ]

    handleSelect(event) {
        console.log('selected option = ', event.detail)

        if(event.detail === 'Submitted To Customers') {
            const message = {
                type: 'submitProducts'
            };
            publish(this.messageContext, SAMPLEMC, message);
        }
        
    }

    get status() {
        return getFieldValue(this.order.data, STATUS_FIELD)
    }

}