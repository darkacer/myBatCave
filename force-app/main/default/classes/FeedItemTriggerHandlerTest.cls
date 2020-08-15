@isTest
public with sharing class FeedItemTriggerHandlerTest {
    public FeedItemTriggerHandlerTest() {}

    User contextuser;
    @TestSetup
    static void makeData(){
        // this.contextuser = [Select id from User where Profile.name = 'System Admin'];
    }


    @IsTest
    static void methodName(){
        
        Test.startTest();
        
        Test.stopTest();
        
    }
}
