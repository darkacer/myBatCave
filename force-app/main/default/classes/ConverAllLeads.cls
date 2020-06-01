/*ConverAllLeads myBatchObject = new ConverAllLeads('test string'); 
Id batchId = Database.executeBatch(myBatchObject);*/
global class ConverAllLeads implements Database.Batchable<sObject>, Database.Stateful {
    
    private String myString;
    public ConverAllLeads(String passedValue) {
        myString = passedValue;
        System.debug('the passed value is '+ myString);
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id FROM Lead WHERE IsConverted = FALSE';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, Lead[] listOfLeads) {
        System.debug('the passed value is '+ myString);
        Database.LeadConvert[] lcList = new Database.LeadConvert[0];
       /* String leadStatus = [Select MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
        for(Lead record : listOfLeads) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(record.Id);
            lc.setConvertedStatus(leadStatus);
            lc.setDoNotCreateOpportunity(true);
            lcList.add(lc);
        }
       Database.LeadConvertResult[] lcr = Database.convertLead(lcList, false);*/
    }
    
    global void finish(Database.BatchableContext context) {

    }
    
}