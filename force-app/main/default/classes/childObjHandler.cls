public class childObjHandler {
    public childObjHandler() {
        
    }
    public static void updateChilds (List<Child__c> newChildList, Map<Id, Child__c> oldMap) {
        Child__c [] newlistChild = new List<Child__c>();
        for (Child__c chld : newChildList) {
            system.debug('hi');
            if (chld.Age__c != oldMap.get(chld.Id).Age__c && chld.Age__c > 10) {
                newlistChild.add(chld);
                //chld.Name = chld.Name + ' oldeer child';
            }
        }
        
        for (Child__c child : newlistChild) {
            child.Name = child.Name + ' oldest child';
        }
    }
}