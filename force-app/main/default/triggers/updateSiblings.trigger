trigger updateSiblings on Child__c (before insert, before update) {
    List<Id> motherids = new List<Id>();
    if (Trigger.isDelete) {
        for(Child__c test:Trigger.Old) {
            motherids.add(test.Mother__c);
        }
    }
    else if (Trigger.isUpdate) {
        for(Child__c test:Trigger.New) {
            motherids.add(test.Mother__c);
        }
        for(Child__c test:Trigger.Old) {
            motherids.add(test.Mother__c);
        }
    }
    else {
        for(Child__c test:Trigger.New) {
            motherids.add(test.Mother__c);
        }
    }
    
    Map<Id, Mother__c> mymap= new Map<Id, Mother__c>();
    AggregateResult[] groupedResults = [SELECT COUNT(Id), Mother__c FROM Child__c where Mother__c IN :motherids GROUP BY Mother__c ];
    for(AggregateResult ar:groupedResults) {
        Id custid = (ID)ar.get('Mother__c');
        Integer count = (INTEGER)ar.get('expr0');
        Mother__c cust1 = new Mother__c(Id=custid);
        cust1.Childrens__c = count;
        mymap.put(custid, cust1);
    }
 
    for (Child__c ch : Trigger.New) {


        Integer sibs = Integer.Valueof(mymap.get(ch.Mother__c).Childrens__c);
        if (Trigger.isUpdate) {
             ch.Siblings__c = sibs - 1;
        }
        else if (Trigger.isInsert) {
             ch.Siblings__c = sibs;
        }
    }
}