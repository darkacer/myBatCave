import { LightningElement, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ShoppingCart.getProducts';
import { publish, MessageContext } from 'lightning/messageService';
import SAMPLEMC from '@salesforce/messageChannel/shoppingMessageChannel__c';



export default class ShoppingList extends LightningElement {
    
    @track products;
    @track error
    
    @wire(MessageContext)
    messageContext;

    @wire(getProducts)
    wiredContacts({ error, data }) {
        console.log('error', error, data)
        if (data) {
            this.products = data;
            this.error = undefined;
            console.log('data is ', data)
        } else if (error) {
            this.error = error;
            this.products = undefined;
        }
    }

    handleDragStart(event) {
        event.dataTransfer.dropEffect = 'copy'

        let productId = event.target.dataset.id

        const message = {
            recordId: productId
        };
        publish(this.messageContext, SAMPLEMC, message);
    }
}