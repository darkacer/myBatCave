global class MyScheduleapex implements Schedulable{
	global void execute(SchedulableContext sc) {
		//sendmail();
		List<CustomObj__c> mylist = [select id, Email_to_send__c, Clarification_Start_Date__c from CustomObj__c where Clarification_Start_Date__c = Today];
        //for ()
        sendmail();
	}
    
    public void sendmail() {
        
    }
}