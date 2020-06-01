global class testNewCode {
    
    public void put() {
     
    	system.debug('hello');
        account acc = new account();
        acc.name = 'myname';
        
        try {
            insert acc;
        }
        catch (exception e) {
            system.debug('error is :'+ e);
        }
    }
    
    
    public void iterator() {
        for (Integer i = 0; i < 10; i++) {
            system.debug(i);
        }
    }
    
    public void testFunction() {
        //reads data from static resource like query
        System.debug('hi');
        List<Opportunity> mylist = [SELECT ID FROM OPPORTUNITY WHERE ID = '0061h000002l7Fq'];
        System.debug(mylist.size());
    }
    			
    
    public void testCustomSetting () {
        CoustomObj__c label = CoustomObj__c.getInstance('name1');
        System.debug(label.lable__c);
    }
    
    
    
	webservice static String getContextUserName() {
        return 'hello there';
   }
    
    
    
}