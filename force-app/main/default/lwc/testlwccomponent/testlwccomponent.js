/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  fetchAccounts  from '@salesforce/apex/getAccountDetails.getAccountsKey';

export default class Testlwccomponent extends LightningElement {
    @track myname = '';
    @track accname = 'new';
    @api prop1;
    @api prop2;
    @api Accounts;
    changeHappend(event) {
        this.myname = event.target.value;
        console.log(this.prop2);
    }
    handleButton() {
        console.log('hihih');
        const title = this.template.querySelector('.title').value;
        const message = this.template.querySelector('.message').value;
        const variant = this.template.querySelector('.variant').value;
        const evt = new ShowToastEvent({
            title:  title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

//    @wire (fetchAccounts) getAcc(error, data){
//         if (data) {
//             console.log('im hgere');
//             this.Accounts = data;
//         }
//         else if(error) {
//             console.log(error);
//         }
//    }
    callApex() {
        let inp = this.template.querySelector('.input1').value;
        fetchAccounts({key : inp})
            .then(result => {
                this.Accounts = result;
                console.table(result);
            })
            .catch(error => {
                console.log(error);
                console.log('hihihihihi');
            })
    } 
}