import { LightningElement, track } from 'lwc';

export default class PBCollabEdit extends LightningElement {
    codeData = 'this code is from pBCollabEdit';
    @track numberOfLines = [1];
    keyPressed(event) {
        // const lineNumbers = this.template.querySelector('.line-numbers')
        // console.log('event target ', event.target.value);
        const numberOfLines = event.target.value.split("\n").length
        // console.log('numberOfLines', numberOfLines)
        this.numberOfLines = Array(numberOfLines).fill(1);
        this.codeData = event.target.value;
        setTimeout(() => {
            this.sendtoApex()
        }, 500);
    }

    // saveToDB() {
        
    //}

    sendtoApex() {
        console.log('sending to apex')
    }
}