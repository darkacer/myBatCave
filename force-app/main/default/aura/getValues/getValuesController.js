({
	valueupdated : function(component, event, helper) {
		var a = component.find('quoteField').get('v.value');
        var b = component.get("v.firstname");
        alert('hi ' + a);
        console.log(b);
	}
})