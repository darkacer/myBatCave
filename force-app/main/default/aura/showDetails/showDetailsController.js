({
    myAction : function(component, event, helper) {
        
        
        var mynum = component.get('v.myMumber');
        
        console.log('hi im invoked' + mynum);
        
    },
    
    doInit : function(component, event, helper) {
        console.log('hi im triggered!!!!');
    },
    
    handleClick : function(component, event, helper) {
        
        helper.handleClickhelper(component, event);
        
        
    }
    
    
    
})