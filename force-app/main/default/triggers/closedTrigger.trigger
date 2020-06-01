trigger closedTrigger on Opportunity (before update, after update) {
    if(Trigger.isBefore){
        for (Opportunity opp : Trigger.New) {
            if (opp.My_Stage__c == 'Completed') {
                opp.StageName = 'Closed Won';
                opp.My_Stage__c = null;
            } else {
                System.debug('not valid My Stage feild value');
            }
        }
    }
}