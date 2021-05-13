public with sharing class BatchProgressController {

    @AuraEnabled
    public static string startBatch(){
        Id batchId;
        try {
            ProcessAccountsBatch pab = new ProcessAccountsBatch();
            batchId = Database.executeBatch(pab, 10);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return String.valueOf(batchId);
    }
}
