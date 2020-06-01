global class myBatchClass implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('select id, name from L3DB_Total_Case__c');

    }
    global void execute(Database.BatchableContext bc, L3DB_Total_Case__c[] records){
        // process each batch of records
        List <L3DB_Total_Case__c> mylist = new List<L3DB_Total_Case__c>();
        for (Integer i = 0; i < 5000; i++) {
            L3DB_Total_Case__c myobj = new L3DB_Total_Case__c();
            myobj.Name = 'Name' + i;
            myobj.Count__c = i;
            mylist.add(myobj);
        }
        insert mylist;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}

// To invoke the batch class 
// myBatchClass myBatchObject = new myBatchClass(); 
// Id batchId = Database.executeBatch(myBatchObject);