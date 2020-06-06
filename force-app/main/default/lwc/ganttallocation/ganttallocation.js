import { LightningElement, api, track } from 'lwc';

export default class Ganttallocation extends LightningElement {
	
	@api project;
	@api projectId;
	@api dateIncrement;
	@api startDate;
	@api endDate;
	
	@track myVar;
	
	
	connectedCallback() {
		
	}
	
}