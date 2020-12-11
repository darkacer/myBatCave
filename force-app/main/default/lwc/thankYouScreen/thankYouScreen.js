import { LightningElement } from 'lwc';
import AstroGif from '@salesforce/resourceUrl/SalesforceGifs';

export default class ThankYouScreen extends LightningElement {
    astroGif = AstroGif + this.gifName
    connectedCallback() {
        
        console.log('hi hi hi')
    }

    get gifName() {
        return (new Date().getDate() >= 25 && new Date().getMonth() === 11) ? '/gifs/xmasAstro.gif' : '/gifs/astroHands.gif';
    }
}