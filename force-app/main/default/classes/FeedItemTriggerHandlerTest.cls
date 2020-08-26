@isTest
public with sharing class FeedItemTriggerHandlerTest {
    public FeedItemTriggerHandlerTest() {}


    @IsTest(SeeAllData = true)
    static void updateAccountChatterPostTest() {
        Account myAccount = [Select Id From Account Limit 1];

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        String expectedText = 'Text ';

        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = expectedText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = myAccount.Id;

        Test.startTest();
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        Test.stopTest();
    }
}
