trigger childTrigger on Child__c (
    before insert, before update
) {
    new childTriggerHandler().run();
    system.debug('current user id ' + UserInfo.getUserId());
}