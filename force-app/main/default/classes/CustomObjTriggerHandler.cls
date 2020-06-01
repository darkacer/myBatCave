public class CustomObjTriggerHandler {
    public static void AfterInsert(List<CustomObj__c> newList) {
        Set<Id> idSet = new Set<Id>();
        for(CustomObj__c obj : newList) {
            idSet.add(obj.Id);
        }
        List<CustomObj__c> checkList = [Select id, Name from CustomObj__c where CustomObj__c in : idSet];
    }
}