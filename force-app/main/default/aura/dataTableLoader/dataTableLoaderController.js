({
	init : function(component, event, helper) {
		console.log('hello');
		var action = component.get("c.getContacts");
        //var 
        component.set("v.columns", [
            {label: 'Name', fieldName: 'linkName', type: 'url', 
            		typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {type:"text",label:"Phone",fieldName:"Phone"}]);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('heyyyy!!!');
            if (state === "SUCCESS") {
                //component.set("v.contact", response.getReturnValue());
                var records = response.getReturnValue();
                
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                
                component.set("v.data", records);
                component.set("v.filteredData", records);
            }
         });
         $A.enqueueAction(action); 
	},
    
    filter: function(component, event, helper) {
    	console.log('hit!');
        
        var data = component.get("v.data"),
            term = component.get("v.filter"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.Name) );
        } catch(e) {
            // invalid regex, use full list
        }
        console.log(results);
        results.splice(20, results.length - 20);
        component.set("v.filteredData", results);
	}
})