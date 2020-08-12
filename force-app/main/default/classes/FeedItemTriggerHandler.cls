public with sharing class FeedItemTriggerHandler {
    public FeedItemTriggerHandler() {}
    
    public static void updateRRName(List<FeedItem> newList) {
        EditFeedItemHelper.edit(newList);
    }
}
