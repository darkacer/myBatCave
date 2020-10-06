trigger customObjTrigger on CustomObj__c (before insert, before update) {
    Map<String, LookupName__c> api_names = LookupName__c.getAll();  // get custom setting values of Lookupname 
    set<String> unames = api_names.keyset();            // throw them in a key set
    
    Map<Id, Id> mymap = new Map<Id, Id>();              // id-id map
    Map<Id, String> usermap = new Map<Id, String>();    // id-String map
    List<Id> userIds = new List<Id>();                  // list to catch userids so to qurey further
    
                                                        // loop on the keyset so that all fields are gone through
    for(String uname : unames) {
                                                        // uname for user field apiname 
                                                        // emailAPI for user field apiname
        String emailAPI = api_names.get(uname).Email_Api_name__c;
        Integer count = 0;
        userIds.clear();
        usermap.clear();
        mymap.clear();
        
        Id usid;
        if (Trigger.isUpdate) {
            for (CustomObj__c mylis :  Trigger.Old) {
                usid = (Id)mylis.get(uname);
                mymap.put(mylis.Id, usid);
                userIds.add(usid);
            }
        }
        else if (Trigger.isInsert) {
            for (CustomObj__c mylis :  Trigger.New) {
                usid = (Id)mylis.get(uname);
                mymap.put(mylis.Id, usid);
                userIds.add(usid);
            }
        }
        
        List<User> users = new List<User>();
        if (userids.size() != 0) {
            users = [select id, Email from User where Id in :userIds];   // DML query
        }
        
        for (User us : users) {
            usermap.put(users[count].id, users[count].Email);
            count++;
        }
        
        for (CustomObj__c mylis :  Trigger.New) {
            mylis.put(emailAPI, usermap.get(mymap.get(mylis.Id)));
        }
    }
}