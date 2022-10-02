public without sharing class CloneSObjectDAG {
    public static void demoMethod(Id attachmentRecord) {

        // attachmentRecord = '0017F00002l6spTQAQ';

        List<WrapperClass> listOfWrapperClasses = new List<WrapperClass>();
        List<Account> accList = [
            SELECT Id, name, description 
            FROM Account 
            WHERE id = '0017F00002l6spTQAQ'
        ];
        WrapperClass accountRecords = new WrapperClass(
            accList,
            null,
            'Account',
            false,
            null
        );
        listOfWrapperClasses.add(accountRecords);

        WrapperClass contactRecords = new WrapperClass(
            [
                SELECT Id, AccountId, account.name,account.description, lastname 
                FROM contact 
                WHERE Accountid = :accList[0].Id
            ],
            new Set<String> {
                'AccountId'
            },
            'Contact',
            false,
            null
        );
        listOfWrapperClasses.add(contactRecords);

        WrapperClass opportunityRecords = new WrapperClass(
            [
                SELECT Id, name, Amount, CloseDate, AccountId, StageName 
                FROM Opportunity 
                WHERE Accountid = :accList[0].Id
            ],
            new Set<String> {
                'AccountId'
            },
            'Opportunity',
            false,
            null
        );
        listOfWrapperClasses.add(opportunityRecords);

        WrapperClass genericRecords = new WrapperClass(
            [
                SELECT Id, Name, Value__c, custom_parent__c, Opportuntiy__c, Identifier__c 
                FROM Generic_Custom_JSON__c
                WHERE Identifier__c = 'testIden'
            ],
            new Set<String> {
                'Opportuntiy__c',
                'custom_parent__c'
            },
            'Generic_Custom_JSON__c',
            true,
            'custom_parent__c'
        );
        listOfWrapperClasses.add(genericRecords);


        CloneSObjectDAGUtility.main(listOfWrapperClasses, attachmentRecord);

    }

    public class WrapperClass {
        public List<sObject> records;
        public String sObjectName;
        public Set<String> fieldsToRef;
        public Boolean hasSelfRelationship;
        public String ifSelfRefThenFieldName;

        public WrapperClass(List<sObject> records,  Set<String> fieldsToRef, String sObjectName,Boolean hasSelfRelationship, String ifSelfRefThenFieldName) {
            this.records = records;
            this.sObjectName = sObjectName;
            this.fieldsToRef = fieldsToRef;
            this.hasSelfRelationship = hasSelfRelationship;
            this.ifSelfRefThenFieldName = ifSelfRefThenFieldName;
        }
    }

    
}
