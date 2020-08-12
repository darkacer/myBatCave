public class EditFeedItemHelper {
 
    /**
   
    * Call this method from an after insert FeedItem trigger.
   
    * It updates the feed items passed in and preserves @mentions.
   
  */
   
    public static void edit(FeedItem[] feedItems) {
   
      String communityId = Network.getNetworkId();
   
      List<String> feedItemIds = new List<String>();
   
      for (FeedItem f : feedItems) {
   
          feedItemIds.add(f.id);
   
      }
   
          // Get all feed items passed into the trigger (Step #1).
   
      ConnectApi.BatchResult[] results = ConnectApi.ChatterFeeds.getFeedElementBatch(communityId, feedItemIds);
   
      for (ConnectApi.BatchResult result : results) {
   
          if (result.isSuccess()) {
   
              Object theResult = result.getResult();
   
              if (theResult instanceof ConnectApi.FeedItem) {
   
                  ConnectApi.FeedItem item = (ConnectApi.FeedItem) theResult;
   
                  // Convert message segments into input segments (Step #2a).
   
                  ConnectApi.FeedItemInput input = ConnectApiHandler.createFeedItemInputFromBody(item.body);
   
                  // Modify the input segments as you see fit (Step #2b).
   
                  modifyInput(input);
   
                  // Update the feed item (Step #2c).
   
                  // We need to update one feed item at a time because there isn't a batch update method yet.
   
                  ConnectApi.ChatterFeeds.updateFeedElement(communityId, item.id, input);
   
              }
   
              else {
   
                  // Do nothing. Posting other feed element types isn't supported.
   
              }
   
          }
   
          else {
   
                  System.debug('Failure in batch feed element retrieval: ' + result.getErrorMessage());
   
          }
   
      }
   
  }
   
      /**
   
      * Update the feed item input here!
   
      */
   
      public static void modifyInput(ConnectApi.FeedItemInput input) {
   
          // This example appends text to the feed item.
   
          ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
   
          textInput.text = 'nn---nDisclaimer: Modified in a trigger.';
   
          input.body.messageSegments.add(textInput);
   
      }
   
  }