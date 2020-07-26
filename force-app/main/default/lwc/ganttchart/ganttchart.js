import { LightningElement, api, track } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";

import momentJS from "@salesforce/resourceUrl/momentJS";

import getChartData from "@salesforce/apex/GanttChartController.getGanttData";

const [DEFAULT_DAYS_SHIFT, MONTH_DAYS_SHIFT] = [7, 31];
const [DAY_SLOT_SIZE, WEEK_SLOT_SIZE, MONTH_SLOT_SIZE] = [1, 7, 31];
const [DAY_SLOTS, WEEK_SLOTS, MONTH_SLOTS] = [14, 10, 6]
export default class Ganttchart extends LightningElement {
    
    @api recordId;
    @api defaultView;
    @api methodName = 'getGanttDataMileStone';

    @track projects=[];
	@track startDateUTC;
	@track formattedStartDate;
	@track formattedEndDate;
	@track datePickerString;
	@track dates;
	@track dateShift = DEFAULT_DAYS_SHIFT;

	@track view = {
		
		options: [
			{label: "View by Day", value: DAY_SLOT_SIZE+'/'+DAY_SLOTS+'/'+DEFAULT_DAYS_SHIFT},
			{label: "View by Week", value: WEEK_SLOT_SIZE+'/'+WEEK_SLOTS+'/'+DEFAULT_DAYS_SHIFT},
			{label: "View by Month", value: MONTH_SLOT_SIZE+'/'+MONTH_SLOTS+'/'+MONTH_DAYS_SHIFT},
			//slot size
			//# of slot
			//dateshift 
		],
		slotSize: DAY_SLOT_SIZE,
		slots: DAY_SLOTS
	};

	connectedCallback() {
		loadScript(this, momentJS)
		.then(() => {
			this.setStartDate(new Date());
			this.handleRefresh();
		});
	}
	
	firstDateOfWeek(date) {
		return moment(date).day(1).toDate()
	}

	firstDateOfMonth(date) {
		return moment(date).startOf('month').toDate()
	}
	
	setStartDate(_startDate) {
		if (_startDate instanceof Date) {
			_startDate.setHours(0, 0, 0, 0);
			
			this.datePickerString = _startDate.toISOString();
			
			this.startDate = (this.view.slotSize !== MONTH_SLOT_SIZE) ?
				this.firstDateOfWeek(_startDate) :
				this.firstDateOfMonth(_startDate)

			
			this.startDateUTC = moment(this.startDate)
							    .utc()
								.valueOf() - moment(this.startDate)
                                .utcOffset() * 60 * 1000 + "";
            this.formattedStartDate = moment(this.startDate).format('DD-MMM-YYYY');
			this.setDateHeaders();
		}
	}

	getNextDateInSlot(date) {
		let nextDate = date.add(this.view.slotSize, "days")
		return (this.view.slotSize === MONTH_SLOT_SIZE) ? moment(this.firstDateOfMonth(nextDate)) : nextDate
	}
	
	setDateHeaders() {
		
		this.endDate = (this.view.slotSize !== MONTH_SLOT_SIZE) ? 
						moment(this.startDate).add(this.view.slots * this.view.slotSize - 1, "days").toDate() :
						moment(this.startDate).add(this.view.slots, "month").add(-1, 'days').toDate()
		this.endDateUTC = moment(this.endDate)
						.utc()
						.valueOf() -
						moment(this.endDate).utcOffset() * 60 * 1000 + "";

		this.formattedEndDate = moment(this.endDate).format('DD-MMM-YYYY');
	
		let today = new Date();
		today.setHours(0, 0, 0, 0);
		today = today.getTime();

		let dates = {};

		for (let date = moment(this.startDate); date <= moment(this.endDate) ; date = this.getNextDateInSlot(date)) {
			let index = date.format("YYYYMM");
			if (!dates[index]) {
				dates[index] = {
					dayName: '',
					name: date.format("MMMM"),
					days: []
				};
			}

			let day = {
				class: "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
				label: date.format("M/D"),
				start: date.toDate()
			};

			if (this.view.slotSize > 1) {
				let end = moment(date).add(this.view.slotSize - 1, "days");
				day.end = end.toDate();
			} else {
				day.end = date.toDate();
				day.dayName = date.format("ddd");
				if (date.day() === 0) day.class = day.class + " lwc-is-week-end";
			}
			
			if (today >= day.start && today <= day.end) day.class += " lwc-is-today";
			
			dates[index].days.push(day);
			dates[index].style = "width: calc(" 
								+ dates[index].days.length
								+ "/"
								+ this.view.slots
								+ "*100%)";
		}

		// reorder index
        this.dates = Object.values(dates);
        
        Array.from(
            this.template.querySelectorAll("c-ganttallocation")
        ).forEach(resource => {
            resource.refreshDates(this.startDate, this.endDate, this.view.slotSize);
        });

	}
	
	handleRefresh() {

		getChartData({
			recordId: this.recordId,
			startDateStr: this.startDateUTC,
			endDateStr: this.endDateUTC,
			slotSize:this.view.slotSize,
			methodName: this.methodName
		})
		.then(data => {
            this.projects = []
			if (data) {
				this.projects.forEach(function (resource, i) {
					this.projects[i] = {
						Id: resource.Id,
						Name: resource.projectName,
						childDataList: {}
					};
				});
				
				let tempProjects = {...this.projects};
				data.forEach(newResource => {
					for (let i = 0; i < tempProjects.length; i++) {
						if (this.projects[i].Id === newResource.Id) {
							this.projects[i] = {...newResource};
							return;
						}
					}
					this.projects.push({...newResource});
				});
			}
		})
	}
	
	// utility methods
	
	navigateToToday() {
		this.setStartDate(new Date());
		this.handleRefresh();
	}

	getShiftedDate(start, direction){
		if (this.dateShift !== MONTH_DAYS_SHIFT) {
			(direction === 'prev') ? 
				start.setDate(start.getDate() - this.dateShift):
				start.setDate(start.getDate() + this.dateShift)
			return start
		}
		return (direction === 'prev') ? this.addMonths(start, -1) : this.addMonths(start, 1)
	}

	addMonths(date, skew) {
		return moment(date).add(skew, 'months').toDate();
	}

	navigateToPrevious() {
		let _startDate = new Date(this.startDate);
		_startDate = this.getShiftedDate(_startDate, 'prev');
		this.setStartDate(_startDate);
		this.handleRefresh();
	}

	navigateToNext() {
		let _startDate = new Date(this.startDate);
		_startDate = this.getShiftedDate(_startDate, 'next');

		this.setStartDate(_startDate);
		this.handleRefresh();
	}

	navigateToDay(event) {
		this.setStartDate(new Date(event.target.value + "T00:00:00"));
		this.handleRefresh();
	}

	setView(value) {
		let values = value.split("/");
		this.view.value = value;
		this.view.slotSize = parseInt(values[0], 10);
		this.view.slots = parseInt(values[1], 10);
		this.dateShift = parseInt(values[2], 10);
	}

	handleViewChange(event) {
		this.setView(event.target.value);
		this.setStartDate(this.startDate)
		this.setDateHeaders();
		this.handleRefresh();
	}

}