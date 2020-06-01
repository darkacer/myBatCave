import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ChildDisplay extends NavigationMixin(LightningElement) {
    @api myChildList;
    @api sObjectType;

    handleContactView(event) {
        // Navigate to contact record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: this.sObjectType,
                actionName: 'edit',
            },
        });
    }
}