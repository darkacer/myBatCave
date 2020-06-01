import { LightningElement, api, track } from 'lwc';

export default class Childcomponent extends LightningElement {
    @api name;
    @track name;
    @track childCounter;
    @track parentName = 'default value';
    myvar;
    updateme (event) {
        this.name = event.target.value;
    }
    doIncrement() {
        this.dispatchEvent(new CustomEvent('increment'));
    }
    doDecrement() {
        this.dispatchEvent(new CustomEvent('decrement'));
    }
    updateParentName(event) {
        this.parentName = event.target.value;
        
        // eslint-disable-next-line
        this.myvar = setTimeout(
            function() {
                // eslint-disable-next-line no-console
                console.log('yo!!!!');
            }, 1000
        );
        this.dispatchEvent(new CustomEvent('namechange', {detail : this.parentName}));
    }
}