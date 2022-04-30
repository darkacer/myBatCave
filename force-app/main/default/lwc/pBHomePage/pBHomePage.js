import { LightningElement, api } from 'lwc';
import sendMessage from '@salesforce/apex/PushBulletController.sendToTelegram';
const myConstant = ['cp', 'api', 'ce'];
const myAdder = (a, b) => a + b;

export default class PBHomePage extends LightningElement {
    defaultActiveTab;
    @api navigationList = [
        {id:0,label:'Copy - Paste', name:'cp'}, 
        {id:1,label:'All stuff API', name:'api'}, 
        {id:2,label:'Collabedit', name:'ce'}, 
    ]
    textosend = '';
    
    handleInputChange(event) {
        this.textosend = event.detail.value;
    }

    handleClick() {
        console.log('handleClick', this.textosend);
        sendMessage({ text: this.textosend })
        .then((result) => {
            console.log(result);
        })
        .catch((error) => {
            console.log(error);
        });
    }

    connectedCallback() {
        console.log('connectedCallback');
        this.defaultActiveTab = 'cp'

        // myConstant.push('wildcard');
    }
}