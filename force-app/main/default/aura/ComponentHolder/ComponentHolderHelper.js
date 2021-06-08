({
    createChild : function(component, event, helper) {
        $A.createComponent(
            "c:FlowHolder",
            {
                "recordId" : component.get('v.recordId'),
                "flowName" : component.get('v.flowName'),
                "aura:id" : "childComp"
            }, function(newCmp, status, error) {
                if(status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                } else {
                    console.log('im failure ' +error)
                }
            }
        )
    }
})