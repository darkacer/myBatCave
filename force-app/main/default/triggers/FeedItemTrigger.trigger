trigger FeedItemTrigger on FeedItem (after insert) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            FeedItemTriggerHandler.updateRRName(Trigger.new);
        }
        when else {
            
        }
    }
}