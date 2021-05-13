import { LightningElement } from 'lwc';
import setDuration from '@salesforce/apex/DurationTracker.setDuration';

export default class DurationTracker extends LightningElement {
    connectedCallback(){
        setDuration({context: 'connected callback'})
        .then(result => {
            console.log('connected call was success' + result);
        })

        this.template.addEventListener('onunload', function() {
            console.log('indide ');
            setDuration({context: 'unload callback'})
            .then(result => {
                console.log('connected call was success' + result);
            })
        })
    }

    disconnectedCallback() {
        setDuration({context: 'disconnected callback'})
        .then(result => {
            console.log('disconnected call was success');
        })
    }
}