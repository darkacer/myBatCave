({
	openActionWindow : function(component, event, helper) {
		window.open("https://www.w3schools.com");
	},
    
    
    doInit: function(cmp) {
        var id = cmp.get("v.recordId");
        //cmp.set("v.setMeOnInit", id);
        //alert('hello');
        //var c = new sforce.SObject("Opportunity");
        alert('this ' + id);
        console.log('fisys');
        var action = cmp.get("c.getOppDetails");
        action.setParams({
            "id" : id
        });
       console.log('helosy');
        
        action.setCallback(this, function(response){
       		var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var resp = response.getReturnValue();
            	cmp.set("v.setMeOnInit", resp[1]);
               	console.log(resp + 'sd');
                window.open("/lightning/r/Opportunity/{!Opportunity.Id}/view");
        	}
            else {
            	console.log("Failed with state: " + state);
        	}
        });
        $A.enqueueAction(action);
        
    },
    
    
    handleClick : function(component, event, helper) {
        var id = component.get("v.recordId");
        var finalvalue = "/apex/AccountList?id=" + id;
        alert(finalvalue);
        component.set('v.srcvalue',finalvalue);
		
	}
    
    
    
    
    
    
    
    
    
    
    
    
    
})