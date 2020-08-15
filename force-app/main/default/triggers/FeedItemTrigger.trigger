trigger FeedItemTrigger on FeedItem (after insert) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            FeedItemTriggerHandler.updateAccountChatterPost(Trigger.new);
        }
        when else {
            
        }
    }
}