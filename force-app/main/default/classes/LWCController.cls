public with sharing class LWCController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList(Integer count){
        return [SELECT Id, Name, Title, Phone, Email, Picture__c FROM Contact LIMIT :count];
    }
}