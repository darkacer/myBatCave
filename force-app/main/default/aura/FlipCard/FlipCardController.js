({
	handleClick : function(component, event, helper) {
		component.set("v.Name", "hehehehe");
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
		console.log(id_str);
        component.set("v.Name", id_str);
	}
})