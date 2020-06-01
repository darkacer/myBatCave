import { LightningElement, api, track } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";

import momentJS from "@salesforce/resourceUrl/momentJS";

import getChartData from "@salesforce/apex/GanttChartController.getGanttData";


export default class Ganttchart extends LightningElement {
	
	@api defaultView
	@track startDateUTC
	@track formattedStartDate
	@track formattedEndDate
	@track datePickerString
	@track dates;
	@track dateShift = 7;
	
	@track returnedData;
	
	
	@track view = {
		options: [
			{
				label: "View by Day",
				value: "1/14"
			},
			{
				label: "View by Week",
				value: "7/10"
			}
		],
		slotSize: 1,
		slots: 14
	};
	
	
	connectedCallback() {
		/*Promise.all([
			loadScript(this, momentJS)
		])
		*/
		
		loadScript(this, momentJS)
		.then(() => {
			/*
			switch (this.defaultView) {
				case "View by Day":
					//this.setView([1, 14]);
					break;
				default:
					//this.setView([7, 10])
			}
			*/
			
			this.setStartDate(new Date());
			this.handleRefresh();
			
		});
	}
	
	
	setStartDate(_startDate) {
		if (_startDate instanceof Date) {
			_startDate.setHours(0, 0, 0, 0);
			
			this.datePickerString = _startDate.toISOString();
			
			this.startDate = moment(_startDate)
							.day(1)
							.toDate();
			
			this.startDateUTC = moment(this.startDate)
								.utc()
								.valueOf() - moment(this.startDate)
								.utcOffset() * 60 * 1000 + "";
			this.formattedStartDate = this.startDate.toLocaleString();
			

			this.setDateHeaders()
		}
	}
	
	setDateHeaders() {
		
		this.endDate = moment(this.startDate)
						.add(this.view.slots * this.view.slotSize - 1, "days")
						.toDate();
		this.endDateUTC = moment(this.endDate)
						.utc()
						.valueOf() -
						moment(this.endDate).utcOffset() * 60 * 1000 + "";
		this.formattedEndDate = this.endDate.toLocaleString();
		
		console.log('formattedStartDate ', this.formattedStartDate)
		console.log('formattedEndDate ', this.formattedEndDate)
		
		
		
		let today = new Date();
		today.setHours(0, 0, 0, 0);
		today = today.getTime();

		let dates = {};

		for (let date = moment(this.startDate); date <= moment(this.endDate); date.add(this.view.slotSize, "days")) {
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
		console.log('dates -> ', dates)
		this.dates = Object.values(dates);


	}
	
	handleRefresh() {

		getChartData({
			recordId: 'omkar',
			startDateStr: this.startDateUTC,
			endDateStr: this.endDateUTC
		})
		.then(data => {
			if (data) {
				console.log('data is ', data)
				
			}
		})
	}
	
	// utility methods
	
	navigateToToday() {
		this.setStartDate(new Date());
		this.handleRefresh();
	}

	navigateToPrevious() {
		let _startDate = new Date(this.startDate);
		_startDate.setDate(_startDate.getDate() - this.dateShift);

		this.setStartDate(_startDate);
		this.handleRefresh();
	}

	navigateToNext() {
		let _startDate = new Date(this.startDate);
		_startDate.setDate(_startDate.getDate() + this.dateShift);

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
	}

	handleViewChange(event) {
		this.setView(event.target.value);
		this.setDateHeaders();
		this.handleRefresh();
	}
	
}





