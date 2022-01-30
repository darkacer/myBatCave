public class TreeComponentController {
	
    @auraEnabled
    public static List<Generic_Custom_JSON__c> getCustomJson(String identifier) {
        List<Generic_Custom_JSON__c> genericList = new List<Generic_Custom_JSON__c>();
        genericList = [
            Select Id, Name, Custom_Parent__c, Value__c 
            from Generic_Custom_JSON__c 
            Where identifier__c = :identifier 
            Limit 200
        ];
        return genericList;
    }
}