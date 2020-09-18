import { api, LightningElement, track, wire} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Order.Status';

export default class EmpApiPath extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    order;

    @track myOptions = [
        'Draft','Submitted To Customers','Ordered By Customers','Shipped',
    ]

    handleSelect(event) {
        console.log('selected option = ', event.detail)
    }

    get status() {
        return getFieldValue(this.order.data, STATUS_FIELD)
    }

}