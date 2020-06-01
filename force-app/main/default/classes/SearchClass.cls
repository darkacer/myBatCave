public with sharing class SearchClass {
    
    public String nameQuery{get;set;}
    public List<Account> accounts{get;set;}
    public Boolean isTableExit {get;set;}
    public Integer offset {get;set;}
    public Boolean hasNext {get;set;}
    public Integer perPage {get; set;}
    public Boolean hasPrevious {get;set;}
    public Boolean firstCall {get; set;}    
    public SearchClass(){
        isTableExit=false;
        hasNext = true;
        hasPrevious = false;
        firstCall = true;
        offset = 0;
        perPage = 10;
       
    }
    public void previous() {
        //con.previous();
        offset -= perPage;
        firstCall = false;
        executeSearch();
        
        hasPrevious = true;
        if (offset < perPage) {
            hasPrevious = false;
        }
        if (accounts != null) {
            hasNext = true;
            if (accounts.size() < perPage) {
                hasNext = false;
            }
        }
    }
    
    
    public void next() {
        //con.next();
        offset += perPage;
        firstCall = false;
        executeSearch();
        if (accounts.size() < perPage) {
            hasNext = false;
        }
        else {
            hasNext = true;
        }
        hasPrevious = true;
    }
    
    public PageReference execute() {  // Wrapper class to main search method just to raise a flag so to understand that the call is from search button
        firstCall = true;
        executeSearch();
        return null;
    }
    
    public PageReference executeSearch(){
        System.debug('im in here!' + nameQuery + offset);
        if (firstCall) {
            offset = 0;
        }
        if(nameQuery == null || nameQuery==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Account Name'));
            isTableExit = false;
        }else{
            accounts=[Select id,name, phone From Account where name like : ('%' +  nameQuery  + '%') Limit :perPage offset :offset];
            if ((accounts.size() < perPage)) {
                hasNext = false;
            }
            if (accounts.size() == 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No search results'));
            }
           
        }
        System.debug(accounts.size());
        
        isTableExit = true;
        return null;
    }
}