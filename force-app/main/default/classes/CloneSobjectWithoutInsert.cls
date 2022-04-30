public with sharing class CloneSobjectWithoutInsert {
    public CloneSobjectWithoutInsert() {

    }

    public static void demo() {
        Id attachingToId = 'a097F00000BC6czQAD';
        List<Account> accList = [Select Id, name, description, BillingCity from Account Where name like 'Edge Communications%'];
        List<Contact> conList = [Select Id, lastname from contact where Accountid = :accList[0].Id];
        List<Opportunity> oppList = [Select Id, name, Amount, CloseDate, AccountId, StageName From Opportunity Where Accountid = :accList[0].Id];

        Map<String, CloneSObjects.OverRideSobjectFields> overRideAccountMap = new Map<String, CloneSObjects.OverRideSobjectFields> {
            // only copies fields from template's records
            'ShippingCity' => new CloneSObjects.ReturnTemplateFieldValue('BillingCity')
        };

        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapContact = new Map<String, CloneSObjects.OverRideSobjectFields> {
            // copies fields from parent records
            'AccountId' => new CloneSObjects.RetrunParentRrefFromTemplate('AccountId')
        };
            
        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapOpp = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'AccountId' => new CloneSObjects.RetrunParentRrefFromTemplate('AccountId')
        };

        CloneSObjects testDemo = new CloneSObjects()
                                .cloneSobjectsFrom(accList, overRideAccountMap, false, true)
                                .cloneSobjectsFrom(conList, overRideMapContact, false, true)
                                .cloneSobjectsFrom(oppList, overRideMapOpp, false, false);
        // system.debug('Cloned records: ' + testDemo.getGeneratedRecords());
        CloneSObjectLibrary.insertAttachments(testDemo, attachingToId);
        
    }
}