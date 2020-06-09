import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const dateOption = {weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'}

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
        this.setTasks();
    }


    connectedCallback() {
        this.refreshDates(this.startDate, this.endDate, this.dateIncrement);
    }
    @api
    refreshDates(startDate, endDate, dateIncrement) {
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
        Object.keys(this.project.childDataList).forEach(task => {
            let tempTask = {
                ...this.project.childDataList[task]
            }
            tempTask.style = this.calcStyle(tempTask);
            tempTask.labelStyle = this.calcLabelStyle(tempTask);
            tempTask.toolTipContent = this.toolTipContent(tempTask)
            tempTask.class = ["slds-is-absolute", "lwc-allocation"].join(" ");
            this.tasks.push(tempTask);
        })
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
            ((totalSlots - (allocation.right + 1)) / totalSlots) * 100 +
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
        let right = (totalSlots - (allocation.right + 1)) / totalSlots < 0 ?
            0 :
            (totalSlots - (allocation.right + 1)) / totalSlots;
        let styles = [
            "left: calc(" + left * 100 + "% + 15px)",
            "right: calc(" + right * 100 + "% + 30px)"
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