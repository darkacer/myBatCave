public class MyController {
    
    private final Account acc;
    public MyController() {
        	acc =  [SELECT Id, Name, Site FROM Account
                       WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
    
    public Account getAccount() {
        return acc;
    }
    
    public PageReference save() {
        update acc;
        //return null;
        
       
         PageReference secondpage = page.mySecondpage;
		 secondpage.setRedirect(true);
		 secondpage.getParameters().put('id', acc.id);
		 return secondpage;
			
         
    }
}