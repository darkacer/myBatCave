import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class CustomPickList extends LightningElement {
    @track
    options;
    @api 
    fieldApiName;
    @api 
    recordTypeId;
    @api
    objectApi;
    @api
    selectedValue;

    recTypeId;

    @wire(getObjectInfo, { objectApiName: '$objectApi' })
    objectInfo({error, data}) {
        if (data) {
            console.log('object data is ', data)
            if (this.recordTypeId === '') this.recTypeId = data.defaultRecordTypeId;
        }
    };

    @wire(getPicklistValues, { recordTypeId: '$recTypeId', fieldApiName: '$fieldApiName' })
    pickVals({error, data}) {
        if (data) {
            this.options = data.values.map(el => {
                let retObj = {
                    value: el.label, isSelected: false
                }
                if (this.selectedValue === el.label) {
                    retObj.isSelected = true;
                }
                return retObj
            })
        }
    };

    connectedCallback() {
        this.recTypeId = this.recordTypeId;
    }
    
}