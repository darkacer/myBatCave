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
            if (this.recordTypeId === '') this.recTypeId = data.defaultRecordTypeId;
        }
    };

    @wire(getPicklistValues, { recordTypeId: '$recTypeId', fieldApiName: '$fieldApiName' })
    pickVals({error, data}) {
        if (data) {
            this.options = data.values.map(el => {
                return {
                    isSelected: (this.selectedValue === el.label),
                    value: el.label
                }
            })
        }
    };

    connectedCallback() {
        this.recTypeId = this.recordTypeId;
        console.log('im isncde picklist controller', this.selectedValue)
    }
    
}