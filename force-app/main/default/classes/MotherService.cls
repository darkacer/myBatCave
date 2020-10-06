public class MotherService implements IMotherService {
    public List<Mother__c> getMother() {
        return [Select Id, Name From Mother__c Limit 5];
    }
    
    public List<Mother__c> olderMothers(Integer ageNum) {
        return [Select Id, Name, Age__c From Mother__c Where Age__c > :ageNum];
    }
    
    
}