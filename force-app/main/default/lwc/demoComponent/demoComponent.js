import { LightningElement, track } from 'lwc';

export default class DemoComponent extends LightningElement {
    @track name;
    updates (event) {
        this.name = event.target.value;
    }
}