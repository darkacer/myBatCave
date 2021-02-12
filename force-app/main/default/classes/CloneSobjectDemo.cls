public class CloneSobjectDemo {
    public static void demo() {
        
        List<Account> accList = [Select Id, name, description from Account Where name = 'Edge Communications'];
        List<Contact> conList = [Select Id, account.name,account.description, lastname from contact where Accountid = :accList[0].Id];
        List<Opportunity> oppList = [Select Id, name, Amount, CloseDate, AccountId, StageName From Opportunity Where Accountid = :accList[0].Id];
        
        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapContact = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'AccountId' => new CloneSObjects.ReturnParentFieldFromTemplate('AccountId')
        };
            
        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapOpp = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'AccountId' => new CloneSObjects.ReturnParentFieldFromTemplate('AccountId')
        };

        new CloneSObjects()
            .cloneSobjectsFrom(accList, null, true)
            .cloneSobjectsFrom(conList, overRideMapContact, true)
            .cloneSobjectsFrom(oppList, overRideMapOpp, true);
        
    }
}