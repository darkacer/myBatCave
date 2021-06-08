import { LightningElement, track } from 'lwc';
import setDuration from '@salesforce/apex/DurationTracker.setDuration';

export default class CountDownTimer extends LightningElement {
    
    @track timeVal = '00:00:00';
    timeIntervalInstance;
    totalSeconds = 0;

    connectedCallback() {
        var parentThis = this;

            // Run timer code in every 100 milliseconds
            this.timeIntervalInstance = setInterval(function() {

                // Time calculations for hours, minutes, seconds and milliseconds
                var hours = ("0" + Math.floor((parentThis.totalSeconds % (1000 * 60 * 60 * 24)) / (60 * 60))).slice(-2);
                var minutes = ("0" + Math.floor((parentThis.totalSeconds % (1000 * 60 * 60)) / (60))).slice(-2);
                var seconds = ("0" + Math.floor((parentThis.totalSeconds % (1000 * 60)))).slice(-2);
                
                // Output the result in the timeVal variable
                parentThis.timeVal = hours + ":" + minutes + ":" + seconds;   
                
                parentThis.totalSeconds += 1;
            }, 1000);
    }
    disconnectedCallback() {
        setDuration({context: 'disconnected callback from child timer componnet'})
        .then(result => {
            console.log('disconnected call was success');
        })
    }

    renderedCallback() {
        setInterval(this.checkPageFocus, 1000);
    }

    checkPageFocus() {
        // console.log('this.templae', this, this.template);
        let element = this.document.querySelector('.center');
        if(this.document.hasFocus()) {
            console.log('inside has focus');
            // element.classList.remove("red");
            // element.classList.add("green");
        } else {
            console.log('inside does not have focus');
            // element.classList.remove("green");
            // element.classList.add("red");
        }
    }

}