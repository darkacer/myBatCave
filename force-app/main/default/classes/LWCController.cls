public with sharing class LWCController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList(Integer count){
        return [SELECT Id, Name, Title, Phone, Email, Picture__c FROM Contact LIMIT :count];
    }

    public class inputFields {
        @AuraEnabled public String childApiName;
        @AuraEnabled public String parentApiName;
        @AuraEnabled public String columnNames;

    }

    @AuraEnabled
    public static string getChildRecords(String childApiName, String parentApiName){
        return 'yes';
    }


    public static String getFieldType(String objApiName, String fieldApiName) {
        

        return '';
    } 
}