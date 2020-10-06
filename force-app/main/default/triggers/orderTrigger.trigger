trigger orderTrigger on Order (before Insert, after update) {
    
    if (Trigger.isInsert && Trigger.isbefore) {
        OrderTriggerHandler.beforeInsertTrigger(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        OrderTriggerHandler.afterUpdateTrigger(Trigger.new, Trigger.oldMap);
	}
    
}