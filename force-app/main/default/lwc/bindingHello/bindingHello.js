// https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.events_handling
// read the part from the above link 
// Listen for Changes to Input Fields

import { LightningElement, track } from 'lwc';

export default class BindingHello extends LightningElement {
    @track myValue = 'omkar';

    handleChange(evt) {
        let currentValue = evt.target.value.replace(/ /g, "");
        this.myValue = currentValue;
        console.log('hi')
        evt.target.value = currentValue
    }
}