public with sharing class CloneSObjectDAG {
    public void demoMethod() {
        List<WrapperClass> listOfWrapperClasses = new List<WrapperClass>();
        WrapperClass accountRecords = new WrapperClass(
            records = [
                SELECT Id, name, description 
                FROM Account 
                WHERE name = 'Edge Communications'
            ],
            fieldsToRef = null,
            sObjectName = 'Account',
            hasSelfRelationship = false
        );
        listOfWrapperClasses.add(accountRecords);

        WrapperClass contactRecords = new WrapperClass(
            records = [
                SELECT Id, AccountId, account.name,account.description, lastname 
                FROM contact 
                WHERE Accountid = :accList[0].Id
            ],
            fieldsToRef = new Set<String> {
                'AccountId'
            },
            sObjectName = 'Contact',
            hasSelfRelationship = false
        );
        listOfWrapperClasses.add(contactRecords);

        WrapperClass opportunityRecords = new WrapperClass(
            records = [
                SELECT Id, name, Amount, CloseDate, AccountId, StageName 
                FROM Opportunity 
                WHERE Accountid = :accList[0].Id
            ],
            fieldsToRef = new Set<String> {
                'AccountId'
            },
            sObjectName = 'Opportunity',
            hasSelfRelationship = false
        );
        listOfWrapperClasses.add(opportunityRecords);


    }

    public WrapperClass {
        public List<sObject> records;
        public String sObjectName;
        public Set<String> fieldsToRef;
        public Boolean hasSelfRelationship;
    }

    
}
