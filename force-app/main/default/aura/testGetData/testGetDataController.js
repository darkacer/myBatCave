({
	doInit : function(component, event) {
        console.log('inside init getData');
        var recId = component.get("v.recordId");
		var dataAction = component.get('c.getDetails');
        dataAction.setParams({accountId : recId});
        dataAction.setCallback(this, function(response){
            var state = response.getState();
            if(state=='SUCCESS')
            {
                var retVal = response.getReturnValue();
                console.log('retVal---'+retVal.Name);
                component.set("v.account",retVal);
            }
            
        });
		$A.enqueueAction(dataAction);        
	},
    
    handleChange : function(component, event, helper) {
        var value = component.get('v.number');
        console.log('hi im ' +value);
        value = parseInt(value) + parseInt(10);
        
        component.set('v.number', value);
        
    }
})