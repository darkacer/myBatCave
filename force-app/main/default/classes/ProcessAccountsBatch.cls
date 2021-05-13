public class ProcessAccountsBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(
            'SELECT ID, Name, NumberOfEmployees, BillingCity, BillingState, ' +
            'BillingPostalCode FROM Account'
        );
    }

    private static Integer incrementByOne(Integer count) {
        return (count == null) ? 1 : count++;
    }
    public void execute(Database.BatchableContext bc, List<Account> accountRecords){
        // process each batch of records
        for(Account acc : accountRecords) {
            acc.NumberOfEmployees = incrementByOne(acc.NumberOfEmployees);
        }

        try {
            update accountRecords;

            Batch_Progress__e bpEvent = new Batch_Progress__e();

            AsyncApexJob job = [
                SELECT Id, Status, NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
            ];

            bpEvent.Batch_Id__c = bc.getJobId();
            bpEvent.Class_name__c = 'ProcessAccountsBatch';
            bpEvent.Count__c = Integer.valueOf(job.JobItemsProcessed);
            bpEvent.DML_type__c = 'Update';
            bpEvent.isSuccess__c = true;
            bpEvent.ObjectApiName__c = 'Account';

            Database.SaveResult results = EventBus.publish(bpEvent);
            
            if (results.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : results.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }
            
        } catch(Exception e) {
            system.debug(e);
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}