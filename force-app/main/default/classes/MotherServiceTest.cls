@isTest
public class MotherServiceTest {
    private class MotherServiceMock implements IMotherService {
        
        private List<Mother__c> returnedMother;
        
        private MotherServiceMock mockGetMother(List<Mother__c> returnedMothers) {
            this.returnedMother = returnedMothers;
            return this;
        }
        
        public List<Mother__c> getMother() {
            return returnedMother;
        }
        
        public List<Mother__c> olderMothers(Integer myNum) {
            return returnedMother;
        }
    }
    
    @isTest
    private static void getMother_MothersExist() {
        MotherServiceMock mockMotherService = new MotherServiceMock().mockGetMother(new List<Mother__c> { 
            new Mother__c(Name = 'new Mother') 
        });
        Test.startTest();
        	MotherController mc = new MotherController(mockMotherService);
        	List<Mother__c> result = mc.getMother();
        	List<Mother__c> result2 = new MotherController(mockMotherService).olderMothers(45);
        
        //List<Mother__c> resoult = MotherController.getMotherRecords()
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
}