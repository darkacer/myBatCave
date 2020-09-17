import { LightningElement, track} from 'lwc';

export default class EmpApiPath extends LightningElement {
    @track myOptions = [
        'Draft','Submitted To Customers','Ordered By Customers','Shipped',
    ]
    @track defaultOption = 'option3'
    handleSelect(event) {
        console.log('selected option = ', event.detail)
    }
}