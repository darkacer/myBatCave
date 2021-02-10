trigger updateCount on Child__c (after insert, after update) {
    
    new childTriggerHandler().run();
    
}