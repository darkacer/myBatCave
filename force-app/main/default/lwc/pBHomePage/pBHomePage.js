import { LightningElement, api } from 'lwc';
const myConstant = ['cp', 'api', 'ce'];
const myAdder = (a, b) => a + b;

export default class PBHomePage extends LightningElement {
    defaultActiveTab;
    @api navigationList = [
        {id:0,label:'Copy - Paste', name:'cp'}, 
        {id:1,label:'All stuff API', name:'api'}, 
        {id:2,label:'Collabedit', name:'ce'}, 
    ]

    

    connectedCallback() {
        console.log('connectedCallback');
        this.defaultActiveTab = 'cp'

        // myConstant.push('wildcard');
    }
}
export { myConstant, myAdder }