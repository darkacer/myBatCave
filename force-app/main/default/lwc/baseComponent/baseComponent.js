/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';
import  fetchAccounts  from '@salesforce/apex/getAccountDetails.getAccountsdate';
import  fetchOpportunities  from '@salesforce/apex/getAccountDetails.getOpportinitysdate';
export default class BaseComponent extends LightningElement {
    @api myList;
    @api objectType;
    handleClick(event) {
        let sdate = this.template.querySelector('.sdate').value;
        let edate = this.template.querySelector('.edate').value;
        let type = event.target.value;
        console.log('hoihih' +sdate);
        console.log(event.target.value);

        if(type === 'Account') {
            this.objectType = type;
            fetchAccounts({start : sdate, enddate: edate})
            .then(result => {
            this.myList = result;
            console.table(result);
        })
        } else if(type === 'Opportunity') {
            this.objectType = type;
            fetchOpportunities({start : sdate, enddate: edate})
            .then(result => {
                this.myList = result;
            })
        }
    }
}