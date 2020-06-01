public with sharing class MySearchClass {
    public Boolean isTableExit {get;set;}
    public Integer offset {get;set;}
    public String nameQuery{get;set;}
    public mySearchClass() {
        isTableExit = false;
    }
    
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con.setPageSize(15);
                //comment here this is new HSJDKFHKS THIS IS NEW MORE this 
            }
            return con;
        }
        set;
    }
    public List<Contact> getContacts() {
        return (List<Contact>) con.getRecords();
    }
    
    public PageReference execute() {  
        con = new ApexPages.StandardSetController(Database.getQueryLocator([Select FirstName, LastName FROM Contact where FirstName like : ('%' +  nameQuery  + '%') ]));
        if (con.getRecords().size() == 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No search results'));
        }
        else {
            isTableExit = true;
        }
        return null;
    }
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    public void first() {
        con.first();
    }
    public void last() {
        con.last();
    }
    public void previous() {
        con.previous();
    }
    public void next() {
        con.next();
    }
    public void cancel() {
        isTableExit = false;
        con.cancel();
    }
}