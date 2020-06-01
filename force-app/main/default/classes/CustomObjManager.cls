@RestResource(urlMapping='/CustomObj/*')
global with sharing class CustomObjManager {
    @HttpGet
    global static CustomObj__c getObjById() {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        String MyId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        CustomObj__c result =  [SELECT Clarification__c,Name,Email__c,User__c
                        FROM CustomObj__c
                        WHERE Id = :MyId];
        return result;
    }
    @HttpPost
    global static ID createCase(String name, String Email,
        String User, Boolean clarification) {
        CustomObj__c thisCase = new CustomObj__c(
            Name=name,
            Clarification__c=clarification);
        insert thisCase;
        return thisCase.Id;
    }           
}