import { LightningElement, api, track } from 'lwc';

const isEqual = (str1, str2) => { return (str1.localeCompare(str2)) === 0}

export default class Basepath extends LightningElement {
    @api givenOptions = [
        'New', 'Qualified', 'Open', 'Closed'
    ]
    @api selectedOption = 'Qualified'
    @track listOptions = [];

    connectedCallback() {
        let count = 0
        let isequal = false;
        let foundActive = false;
        let myclass;
        this.givenOptions.forEach(el => {
            myclass = 'slds-path__item';
            isequal = isEqual(el, this.selectedOption)
            myclass += (isequal) ? ' slds-is-current slds-is-active' : 
                        (foundActive) ? ' slds-is-incomplete': ' slds-is-complete'

            // myclass += (foundActive) ? ' slds-is-incomplete' : ''
            // myclass += (!isequal && !foundActive) ? 'slds-is-complete' : ''
            this.listOptions.push(Object.assign(
                {},
                {id: count++}, 
                {value: el}, 
                {selected: isequal},
                {class: myclass}
            ))
            if (isequal) foundActive = true
        })

        console.log('this.listOptions ', JSON.stringify(this.listOptions))
    }

    handleSelect(event) {
        let id = event.currentTarget.dataset.id
        console.log('id is', id)
        this.listOptions.forEach(el => {
            console.log('checking for ', el.id)
            if (el.selected) {
                el.class = 'slds-path__item slds-is-current'
                el.selected = false
            }
            if(el.id == id) {
                el.class = 'slds-path__item slds-is-active'
                el.selected = true
                this.selectedOption = el.value
            } else if( el.id < id) {
                el.selected = false
                el.class = 'slds-path__item slds-is-complete'
            } else {
                el.selected = false
                el.class = 'slds-path__item slds-is-incomplete'
            }
        })
        console.log('after update ', JSON.stringify(this.listOptions))

    }

    handleUpdate() {
        this.dispatchEvent(new CustomEvent('select'),{
            detail: this.selectedOption
        });
    }
}