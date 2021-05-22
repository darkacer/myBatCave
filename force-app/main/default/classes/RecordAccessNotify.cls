public with sharing class RecordAccessNotify {

    @AuraEnabled
    public static void init(Id recordId, String componentId, boolean recordOpened){
        try {
            System.debug('recordid ' + recordId);
            System.debug('componentId ' + componentId);
            publishPlatformEvent(new Record_accessed__e(
                Record_Id__c = recordId,
                Reply_back__c = true,
                UUID__c = componentId,
                Record_Opened__c = recordOpened
            ));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void attendance(Id recordId, String componentId){
        try {
            publishPlatformEvent(new Record_accessed__e(
                Record_Id__c = recordId,
                Reply_back__c = false,
                UUID__c = componentId,
                Record_Opened__c = false
            ));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static void publishPlatformEvent(Record_accessed__e platformEvent) {
        publishPlatformEvent(new List<Record_accessed__e>{platformEvent});
    }
    private static void publishPlatformEvent(List<Record_accessed__e> platformEventList) {

        List<Database.SaveResult> results = EventBus.publish(platformEventList);
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }
}
