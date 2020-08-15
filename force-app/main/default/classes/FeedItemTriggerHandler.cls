public with sharing class FeedItemTriggerHandler {
    public FeedItemTriggerHandler() {}
    
    public static void updateAccountChatterPost(List<FeedItem> newList) {
        Map<Id, Account> feedIdToAccountMap = new Map<Id, Account>();
        Set<Id> accountIdSet = new Set<Id>();
        if (Trigger.isAfter) {
            for (FeedItem fi : newList) {
                if (fi.ParentId.getSObjectType().getDescribe().getName() == 'Account') 
                    accountIdSet.add(fi.ParentId);
            }

            if (accountIdSet.isEmpty()) return;

            Map<Id, Account> idToAccountMap = new Map<Id, Account>([
                Select Id, Name 
                From Account
                Where Id in :accountIdSet
            ]);

            for(FeedItem fi : newList) {
                if (idToAccountMap.containsKey(fi.ParentId))
                feedIdToAccountMap.put(fi.id, idToAccountMap.get(fi.ParentId));
            }

            EditFeedItemHelper.ModifyAccount modifyAccount = new EditFeedItemHelper.ModifyAccount(feedIdToAccountMap);
            EditFeedItemHelper.edit(newList, modifyAccount);
        }
    }
}