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
}
