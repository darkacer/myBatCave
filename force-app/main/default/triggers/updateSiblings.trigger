trigger updateSiblings on Child__c (before insert, before update) {
    if (Trigger.isUpdate && Trigger.isBefore)
    childObjHandler.updateChilds (Trigger.new, Trigger.oldMap);
}