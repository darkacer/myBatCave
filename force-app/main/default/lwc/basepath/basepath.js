import { LightningElement, api, track } from 'lwc';
import confetti from 'c/confetti';

const isEqual = (str1, str2) => { return (str1.localeCompare(str2)) === 0}

export default class Basepath extends LightningElement {
    @api givenOptions = [
        'New', 'Qualified', 'Open', 'Closed'
    ]
    @api selectedOption = 'Qualified'
    @track listOptions = [];

    connectedCallback() {
        this.makeClassList(this.selectedOption, false)
        confetti.loadConfetti(this);
    }

    @api
    makeClassList(val, makeConfetti) {
        console.log('indide makeclasslis', val)
        this.selectedOption = val
        this.listOptions = []
        let count = 0
        let isequal = false;
        let foundActive = false;
        let myclass;
        this.givenOptions.forEach(el => {
            myclass = 'slds-path__item';
            isequal = isEqual(el, val)
            myclass += (isequal) ? ' slds-is-current slds-is-active' : 
                        (foundActive) ? ' slds-is-incomplete': ' slds-is-complete'
            this.listOptions.push(Object.assign(
                {},
                {id: count++}, 
                {value: el}, 
                {selected: isequal},
                {class: myclass}
            ))
            if (isequal) foundActive = true
        })
        if(makeConfetti) this.makeConfetti()
    }
    handleSelect(event) {
        let id = event.currentTarget.dataset.id
        this.listOptions.forEach(el => {
            if (el.selected) {
                el.class = 'slds-path__item slds-is-current'
                el.selected = false
            } else {
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
            }
        })
    }

    handleUpdate() {
        this.makeClassList(this.selectedOption, true);
        this.dispatchEvent(new CustomEvent('select',{
            detail: this.selectedOption
        }));
        
        // confetti.loadConfetti(this);
       // this.makeConfetti()
    }

    makeConfetti() {
        switch (this.selectedOption) {
            case 'Draft':
                confetti.fireworks()
                break;
            case 'Submitted To Customers':
                confetti.confettiShower()
                break;
            case 'Ordered By Customers':
                confetti.winnerCelebration()
                break;
            case 'Shipped':
                confetti.busrtMode()
                break;
        
            default:
                break;
        }
    }
}