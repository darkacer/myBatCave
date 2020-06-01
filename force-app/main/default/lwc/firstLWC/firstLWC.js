import { LightningElement, track } from 'lwc';
export default class FirstLWC extends LightningElement {
	
	@track myarray = ['ennie', 'minnie', 'mani', 'mow'];
    @track parentCounter = 0;
    @track test = 'placeholer';
    @track parentname;
    childCounter = 0;
    doIncrement() {
        this.parentCounter = this.parentCounter + 1;
    }
    doDecrement() {
        this.parentCounter = this.parentCounter - 1;
    }
    updateProperty(event) {
        this.test = event.target.value;
    }
    updateParentName(event) {
        this.parentname = event.detail;
    }

}