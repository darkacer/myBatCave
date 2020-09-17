import { LightningElement, wire, track } from 'lwc';
import { MessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import getProuctById from '@salesforce/apex/ShoppingCart.getProuctById';

import SAMPLEMC from "@salesforce/messageChannel/shoppingMessageChannel__c";


export default class ShoppingCart extends LightningElement {
    subscription;

    @wire(MessageContext)
    messageContext;

    receivedMessage;
    @track products = [];

    rxId;

    connectedCallback() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, SAMPLEMC, (message) => {
            this.handleMessage(message);
        });

        this.addEventListers()
    }

    addEventListers() {
        this.template.addEventListener('dragover', this.handleDragOver.bind(this));
        this.template.addEventListener('drop', this.handleDrop.bind(this));   
    }

    disconnectedCallback() {
        releaseMessageContext(this.messageContext);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleDrop(event) {
        console.log('inside handle drop');
        if(event.stopPropagation){
            event.stopPropagation();
        }
        event.preventDefault();

        this.getProductDetials();
    }

    handleDragOver(event){
        console.log('inside dragover')
        event.dataTransfer.dropEffect = 'move';
        event.preventDefault();       
    }  

    handleMessage(message) {
        this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
        console.log('rx msg ', this.receivedMessage)
        this.rxId = JSON.parse(this.receivedMessage)['recordId'];
    }

get cartTotal() {
    if (this.products.length){
        let ret = 0;
        this.products.forEach(el => {
            ret += parseInt(el.price) * parseInt(el.quantity)
        })
        return ret
    }
    else return 0
}

    getProductDetials() {
        console.log('rxid is ', this.rxId)
        getProuctById({Id: this.rxId})
        .then(result => {
            console.log('data recieved is ', result)
            if(result.PricebookEntries.length)
                this.products.push(
                    Object.assign(
                        {}, 
                        result, 
                        {quantity: 10}, 
                        {price: result.PricebookEntries[0].UnitPrice}
                    )
                );
            console.log('proucts =>', this.products)
        })
    }
}