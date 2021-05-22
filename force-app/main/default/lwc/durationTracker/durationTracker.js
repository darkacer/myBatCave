import { api, LightningElement } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import insertSession from '@salesforce/apex/DurationTracker.insertSession';
import getTotalDuration from '@salesforce/apex/DurationTracker.getTotalDuration';
import Id from '@salesforce/user/Id';

const calculateString = (duration) => {
    let hours = Math.floor(duration / 3600);
    let minutes = Math.floor((duration % 3600) / 60)
    let seconds = Math.floor((duration % 3600) % 60)

    return ("0" + hours).slice(-2) + ":" 
        + ("0" + minutes).slice(-2) + ":"
        + ("0" + seconds).slice(-2);
}

const PLAYBUTTON = 'utility:play'
const PAUSEBUTTON = 'utility:pause'
export default class DurationTracker extends LightningElement {
    @api recordId
    seconds = 0
    minutes = 0
    hours = 0
    userId = Id
    totalTimeSeconds = 0

    interval = false;

    buttonName = PAUSEBUTTON

    get string() {
        return this.format(this.hours) +
            ":" + this.format(this.minutes) +
            ":" + this.format(this.seconds)
    }

    get totalTime() {
        return calculateString(this.totalTimeSeconds)
    }

    format(integer) {
        return ("0" + integer).slice(-2)
    }

    connectedCallback() {
        this.startTimer()
        this.checkFocus()

        this.getTotalDuration()
    }

    disconnectedCallback() {
        this.insertRecord()
    }

    getTotalDuration() {
        getTotalDuration({caseId: this.recordId})
        .then(data => {
            this.totalTimeSeconds = data
        })
    }

    insertRecord() {
        let durationSeconds = this.hours * 60 * 60 + this.minutes * 60 + this.seconds
        insertSession({caseId: this.recordId, userId: this.userId, durationSeconds: durationSeconds})
        .then(result => {
            console.log('called apex' + result)
        })
        .catch(error => {
            console.log(error);
        })
    }

    checkFocus() {
        setInterval(() => {
            if (document.hasFocus() && this.buttonName === PAUSEBUTTON) {
                this.startTimer()
            } else {
                this.stopTimer()
            }
        }, 1000)

    }

    startTimer() {
        if (this.interval) return;           // check if the interval is running already, if yes the dont run it again
        this.interval = setInterval(() => {
            this.seconds++;
            if (this.seconds === 60) {
                this.minutes++
                this.seconds = 0
            }
            if (this.minutes === 60) {
                this.minutes = 0
                this.hours++
            }
        }, 1000)
    }

    stopTimer() {
        clearInterval(this.interval)
        this.interval = false                   // properly kill the interval variable by setting to false
    }

    playPauseClick() {
        if (this.buttonName === PAUSEBUTTON) {
            this.buttonName = PLAYBUTTON
            this.stopTimer()
        } else {
            this.buttonName = PAUSEBUTTON
            this.startTimer()
        }
    }
}