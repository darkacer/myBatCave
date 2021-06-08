({
    init : function(component, event, helper) {
        helper.createChild(component, event, helper);
    },
    recordUpdated: function(component, event, helper) {
        var isChanged = component.get('v.isChanged');
        var changeType = event.getParams().changeType;
        if (changeType === "CHANGED") {
            component.set('v.isChanged', true);
            component.find("forceRecord").reloadRecord();
        }
        if (changeType === "LOADED" && isChanged) {
            component.set('v.isChanged', false);
            var childCmp = component.find("childComp");
            childCmp.destroy();
            helper.createChild(component, event, helper);
        }
    }
})