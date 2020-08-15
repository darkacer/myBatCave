public class EditFeedItemHelper {
    /**
* Call this method from an after insert FeedItem trigger.
* It updates the feed items passed in and preserves @mentions.
*/
    
    public static void edit(FeedItem[] feedItems, ModifyInterface modifyObject) {
        String communityId = Network.getNetworkId();
        List<String> feedItemIds = new List<String>();
        for (FeedItem f : feedItems) {
            feedItemIds.add(f.id);
        }
        
        ConnectApi.BatchResult[] results = ConnectApi.ChatterFeeds.getFeedElementBatch(communityId, feedItemIds);
        
        for (ConnectApi.BatchResult result : results) {
            if (result.isSuccess()) {
                Object theResult = result.getResult();
                
                if (theResult instanceof ConnectApi.FeedItem) {
                    ConnectApi.FeedItem item = (ConnectApi.FeedItem) theResult;
                    System.debug('initial body => ' + item.body);
                    ConnectApi.FeedItemInput input = ConnectApiHandler.createFeedItemInputFromBody(item.body);
                    if (modifyObject != null) modifyObject.modifyInput(input, item.Id);
                    System.debug('input => ' + input);
                    ConnectApi.ChatterFeeds.updateFeedElement(communityId, item.id, input);
                } 
            }
            else {
                System.debug('Failure in batch feed element retrieval: ' + result.getErrorMessage());
            }
        }
    }

    public interface ModifyInterface {
        void modifyInput(ConnectApi.FeedItemInput input, Id feedId);
    }

    public class ModifyAccount implements ModifyInterface{
        Map<Id,Account> idToRecordMap;

        // constructor for preset id to rec map for account names
        public ModifyAccount(Map<Id,Account> idToRecordMap) {
            this.idToRecordMap = idToRecordMap;
        }

        public void modifyInput(ConnectApi.FeedItemInput input, Id feedId) {
            Account tempObj = this.idToRecordMap.get(feedId);
            ConnectApiHandler.addStartHtmlTag(input.body, ConnectApi.MarkupType.Paragraph);
            	ConnectApiHandler.addHtmlTagAround(input.body, ConnectApi.MarkupType.Bold, 'Account Name: ');
            	ConnectApiHandler.addText(input.body, tempObj.name);
            ConnectApiHandler.addEndHtmlTag(input.body, ConnectApi.MarkupType.Paragraph);
        }
    }
}