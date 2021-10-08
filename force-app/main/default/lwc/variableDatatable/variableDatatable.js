import { LightningElement, api, track } from 'lwc';
import fetchData from '@salesforce/apex/getAccountDetails.getData';

export default class VariableDatatable extends LightningElement {
    @api custData = [];
    @api columnApiName = 'id,name';
    @api columnLabel = 'Id,Name';
    @api sObjectName = 'Account'
    @api fullData;

    get showData() {
        return this.fullData != null && this.fullData.length > 1
    }

    @track columns_show = [
        { label: 'Label', fieldName: 'name' },
        { label: 'Website', fieldName: 'website', type: 'url' },
        { label: 'Phone', fieldName: 'phone', type: 'phone' },
        { label: 'Balance', fieldName: 'amount', type: 'currency' },
        { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
    ];
    connectedCallback() {
        this.buildColumn();
        this.fetchData();
    }

    buildColumn() {
        console.log('inside build col ', this.columnApiName, this.columnLabel);
        this.columns_show = this.columnApiName.split(',').map(
            (el, index) => {
                return {
                    label: this.columnLabel.split(',')[index],
                    fieldName: el
                }
            }
        )
        console.log(JSON.stringify(this.columns_show));
        console.log(JSON.stringify(this.fullData));
    }

    fetchData() {

        // this.columns = ['id','name'];
        // let tempColumns = ;
        fetchData({columns: this.columnApiName.split(','), sObjectName: this.sObjectName})
        .then(data => {
            console.log('data is ', JSON.stringify(data));
            this.fullData = data;
        })
        .catch(error => {
            console.log('error is ', error);
        })
    }
    
}