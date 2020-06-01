public class showDetailController {
    
    @AuraEnabled
    public static Mother__c getData(Id recId, String message) {
        system.debug('the message is '+ message);
        return [Select id, name, age__c, Occupation__c from Mother__c where id =:recId limit 1];
    }

}