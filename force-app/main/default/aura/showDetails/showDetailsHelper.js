({
	handleClickhelper : function(component, event) {
		var _recId = component.get("v.recordId");
        console.log('rec id is ' + _recId);
        
        
        
        var dataAction = component.get('c.getData');
        dataAction.setParams({recId : _recId, message : 'hi'});
        
        dataAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state=='SUCCESS') {
                var retVal = response.getReturnValue();
                console.log('retVal---'+retVal.Age__c);
                component.set('v.motherRecord', retVal)
            } else {
                console.log('error ' + error)
            }
        });
        $A.enqueueAction(dataAction);
	}
})