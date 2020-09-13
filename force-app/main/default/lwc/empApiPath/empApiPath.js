import { LightningElement, track} from 'lwc';

export default class EmpApiPath extends LightningElement {
    @track myOptions = [
        'option1','option2','option3','option4',
    ]
    @track defaultOption = 'option3'
    handleSelect(event) {
        console.log('selected option = ', event.detail)
    }
}