@isTest
public with sharing class ConnectApiHandlerTest {

    @IsTest(SeeAllData=true)
    static void createInputFromBodyTest() {
    
        // We'll post a feed item that contains text, link, hashtag, mention, and markup segments, 
        // and then call the helper method on the resulting body.

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        // We can put the link and hashtag parts into a text segment to post the feed item. When it gets retrieved, it will have
        // separate segments for the text, link and hashtag.
        String expectedText = 'Text ';
        String expectedLink = 'http://link.com';
        String expectedHashtag = 'hashtag';
        String expectedBoldText = 'Bold text';

        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = expectedText + expectedLink + ' #' + expectedHashtag;
        messageBodyInput.messageSegments.add(textSegmentInput);

        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = UserInfo.getUserId();
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegmentInput.markupType = ConnectApi.MarkupType.Bold;
        messageBodyInput.messageSegments.add(markupBeginSegmentInput);
        
        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = expectedBoldText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        ConnectApi.MarkupEndSegmentInput markupEndSegmentInput = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegmentInput.markupType = ConnectApi.MarkupType.Bold;
        messageBodyInput.messageSegments.add(markupEndSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = UserInfo.getUserId();

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        
        ConnectApi.MessageBodyInput input = ConnectApiHandler.createInputFromBody(feedElement.body);
        System.assertEquals(8, input.messageSegments.size(), 'Wrong number of message segments.');

        System.assert(input.messageSegments.get(0) instanceof ConnectApi.TextSegmentInput, 'Segment 0 is not a text segment input.');
        ConnectApi.TextSegmentInput textInput = (ConnectApi.TextSegmentInput) input.messageSegments.get(0);
        System.assertEquals(expectedText, textInput.text, 'Segment 0 text does not match.');

        System.assert(input.messageSegments.get(1) instanceof ConnectApi.LinkSegmentInput, 'Segment 1 is not a link segment input.');
        ConnectApi.LinkSegmentInput linkInput = (ConnectApi.LinkSegmentInput) input.messageSegments.get(1);
        System.assertEquals(expectedLink, linkInput.url, 'Segment 1 url does not match.');

        System.assert(input.messageSegments.get(2) instanceof ConnectApi.TextSegmentInput, 'Segment 2 is not a text segment input.');
        ConnectApi.TextSegmentInput textInput2 = (ConnectApi.TextSegmentInput) input.messageSegments.get(2);
        System.assertEquals(' ', textInput2.text, 'Segment 2 text does not match.');

        System.assert(input.messageSegments.get(3) instanceof ConnectApi.HashtagSegmentInput, 'Segment 3 is not a hashtag segment input.');
        ConnectApi.HashtagSegmentInput hashtagInput = (ConnectApi.HashtagSegmentInput) input.messageSegments.get(3);
        System.assertEquals(expectedHashtag, hashtagInput.tag, 'Segment 3 hashtag does not match.');

        System.assert(input.messageSegments.get(4) instanceof ConnectApi.MentionSegmentInput, 'Segment 4 is not a mention segment input.');
        ConnectApi.MentionSegmentInput mentionInput = (ConnectApi.MentionSegmentInput) input.messageSegments.get(4);
        System.assertEquals(UserInfo.getUserId(), mentionInput.id, 'Segment 4 mention ID does not match.');

        System.assert(input.messageSegments.get(5) instanceof ConnectApi.MarkupBeginSegmentInput, 'Segment 5 is not a markup begin segment input.');
        ConnectApi.MarkupBeginSegmentInput markupBeginInput = (ConnectApi.MarkupBeginSegmentInput) input.messageSegments.get(5);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupBeginInput.markupType, 'Segment 5 markup type does not match.');

        System.assert(input.messageSegments.get(6) instanceof ConnectApi.TextSegmentInput, 'Segment 6 is not a text segment input.');
        ConnectApi.TextSegmentInput textInput3 = (ConnectApi.TextSegmentInput) input.messageSegments.get(6);
        System.assertEquals(expectedBoldText, textInput3.text, 'Segment 6 text does not match.');

        System.assert(input.messageSegments.get(7) instanceof ConnectApi.MarkupEndSegmentInput, 'Segment 7 is not a markup end segment input.');
        ConnectApi.MarkupEndSegmentInput markupEndInput = (ConnectApi.MarkupEndSegmentInput) input.messageSegments.get(7);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupEndInput.markupType, 'Segment 7 markup type does not match.');

        // Get coverage for the createFeedItemInputFromBody() method.
        ConnectApi.FeedItemInput feedItemInput2 = ConnectApiHandler.createFeedItemInputFromBody(feedElement.body);
        System.assertEquals(input, feedItemInput2.body, 'createFeedItemInputFromBody is returning a different input body than createInputFromBody.');
        
        ConnectApiHandler.addHtmlTagAround(input, ConnectApi.MarkupType.Bold, 'innerText');
    }
}
