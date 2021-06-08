@isTest
private class GanttChartControllerTest {
	@testSetup
    private static void setupMethod() {
        Id recordTypeId = Schema.SObjectType.project__c.getRecordTypeInfosByDeveloperName().get('Project_Products').getRecordTypeId();
        
        // insert parent object
        project__c project = new project__c(name='test project', recordTypeId=recordTypeId);
        insert project;
        
        // insert child object 
        task__c task = new task__c(name='test task', project__c=project.Id, start_date__c=date.today(), end_date__c=date.today().addDays(3));
        insert task;
        
    }
    
    @isTest
    private static void getGanttDataTest() {
        project__c project = [Select Id From project__c Limit 1];
        string startDate = String.valueOf(DateTime.newInstance(Date.today().addDays(-2), Time.newInstance(0, 0, 0, 0)).getTime());
        string endDate = String.valueOf(DateTime.newInstance(Date.today().addDays(5), Time.newInstance(0, 0, 0, 0)).getTime());
        List<GanttChartController.ProjectWrapperClass> returnData 
            = GanttChartController.getGanttData(project?.Id, startDate, endDate, 7);
        system.debug('user data ' + returnData);
    }
}