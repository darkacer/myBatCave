import { LightningElement, wire, api} from 'lwc';
import getContactList from '@salesforce/apex/getAccountDetails.getContactList';

export default class ChildLWC extends LightningElement {
	@api name;
	data = [];
	columns = [
		{ label: 'Name', fieldName: 'Name',type:'text'},
		{ label: 'Profile Pic', fieldName: 'Picture__c', type:'image'},
		{ label: 'Email', fieldName: 'Email', type:'text' }
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