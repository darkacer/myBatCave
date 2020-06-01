public class assign1 {
    
    // creates given number of opportunites and inserts them 
    
    /*	 Assign1 assign1 = new assign1();
    	 Assign1.createOpportunities(5); */
    
    public void createOpportunities (Integer num) {
     	List<Opportunity> opps = new List<Opportunity>{};
		for(Integer i = 0; i < num; i++){
			Opportunity Opp = new Opportunity(Name = 'Test Opportunity ' + i);
            opps.add(Opp);
        }
        
        try {
            insert opps;
        }
        catch (exception e) {
            system.debug('error is :'+ e);
        }
    }
    
    //creates a product and associates it with the given opportunity name
    /*
      	Assign1 assign1 = new assign1();
      	List<String> strList = new List<String>();
		strList.add('0067F000004qj3vQAA');
        strList.add('0067F000004qj40QAA');
        strList.add('0067F000004qj4DQAQ');
		Assign1.associateProducts(strList);
    */
	public void associateProducts (List<String> idList) {
        for (Integer i = 0; i < idList.size(); i++) {
            Opportunity oppr = new Opportunity(Id = idList[i]);
            
            Product2 pro = new Product2(Name='product1', isActive=true);
            insert pro;
          
            Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pro.Id, UnitPrice = 1000, IsActive = true);
            insert standardPBE;
            
            Pricebook2 pb2 = new Pricebook2(Name ='test');
            insert pb2;
            
            PricebookEntry pbe = new PricebookEntry(unitprice=0.01,Product2Id=pro.Id,isActive=true,Pricebook2Id = pb2.Id,UseStandardPrice = false);
            insert pbe;
            
            OpportunityLineItem Oplineitem = new OpportunityLineItem (Quantity=2,OpportunityId = oppr.Id,PriceBookEntryId=pbe.Id,TotalPrice = 500);
            insert Oplineitem;
        }
    }
    
    
    //if true is passed removes all products from opportunity else reads the list and removes that ids
    /*
        Assign1 assign1 = new assign1();	
        List<String> strList1 = new List<String>();
		List<String> strList2 = new List<String>();
        strList1.add('0067F000004qj3vQAA');
        strList1.add('0067F000004qj40QAA');
        strList1.add('0067F000004qj4DQAQ');
		strList2.add('01t7F000002BHcVQAW');
		strList2.add('01t7F000002BHccQAG');
        Assign1.removeProducts(false, strList1, strList2);
		Assign1.removeProducts(true, strList, strList2);
	*/
    public void removeProducts (Boolean all, List<String> oppList, List<String> prodList) { 
        if (all  == true) {
        	List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
			olis = [Select Id From OpportunityLineItem];
        	if(olis.size()>0) delete olis;
        }
        else {
            for (Integer i = 0; i < prodList.size(); i++) {
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();                
                olis = [Select Id  From Opportunitylineitem Where PriceBookEntryId in (Select Id From PricebookEntry Where Product2Id = :prodList[i])];
                if(olis.size()>0) delete olis;
            }
            
            for (Integer i = 0; i < prodList.size(); i++) {
                List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
                olis = [Select Id From OpportunityLineItem Where OpportunityId = :prodlist[i]];
                if(olis.size()>0) delete olis;
            }
        }
    }
    
    
    public void addProductsToPBE () {
        for (Integer i = 2; i <= 25; i++) {
            Product2 pro = new Product2(Name='product ' + i , isActive=true, Type__c = 'Testing');
            insert pro;
        }
    }
    
    public void deleteProducts () {
        List<Product2> olis = new List<Product2>();
        olis = [Select Id from Product2 where Type__c='Testing'];
    }
}