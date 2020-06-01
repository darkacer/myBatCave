import { LightningElement, track } from 'lwc';

export default class HelloWorld extends LightningElement {
    @track greeting = 'hello world';

    myChangeHandler (event) {
        this.greeting = event.target.value;
    }
}