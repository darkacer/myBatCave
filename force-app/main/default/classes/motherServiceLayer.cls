public with sharing class motherServiceLayer {
    public motherServiceLayer() {

    }

    public class MSLException extends exception {
    }

    public static void updateMotherCount(Set<Id> motherIdSet) {

        if(motherIdSet.isEmpty()) return;

        Map<Id, Mother__c> motherMap = new Map<Id, Mother__c>();
        
        for(Child__c child : [SELECT Id, Gender__c, Mother__c FROM Child__c WHERE Mother__c in :motherIdSet]) {
            if(!motherMap.containsKey(child.Mother__c)) {
                motherMap.put(child.Mother__c, new Mother__c(Id=child.Mother__c, Sons__c = 0, Daughters__c = 0));
            }
            Mother__c temp = motherMap.get(child.Mother__c);
            System.debug('temp mother' + temp);
            if (child.Gender__c == 'Male') temp.Sons__c += 1;
            if (child.Gender__c == 'Female') temp.Daughters__c += 1;
            motherMap.put(child.Mother__c, temp);
        }

        safelySave(motherMap.values());
        return;
    }

    @testVisible
    private static void safelySave(List<Mother__c> motherRecords) {
        try {
            System.SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.UPDATABLE,
                motherRecords
            );
            update decision.getRecords();
        } catch (DMLException dmle) {
            System.debug(
                LoggingLevel.INFO,
                'Hey, a DML error occurred while updating.'
            );
            throw new MSLException(dmle.getMessage());
        } catch (System.NoAccessException nae) {
            throw new MSLException(nae.getMessage());
        }
    }
}
