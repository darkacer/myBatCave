import { LightningElement, wire, api} from 'lwc';
import getContactList from '@salesforce/apex/getAccountDetails.getContactList';
import LEAD_SOURCE from '@salesforce/schema/Contact.LeadSource';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

export default class ChildLWC extends LightningElement {
	@api name;
	data = [];

	get leadSource() {
		return LEAD_SOURCE;
	}
	get contact() {
		return CONTACT_OBJECT;
	}

	columns = [
		{ label: 'Name', fieldName: 'Name',type:'text'},
		{ label: 'Profile Pic', fieldName: 'Picture__c', type:'image'},
		{ label: 'Email', fieldName: 'Email', type:'text' },
		{ label: 'Lead Source', fieldName: 'LeadSource', type:'picklist',
			typeAttributes: {
				picklistObjectApiName:this.contact,
				picklistRecordTypeId:'',
				picklistFeildApiName:this.leadSource,
				picklistSelectedValue:value
			}
		}
	];

	@wire(getContactList) 
	contacts({error, data}){
		if(data) {
			this.data = data;
			console.log("data is", data);
		} else {
			console.log('error', error)
		}
	};
}