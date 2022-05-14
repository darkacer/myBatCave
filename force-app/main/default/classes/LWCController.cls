public with sharing class LWCController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList(Integer count){
        return [SELECT Id, Name, Title, Phone, Email, Picture__c FROM Contact LIMIT :count];
    }

    @AuraEnabled(cacheable=true)
    public static List<Generic_Custom_JSON__c> getRecordList(String queryString){
        String identifier = 'testIden';
        queryString = 'Select Id, custom_parent__c, custom_parent__r.Name, Value__c, name, Identifier__c From Generic_Custom_JSON__c Where Identifier__c = :identifier';
        return Database.query(queryString);
    }
}