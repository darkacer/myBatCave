@isTest
public class JSONGeneratorForCLITest {
    public JSONGeneratorForCLITest() {}

    @testSetup
    private static void testSetup() {
        // List<Generic_Custom_JSON__c> recordList = new List<Generic_Custom_JSON__c>();
        Generic_Custom_JSON__c parent = new Generic_Custom_JSON__c(
            // Name = 'Parent',
            Identifier__c = 'generic'
        );
        insert parent;
        Generic_Custom_JSON__c child = new Generic_Custom_JSON__c(
            // Name = 'Child',
            Identifier__c = 'child',
            custom_parent__c = parent.Id
        );
        insert child;
    }

    @isTest
    private static void genericTest() {
        Generic_Custom_JSON__c parentRecord = [
            SELECT Id 
            FROM Generic_Custom_JSON__c 
            WHERE Identifier__c = 'generic' 
            LIMIT 1
        ];
        // JSONGeneratorForCLI.recordId = parentRecord.Id;
        JSONGeneratorForCLI.demo(parentRecord.Id);
    }
}
