public with sharing class ConnectApiHandler {
    public ConnectApiHandler() {

    }

    public static ConnectApi.FeedItemInput createFeedItemInputFromBody(ConnectApi.FeedBody body) {
        ConnectApi.MessageBodyInput bodyInput = createInputFromBody(body);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = bodyInput;
        return input;
    }

    public static void addHtmlTagAround(ConnectApi.MessageBodyInput messageInput, ConnectApi.MarkupType tagName, String innerText) {
        addstartHtmlTag(messageInput, tagName);
        addText(messageInput, innerText);
        addEndHtmlTag(messageInput, tagName);
    }
    
    public static void addText(ConnectApi.MessageBodyInput messageInput, String innerText) {
        ConnectApi.TextSegmentInput textSegment;
        textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = innerText;
        messageInput.messageSegments.add(textSegment);
    }
    
    public static void addStartHtmlTag(ConnectApi.MessageBodyInput messageInput, ConnectApi.MarkupType tagName) {
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = tagName;
        messageInput.messageSegments.add(markupBeginSegment);
    }

    public static void addEndHtmlTag(ConnectApi.MessageBodyInput messageInput, ConnectApi.MarkupType tagName) {
        ConnectApi.MarkupEndSegmentInput markupEndSegment;
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegment.markupType = tagName;
        messageInput.messageSegments.add(markupEndSegment);
    }

    public static ConnectApi.MessageBodyInput createInputFromBody(ConnectApi.FeedBody body) {
        ConnectApi.MessageBodyInput input = new ConnectApi.MessageBodyInput();
        input.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        for (ConnectApi.MessageSegment segment : body.messageSegments) {
            if (segment instanceof ConnectApi.TextSegment) {
                ConnectApi.TextSegment textOutput = (ConnectApi.TextSegment) segment;
                ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
                textInput.text = textOutput.text;
                input.messageSegments.add(textInput);
            }
            else if (segment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionOutput = (ConnectApi.MentionSegment) segment;
                ConnectApi.MentionSegmentInput mentionInput = new ConnectApi.MentionSegmentInput();
                mentionInput.id = mentionOutput.record.id;
                input.messageSegments.add(mentionInput);
            }
            else if (segment instanceof ConnectApi.HashtagSegment) {
                ConnectApi.HashtagSegment hashtagOutput = (ConnectApi.HashtagSegment) segment;
                ConnectApi.HashtagSegmentInput hashtagInput = new ConnectApi.HashtagSegmentInput();
                hashtagInput.tag = hashtagOutput.tag;
                input.messageSegments.add(hashtagInput);
            }
            else if (segment instanceof ConnectApi.LinkSegment) {
                ConnectApi.LinkSegment linkOutput = (ConnectApi.LinkSegment) segment;
                ConnectApi.LinkSegmentInput linkInput = new ConnectApi.LinkSegmentInput();
                linkInput.url = linkOutput.url;
                input.messageSegments.add(linkInput);
            }
            else if (segment instanceof ConnectApi.MarkupBeginSegment) {
                ConnectApi.MarkupBeginSegment markupBeginOutput = (ConnectApi.MarkupBeginSegment) segment;
                ConnectApi.MarkupBeginSegmentInput markupBeginInput = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginInput.markupType = markupBeginOutput.markupType;
                input.messageSegments.add(markupBeginInput);
            }
            else if (segment instanceof ConnectApi.MarkupEndSegment) {
                ConnectApi.MarkupEndSegment markupEndOutput = (ConnectApi.MarkupEndSegment) segment;
                ConnectApi.MarkupEndSegmentInput markupEndInput = new ConnectApi.MarkupEndSegmentInput();
                markupEndInput.markupType = markupEndOutput.markupType;
                input.messageSegments.add(markupEndInput);
            }
            else if (segment instanceof ConnectApi.InlineImageSegment) {
                ConnectApi.InlineImageSegment inlineImageOutput = (ConnectApi.InlineImageSegment) segment;
                ConnectApi.InlineImageSegmentInput inlineImageInput = new ConnectApi.InlineImageSegmentInput();
                inlineImageInput.fileId = inlineImageOutput.thumbnails.fileId;
                inlineImageInput.altText = inlineImageOutput.altText;
                input.messageSegments.add(inlineImageInput);
            }
            else {
                // The other segment types are system-generated and have no corresponding input types.
            }
        }
        return input;
    }
}