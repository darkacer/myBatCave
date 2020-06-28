public interface IMotherService {
	List<Mother__c> getMother();
    List<Mother__c> olderMothers(Integer agenum);
}