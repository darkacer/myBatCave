public class searchControllerClass {
	@AuraEnabled
    public static List<Contact> getContacts() {
        return [SELECT Name, Phone from Contact limit 200];
    }
    
    
    @AuraEnabled
    public static Id getCloudProjectId (Id projectid) {
        return [select id from Child__C where Mother__c =: projectid limit 1 ][0].id;
    }
}