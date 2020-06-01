import { LightningElement, wire, track} from 'lwc';
import getContactsList from '@salesforce/apex/LWCController.getContactList';

const DELAY = 300;

export default class ShowContacts extends LightningElement {
    myvar;
    @track mynumber = 0;
    @wire(getContactsList, {count:'$mynumber'}) myList;
    updatedValue (event) {
        const mynumber = event.target.value;
        if (mynumber > 0) {
        //    window.clearTimeout(this.myvar);
            //eslint-disable-next-line
            this.myvar = setTimeout(
                () => {
                    this.mynumber = mynumber;
                }, 
                DELAY
            );
        }
    }
}