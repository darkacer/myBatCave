public with sharing class DurationTracker {
    public DurationTracker() {

    }

    @AuraEnabled
    public static void setDuration(String context){
        try {
            System.debug('inside apex method ' + context);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void checkOtherInstances(String hashString){
        try {
            // get the hash string 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertSession(Id userId, Id caseId, Integer durationSeconds){
        try {
            // check if record is already present for the given userid and caseid combo

            List<CaseTimer19__Session_Time__c> preSessionList = [
                Select Id, CaseTimer19__Agent__c, CaseTimer19__Case__c, CaseTimer19__Duration__c
                From CaseTimer19__Session_Time__c
                Where CaseTimer19__Agent__c = :userId
                And CaseTimer19__Case__c = :caseId
                Limit 1
            ];

            if(preSessionList.isEmpty()) {
                CaseTimer19__Session_Time__c sessionTime = new CaseTimer19__Session_Time__c(
                    CaseTimer19__Agent__c = userId,
                    CaseTimer19__Case__c = caseId,
                    CaseTimer19__Date__c = Date.today(),
                    CaseTimer19__Duration__c = durationSeconds,
                    Name = 'sessionEntry ' + Date.today()
                );
                insert sessionTime;
            } else {
                preSessionList[0].CaseTimer19__Duration__c += durationSeconds;
                update preSessionList[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CaseTimer19__Session_Time__c> getSessionTimes(Id caseId){
        try {
            System.debug('caseid ' + caseId);
            return [
                Select Id, CaseTimer19__Agent__r.Name, CaseTimer19__Duration__c, Name
                From CaseTimer19__Session_Time__c
                Where CaseTimer19__Case__c = :caseId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Integer getTotalDuration(Id caseId){
        try {
            AggregateResult[] groupedResults = [
                Select sum(CaseTimer19__Duration__c) duration
                From CaseTimer19__Session_Time__c
                Where CaseTimer19__Case__c = :caseId
            ];
            return Integer.valueOf(groupedResults[0].get('duration'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}