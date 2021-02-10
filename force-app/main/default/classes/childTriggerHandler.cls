public class childTriggerHandler extends triggerHandler{
    private List<child__c> triggerNew;
    private List<child__c> triggerOld;
    private Map<Id, child__c> triggerMapNew;
    private Map<Id, child__c> triggerMapOld;
    /**
     * @description Constructor that sets class variables based on Trigger
     * context vars
     */
    public ChildTriggerHandler() {
        this.triggerOld = (List<child__c>) Trigger.old;
        this.triggerNew = (List<child__c>) Trigger.new;
        this.triggerMapNew = (Map<Id, child__c>) Trigger.newMap;
        this.triggerMapOld = (Map<Id, child__c>) Trigger.oldMap;
    }

    /**
     * @description Custom exception class
     */
    public class ChildTriggerHandlerException extends Exception {
    }

    public override void afterInsert() {
        this.updateMotherData(this.triggerNew);
    }

    public override void afterUpdate(){
        this.checkIfMotherDataIsToBeUpdated();
    }





    private void checkIfMotherDataIsToBeUpdated() {
        Set<Id> motherIdSet = new Set<Id>();
        for(child__c child : this.triggerNew) {
            if(
                child.Mother__c != this.triggerMapOld.get(child.Id).Mother__c
                || child.Gender__c != this.triggerMapOld.get(child.Id).Gender__c
            ) {
                motherIdSet.add(child.Mother__c);
                motherIdSet.add(this.triggerMapOld.get(child.Id).Mother__c);
            }
        }
        this.updateMotherData(motherIdSet);
    }

    
    private void updateMotherData(List<Child__c> childRecords) {
        Set<Id> motherIdSet = new Set<Id>();
        for(Child__c child : childRecords) {
            if(child.Mother__c != null) {
                motherIdSet.add(child.Mother__c);
            }
        }
        this.updateMotherData(motherIdSet);
    }

    private void updateMotherData(Set<Id> motherIdSet) {
        motherServiceLayer.updateMotherCount(motherIdSet);
    }

    


}
