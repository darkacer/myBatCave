({
    generateStructure : function(array, helper) {
        let finalStructure = {}
		let parentToChildMap = new Map();
        let childToParentMap = new Map();
        let ultimateParent = '';
        array.forEach(el => {
            console.log('el is ', el);
            if(el.hasOwnProperty('custom_parent__c')) {
            	childToParentMap.set(el.Id, el.custom_parent__c);
            	if(!parentToChildMap.has(el.custom_parent__c)) parentToChildMap.set(el.custom_parent__c, []);
            	parentToChildMap.get(el.custom_parent__c).push(el.Id)
            } else {
                ultimateParent = el.Id;
            }
            
            
        })
        console.log('parentToChildMap', parentToChildMap)
        parentToChildMap.get()
        
    }
})