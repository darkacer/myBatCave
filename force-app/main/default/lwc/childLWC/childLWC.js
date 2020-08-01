import { LightningElement, wire, api, track} from 'lwc';
import getContactList from '@salesforce/apex/getAccountDetails.getContactList';
import LEAD_SOURCE from '@salesforce/schema/Contact.LeadSource';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

const DEPENDEE = 'country'
const DEPENDENT = 'state'

export default class ChildLWC extends LightningElement {
	@api name;
	data = [];

	objValuePair(obj) {
		return obj.map(el => Object.assign({ value: el, label: el }))
	}

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
		{ label: 'My Country', fieldName: DEPENDEE, type: 'normalpicklist',
			typeAttributes: {
				picklistOptions: this.objValuePair(Object.keys(data_picklist)),
				value: {fieldName: DEPENDEE},
				index: {fieldName: 'index'},
				fieldApiName: DEPENDEE
			}
		},
		{ label: 'My State', fieldName: DEPENDENT, type: 'normalpicklist',
			typeAttributes: {
				picklistOptions: {fieldName: 'dependentValues'},
				value: {fieldName: DEPENDENT},
				index: {fieldName: 'index'},
				fieldApiName: DEPENDENT
			}
		},
	];

	@wire(getContactList) 
	contacts({error, data}) {
		if(data) {
			let count = 0
			this.data = data.map((item) => {
					if (count % 2)
					return Object.assign({}, item, {country: 'USA'}, {index: count++}, {state: data_picklist['USA'][0]})
					else 
					return Object.assign({}, item, {country: 'IND'}, {index: count++}, {state: data_picklist['IND'][0]})
				}
			)

			this.data = this.data.map( item => {
				return Object.assign(item, {dependentValues: this.objValuePair(data_picklist[item[DEPENDEE]])})
			})
		} else {
			console.log('error', error)
		}
	};
 
	pickliListChanged(event) {
		event.stopPropagation();
		if (event.detail.fieldApiname === DEPENDEE) {
			this.data[event.detail.index].DEPENDEE = event.detail.value
			this.data[event.detail.index].dependentValues = this.objValuePair(data_picklist[event.detail.value])
			this.data[event.detail.index].DEPENDENT = data_picklist[event.detail.value][0]
		} else {
			this.data[event.detail.index].DEPENDENT = event.detail.value
		}
		this.data = [...this.data]
	}
}

const data_picklist = {
	'IND': ['MAH','PUN','GUJ','DEL','KAR'],
	'USA': ['NYC','WAH','MIN','VIR']
}