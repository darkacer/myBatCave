trigger CustomObj_cTrigger on CustomObj__c (After insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        CustomObjTriggerHandler.AfterInsert(Trigger.new);
    }
}