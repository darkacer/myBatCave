import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Child__c.Mother__c'];
const FIELDS2 = ['Mother__c.L3DB_Total_Case__c'];
/*eslint no-console: */ 
export default class Wireapi extends LightningElement {
    @api recordId;
    @track mid;
    @track error;
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS}) 
    motherdata({error, data}) {
        if(data) {            
            console.log(data);
            this.mid = data.Mother__c;
        } else if(error) {
            this.error = error;
        }
    }

    @wire(getRecord, {recordId: '$mid', fields: FIELDS2})
    l3dbId;
    get hasL3() {
        console.log(this.l3dbId + '@@');
        return this.l3dbId && this.l3dbId.data;
    }
}