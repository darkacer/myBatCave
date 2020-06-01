trigger updateCount on Child__c (after insert, after update) {
    List<Mother__c> mothers = new List<Mother__c>();
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
    
    AggregateResult[] groupedResultsMale = [SELECT COUNT(Id), Mother__c FROM Child__c where Mother__c IN :motherids AND Gender__c = 'Male' GROUP BY Mother__c ];
    for(AggregateResult ar:groupedResultsMale) {
        Id custid = (ID)ar.get('Mother__c');
        Integer count = (INTEGER)ar.get('expr0');
        Mother__c cust1 = new Mother__c(Id=custid);
        cust1.Sons__c = count;     
        mothers.add(cust1);
    }
    update mothers;
    mothers.clear();
    AggregateResult[] groupedResultsFemale = [SELECT COUNT(Id), Mother__c FROM Child__c where Mother__c IN :motherids AND Gender__c = 'Female' GROUP BY Mother__c ];
    for(AggregateResult ar:groupedResultsFemale) {
        Id custid = (ID)ar.get('Mother__c');
        Integer count = (INTEGER)ar.get('expr0');
        Mother__c cust1 = new Mother__c(Id=custid);
        cust1.Daughters__c = count;
        //cust1.Childrens__c = count + cust1.Sons__c;
        mothers.add(cust1);
    }
    update mothers;
    mothers.clear();
    mothers = [select id, Sons__c, Daughters__c, Childrens__c from Mother__c where id in : motherids];
    for (Mother__c mo : mothers) {
        mo.Childrens__c = mo.Sons__c + mo.Daughters__c;
    }
    update mothers;
    mothers.clear();
    //////trigger for adding siblings
    //
    /*
    Map<Id, Mother__c> mymap= new Map<Id, Mother__c>();
    for (Id id: motherids) {
        Mother__c cust1 = new Mother__c(Id=id);
        mymap.put(id, cust1);
    }
    for (Child__c ch : Trigger.New) {
        Integer sibs = Integer.Valueof(mymap.get(ch.Mother__c).Childrens__c);
        ch.Siblings__c = sibs;
    }
    */
    
}