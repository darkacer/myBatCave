/*
    Script for generating JSON for the CLI
    this json can be used to insert records to anyother org 
    without having to create a new class and a new method
    with SFDX import cmd 
*/
public with sharing class JSONGeneratorForCLI {
    public static Id recordId = 'a097F00000BC6czQAD';
    public JSONGeneratorForCLI() {}

    public static void demo(Id recordId) {
        recordId = recordId;
        List<Generic_Custom_JSON__c> parentList = [
            SELECT Id, Identifier__c, Name, OwnerId, SystemModstamp, Value__c, custom_parent__c
            FROM Generic_Custom_JSON__c
            // WHERE custom_parent__c = null
            WHERE Id = 'a1h7F0000093VodQAE'
        ];

        Map<Id, Generic_Custom_JSON__c> childMap = new Map<Id, Generic_Custom_JSON__c>([
            SELECT Id, Identifier__c, Name, OwnerId, SystemModstamp, Value__c, custom_parent__c
            FROM Generic_Custom_JSON__c
            WHERE custom_parent__c = :parentList[0].Id
        ]);

        Map<Id, Generic_Custom_JSON__c> grandChildMap = new Map<Id, Generic_Custom_JSON__c>([
            SELECT Id, Identifier__c, Name, OwnerId, SystemModstamp, Value__c, custom_parent__c
            FROM Generic_Custom_JSON__c
            WHERE custom_parent__c In :childMap.keySet()
        ]);

        Map<String, CloneSObjects.OverRideSobjectFields> overRideAccountMap = new Map<String, CloneSObjects.OverRideSobjectFields> {
            // only copies fields from template's records
            'custom_parent__c' => new CloneSObjects.ReturnTemplateFieldValue('custom_parent__c')
        };

        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapContact = new Map<String, CloneSObjects.OverRideSobjectFields> {
            // copies fields from parent records
            'custom_parent__c' => new CloneSObjects.RetrunParentRrefFromTemplate('custom_parent__c')
        };
            
        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapOpp = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'custom_parent__c' => new CloneSObjects.RetrunParentRrefFromTemplate('custom_parent__c')
        };

        CloneSObjects testDemo = new CloneSObjects()
                                .cloneSobjectsFrom(parentList, overRideAccountMap, false, true)
                                .cloneSobjectsFrom(childMap.values(), overRideMapContact, false, true)
                                .cloneSobjectsFrom(grandChildMap.values(), overRideMapOpp, false, true);
        // system.debug('Cloned records: ' + testDemo.getGeneratedRecords());
        CloneSObjectLibrary.insertAttachments(testDemo, recordId);

    }
}
