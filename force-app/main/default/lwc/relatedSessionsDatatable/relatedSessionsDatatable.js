import { api, LightningElement, track } from 'lwc';
import getSessionTimes from '@salesforce/apex/DurationTracker.getSessionTimes';

export function calculateString (duration) {
    let hours = Math.floor(duration / 3600);
    let minutes = Math.floor((duration % 3600) / 60)
    let seconds = Math.floor((duration % 3600) % 60)

    return ("0" + hours).slice(-2) + ":" 
        + ("0" + minutes).slice(-2) + ":"
        + ("0" + seconds).slice(-2);
}

const columns = [
    { label: 'NAME', fieldName: 'Name' },
    { label: 'USERNAME', fieldName: 'AgentName' },
    { label: 'DURATION', fieldName: 'CaseTimer19__Duration__c' }
];

export default class RelatedSessionsDatatable extends LightningElement {
    @track data = [];
    @api recordId;
    columns = columns

    connectedCallback() {
        this.getSessionTimes()
    }

    getSessionTimes() {
        getSessionTimes({caseId: this.recordId})
        .then(result => {
            this.data = result.map(element => {
                element.CaseTimer19__Duration__c = calculateString(element.CaseTimer19__Duration__c)
                element.AgentName = element['CaseTimer19__Agent__r']['Name']
                return element
            });
        })
        .catch(error => {
            console.log('this is error while fetching session times', error);
        })
    }

    // @api
    // calculateString(duration)  {
    //     let hours = Math.floor(duration / 3600);
    //     let minutes = Math.floor((duration % 3600) / 60)
    //     let seconds = Math.floor((duration % 3600) % 60)

    //     return ("0" + hours).slice(-2) + ":" 
    //         + ("0" + minutes).slice(-2) + ":"
    //         + ("0" + seconds).slice(-2);
    // }
}