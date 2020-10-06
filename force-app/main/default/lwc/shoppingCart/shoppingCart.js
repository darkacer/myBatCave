import { LightningElement, wire, track, api } from 'lwc';
import { MessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import getProuctById from '@salesforce/apex/ShoppingCart.getProuctById';
import SAMPLEMC from "@salesforce/messageChannel/shoppingMessageChannel__c";
import postData from '@salesforce/apex/CalloutHelper.postData'


export default class ShoppingCart extends LightningElement {
    subscription;
    @api recordId

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

    clearCart() {
        this.products = []
    }

    addEventListers() {
        this.template.addEventListener('dragover', this.handleDragOver.bind(this));
        this.template.addEventListener('drop', this.handleDrop.bind(this));   
        this.template.addEventListener('dragleave', this.handleDragLeave.bind(this));   
    }

    disconnectedCallback() {
        releaseMessageContext(this.messageContext);
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleDragLeave(event) {
        this.template.querySelector('.dropcls').className='dropcls';
    }

    handleDrop(event) {
        if(event.stopPropagation){
            event.stopPropagation();
        }
        event.preventDefault();
        this.template.querySelector('.dropcls').className='dropcls';
        this.getProductDetials();
    }

    handleDragOver(event){
        event.dataTransfer.dropEffect = 'move';
        event.preventDefault();
        this.template.querySelector('.dropcls').className='dropcls over';
    }  

    handleMessage(message) {
        console.log('message is ', )
        this.receivedMessage = message ? JSON.stringify(message, null, '\t') : 'no message payload';
        if (JSON.parse(this.receivedMessage)['type'] === 'addNewProduct')
            this.rxId = JSON.parse(this.receivedMessage)['recordId'];
        else if (JSON.parse(this.receivedMessage)['type'] === 'submitProducts') {
            this.makeCallout()
        }
    }

    makeCallout() {
        console.log('inside make callout')
        let body = {
            data: {
                orderId: this.recordId,
                cartdata: this.products
            }
        }
        postData({
            url: 'https://acme-api-app.herokuapp.com/setCartData/',
            body: JSON.stringify(body)
        })
        .then((response) => {
            console.log('response is ', response)
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }


    get cartTotal() {
        return this.products.length ? this.products.reduce((a, e) => a + e.price * e.quantity, 0) : 0
    }

    getProductDetials() {
        let found = false;
        getProuctById({Id: this.rxId})
        .then(result => {
            if(result.PricebookEntries.length) {
                for(let i = 0; i < this.products.length; i++) {
                    if (this.products[i].Id === result.Id) {
                        this.products[i].quantity += 10
                        found = true;
                        break;
                    }
                }

                if(!found) {
                    this.products.push(
                        Object.assign(
                            {}, 
                            result, 
                            {quantity: 10}, 
                            {price: result.PricebookEntries[0].UnitPrice}
                        )
                    );
                }
            }
        })
    }

    calcCart(event) {
        let id = event.currentTarget.dataset.id;
        let quant = (event.target.value != null) ? event.target.value : 0;
        this.products.forEach(el => {
            if(el.Id === id) el.quantity = quant;
        })
    }
}