import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// const dateOption = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'}
const MONTH_SLOT_SIZE = 31;

export default class Ganttallocation extends NavigationMixin(LightningElement) {
    @api _project;
    @api projectId;
    @api dateIncrement;
    @api startDate;
    @api endDate;

    @track myVar;
    @track tasks;

    @api
    get project() {
        return this._project;
    }
    set project(_project) {
        this._project = {
            ..._project
        };
        console.log(this.startDate, '<------------->')
        console.log(this.endDate, '<------------->')
        this.setTasks();
    }


    connectedCallback() {
        console.log(this.startDate, '-------------')
        console.log(this.endDate, '-------------')
        this.refreshDates(this.startDate, this.endDate, this.dateIncrement);
    }
    @api
    refreshDates(startDate, endDate, dateIncrement) {
        console.log(this.startDate, '<$$$$>')
        console.log(this.endDate, '<$$$$>')
        if (startDate && endDate && dateIncrement) {
            let times = [];
            let today = new Date();
            today.setHours(0, 0, 0, 0);
            today = today.getTime();

            for (
                let date = new Date(startDate); date <= endDate; date.setDate(date.getDate() + dateIncrement)
            ) {
                let time = {
                    class: "slds-col lwc-timeslot",
                    start: date.getTime()
                };
                if (dateIncrement > 1) {
                    let end = new Date(date);
                    end.setDate(end.getDate() + dateIncrement - 1);
                    time.end = end.getTime();
                } else {
                    time.end = date.getTime();

                    if (times.length % 7 === 6) {
                        time.class += " lwc-is-week-end";
                    }
                }

                if (today >= time.start && today <= time.end) {
                    time.class += " lwc-is-today";
                }

                times.push(time);
            }
            this.times = times;
            this.startDate = startDate;
            this.endDate = endDate;
            this.dateIncrement = dateIncrement;
            this.setTasks();
        }
    }

    setTasks() {
        this.tasks = []
        Object.keys(this.project.taskDataList).forEach(task => {
            let tempTask = {
                ...this.project.taskDataList[task]
            }
            tempTask = this.calculateLeftAndRight(tempTask)
            tempTask.style = this.calcStyle(tempTask);
            tempTask.labelStyle = this.calcLabelStyle(tempTask);
            tempTask.toolTipContent = this.toolTipContent(tempTask)
            tempTask.class = ["slds-is-absolute", "lwc-allocation"].join(" ");
            this.tasks.push(tempTask);
        })
    }

    calculateLeftAndRight(temp) {
        if (this.dateIncrement === MONTH_SLOT_SIZE) {
            temp.left = this.monthCorrector(this.startDate, temp.startDate, 'left')
            temp.right = this.monthCorrector(this.startDate, temp.endDate, 'right')
            return temp
        }
        let taskStart = Date.parse(temp.startDate) - 24 * 3600 * 1000
        let taskEnd = Date.parse(temp.endDate)
        let startDate = Date.parse(JSON.stringify(new Date(this.startDate)).slice(1,11))
        
        temp.left = (taskStart - startDate) / 1000 / 3600 / 24 / this.dateIncrement
        temp.right = (taskEnd - startDate) / 1000 / 3600 / 24 / this.dateIncrement
        return temp
    }

    monthCorrector(dateFrom, dateTo, type) {
        let numberOfMonths = this.monthDiff(new Date(dateFrom), new Date(dateTo))
        let myDateTo = new Date(dateTo);
        let preDate =  (type === 'left') ? -1 / this.getDaysInMonth(myDateTo) : 0
        let offset = myDateTo.getDate() / this.getDaysInMonth(myDateTo)
        return numberOfMonths + offset + preDate;
    }

    addDays(date, days) {
        date.setDate(date.getDate() + days)
        return date;
    }

    getDaysInMonth(date) {
        return new Date(date.getFullYear(), date.getMonth(), 0).getDate();
    }
    
    firstDateOfMonth(date) {
        return new Date(date.getFullYear(), date.getMonth(), 1);
    }

    monthDiff(dateFrom, dateTo) {
        return dateTo.getMonth() - dateFrom.getMonth() + 
          (12 * (dateTo.getFullYear() - dateFrom.getFullYear()))
    }

    toolTipContent(tempTask) {
        return 'From: ' + new Date(tempTask.startDate).toLocaleDateString('en-US', dateOption) + '\n'
            + 'To: ' + new Date(tempTask.endDate).toLocaleDateString('en-US', dateOption) + '\n'
            + 'Task Name: ' + tempTask.taskName + '\n'
            + 'Assigned To: ' + tempTask.assignedTo + '\n'
            + 'Completion : ' + tempTask.completionPercent + '%\n'
            + 'Description: ' + tempTask.description + '\n'
            + 'Completion Date: ' +  tempTask.completedDate
    }

    calcStyle(allocation) {
        if (!this.times) return
        const totalSlots = this.times.length;
        let styles = [
            "left: " + (allocation.left / totalSlots) * 100 + "%",
            "right: " +
            ((totalSlots - (allocation.right)) / totalSlots) * 100 +
            "%"
        ];

        const backgroundColor = allocation.color;
        const colorMap = {
            Blue: "#1589EE",
            Green: "#4AAD59",
            Red: "#E52D34",
            Turqoise: "#0DBCB9",
            Navy: "#052F5F",
            Orange: "#E56532",
            Purple: "#62548E",
            Pink: "#CA7CCE",
            Brown: "#823E17"
        };
        styles.push("background-color: " + colorMap[backgroundColor]);
        styles.push("pointer-events: auto");
        styles.push("transition: none");

        return styles.join("; ");
    }

    calcLabelStyle(allocation) {
        if (!this.times) return;

        const totalSlots = this.times.length;
        let left = allocation.left / totalSlots < 0 ? 0 : allocation.left / totalSlots;
        let right = (totalSlots - (allocation.right)) / totalSlots < 0 ?
            0 :
            (totalSlots - (allocation.right)) / totalSlots;
        let styles = [
            "left: calc(" + left * 100 + "%)",
            "right: calc(" + right * 100 + "%)"
        ];

        styles.push("transition: none")
        return styles.join("; ");
    }

    handleOpenTaskAction(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'project_cloud__Project_Task__c',
                actionName: 'view'
            }
        });
    }
}