({
	update : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
	}
    
    
    //$A.get("e.force:closeQuickAction").fire() to close thelightning quick action modal dialog

})