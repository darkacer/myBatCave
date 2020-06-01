public class MotherController {
    private IMotherService motherSerivce;
    
    // constructor
    public MotherController(IMotherService motherSerivce) {
        this.motherSerivce = motherSerivce;
    }
    
    // Constructor 2
    public MotherController() {
        IMotherService motherSerivce;
        this.motherSerivce = motherSerivce;
    }
    
    @auraEnabled
    public List<Mother__c> getMother() {
        return this.motherSerivce.getMother();
    }
    
    
    public List<Mother__c> olderMothers(Integer ageOfPerson) {
        return this.motherSerivce.olderMothers(ageOfPerson);
    }
    
    @auraEnabled
    public static List<Mother__c> getMotherRecords() {
        IMotherService motherSerivce;
        return motherSerivce.getMother();
    }
    

}