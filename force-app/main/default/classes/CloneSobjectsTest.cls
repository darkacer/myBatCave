@isTest
public without sharing class CloneSobjectsTest {
    @TestSetup
    static void makeData(){
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();

        for(Integer i = 0; i < 3; i++) {
            accountList.add(
                new Account(name = 'Test Account ' + i, BillingCity = 'Test City')
            );
        }

        insert accountList;

        for(Account acc : accountList) {
            for(Integer i = 0; i < 3; i++) {
                contactList.add(
                    new Contact(LastName = 'Test Contact ' + i, AccountId = acc.Id)
                );
            }
        }
        insert contactList;
    }
    
    @IsTest
    private static void cloneSobjectsFromTest() {
        List<Account> accList = [SELECT Id, Name, BillingCity FROM Account WHERE Name LIKE 'Test Account%'];
        List<Contact> conList = [SELECT Id, LastName, AccountId FROM Contact WHERE Account.Name LIKE 'Test Account%'];

        Map<String, CloneSObjects.OverRideSobjectFields> overRideAccountMap = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'ShippingCity' => new CloneSObjects.ReturnTemplateFieldValue('BillingCity')
        };
        Map<String, CloneSObjects.OverRideSobjectFields> overRideContactMap = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'AccountId' => new CloneSObjects.ReturnParentFieldFromTemplate('AccountId')
        };

        Set<SObject> newRecords = new CloneSobjects(false, true, false, false)
                                .cloneSobjectsFrom(accList, overRideAccountMap, true)
                                .cloneSobjectsFrom(conList, overRideContactMap, true)
                                .getClonedRecords();
        System.assertEquals(accList.size() + conList.size(), newRecords.size(), 'Not all records got cloned');
    }
}
