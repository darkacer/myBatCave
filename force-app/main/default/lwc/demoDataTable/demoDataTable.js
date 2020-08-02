import { LightningElement, track } from 'lwc';
import { generateObjValPair, addDependentValues } from 'c/advancedDataTable'

const countryToState = {
    'c1': ['s11','s12','s13','s14'],
    'c2': ['s21','s22','s23','s24'],
}

const DEPENDEE = 'country'
const DEPENDENT = 'state'

export default class DemoDataTable extends LightningElement {
    @track data = [
        {id: 1, userName: 'user1', country: 'c1', state: 's11'},
        {id: 2, userName: 'user2', country: 'c1', state: 's12'},
        {id: 3, userName: 'user3', country: 'c1', state: 's13'},
        {id: 4, userName: 'user4', country: 'c2', state: 's21'},
        {id: 5, userName: 'user5', country: 'c2', state: 's22'},
        {id: 6, userName: 'user6', country: 'c2', state: 's21'},
        {id: 7, userName: 'user7', country: 'c2', state: 's24'},
        {id: 8, userName: 'user8', country: 'c2', state: 's23'},
        {id: 9, userName: 'user9', country: 'c2', state: 's23'},
        {id: 10, userName: 'user10', country: 'c2', state: 's23'},
    ]

    columns = [
		{ label: 'Name', fieldName: 'userName',type:'text'},
		{ label: 'My Country', fieldName: DEPENDEE, type: 'normalpicklist',
			typeAttributes: {
				picklistOptions: generateObjValPair(Object.keys(countryToState)),
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
    
    connectedCallback() {
        this.data = addDependentValues(this.data, countryToState, DEPENDEE)
    }

    pickliListChanged(event) {
        event.stopPropagation();
		if (event.detail.fieldApiname === DEPENDEE) {
			this.data[event.detail.index].DEPENDEE = event.detail.value
			this.data[event.detail.index].dependentValues = generateObjValPair(countryToState[event.detail.value])
			this.data[event.detail.index].DEPENDENT = countryToState[event.detail.value][0]
		} else {
			this.data[event.detail.index].DEPENDENT = event.detail.value
		}
		this.data = [...this.data]
	}
}