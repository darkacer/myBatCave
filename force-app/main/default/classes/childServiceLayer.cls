public with sharing class childServiceLayer {
    public childServiceLayer() {

    }

    public class CSLException extends exception {
    }


    @testVisible
    private static void safelySave(List<child__c> childRecords) {
        try {
            System.SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.UPDATABLE,
                childRecords
            );
            update decision.getRecords();
        } catch (DMLException dmle) {
            System.debug(
                LoggingLevel.INFO,
                'Hey, a DML error occurred while updating.'
            );
            throw new CSLException(dmle.getMessage());
        } catch (System.NoAccessException nae) {
            throw new CSLException(nae.getMessage());
        }
    }
}
