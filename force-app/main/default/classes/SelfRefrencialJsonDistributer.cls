/*
 * aim of this class is to break the given json in tree fashion 
*/
public class SelfRefrencialJsonDistributer {
    private static Id recordId = '0067F00000knKkOQAU';
    private static string parentFieldName = 'Parent_Object__c';
    
    private static Map<String, String> childToParentMap = new Map<String, String>();
    private static Map<String, Object> idToRecordMap = new Map<String, Object>();
    
    public static void main() {
        list<Attachment> Attchmentslist = [select name,id,Body from Attachment where ParentId =: recordId];
        string str = JSON.serialize(Attchmentslist[0].body.toString());
        system.debug('str after= ' + str);
        //str = str.replace('\\"', '"');

        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(Attchmentslist[0].body.toString());
        system.debug('map ' + m.get('records'));
        for(object obj : (List<object>)m.get('records')) {
            system.debug('obj ' + obj);
            String selfId = getSelfRef(obj);
            String parentId = getParentRef(obj);
            childToParentMap.put(selfId, parentId);
            idToRecordMap.put(selfId, obj);
        }
        
        
        system.debug('child to parent Map ' + childToParentMap);
        
        Map<String, List<String>> parentToChildMap = new Map<String, List<String>>();
        
        
        for(String key : childToParentMap.keySet()) {
            String parent = childToParentMap.get(key);
            if(!parentToChildMap.containsKey(parent))
                parentToChildMap.put(parent, new List<String>());
            parentToChildMap.get(parent).add(key);
        }
        for(String key :parentToChildMap.keyset()) {
            system.debug(key + ' = ' + parentToChildMap.get(key));
        }
        system.debug(parentToChildMap.get(null));
        
        List<String> orderForPlan = new List<String>();
        List<String> orderForPlanTemp = parentToChildMap.get(null);
        
        while(!orderForPlanTemp.isEmpty()) {
            orderForPlan.add(orderForPlanTemp[0]);
            orderForPlanTemp.remove(0);
        }
        
        
        
        
        // looop over parent to child map to form jsons
        List<Attachment> attachmentList = new List<Attachment>();
        Integer counter = 1;
        Attachment attachment = new Attachment();
        attachment.ParentId = recordId;
        attachment.Name = 'part'+counter+'.json';
        attachment.Body = Blob.valueOf(decorateObject(parentToChildMap.get(null)));
        attachmentList.add(attachment);
        for(String key :parentToChildMap.keyset()) {
            if(key != null) {
                counter++;
                Attachment tempattachment = new Attachment();
                tempattachment.ParentId = recordId;
                tempattachment.Name = 'part'+counter+'.json';
                tempattachment.Body = Blob.valueOf(decorateObject(parentToChildMap.get(key)));
                attachmentList.add(tempattachment);
            }
        }
        
        system.debug('attachmentList.size' +attachmentList.size());
        
        
        
        insert attachmentList;
    }
    
    private static String decorateObject(List<String> keyList) {
        List<Object> tempList = new List<Object>();
        for(string refName :keyList) {
            tempList.add(idToRecordMap.get(refName));
        }
        Map<String, Object> tempMap = new Map<String, Object>();
        
        tempMap.put('records', tempList);
        return (String)JSON.serialize(tempMap);
    }
    
    private static string getParentRef(Object obj) {
        map<String, Object> RespObjMap = (map<String, Object>)obj;
        String srt = (String)RespObjMap.get(parentFieldName);
        return srt?.replace('@', '');
    }
    
    private static string getSelfRef(Object obj) {
        map<String, Object> RespObjMap = (map<String, Object>)obj;
        Object attr = RespObjMap.get('attributes');
        map<String, Object> RespObjMap2 = (map<String, Object>)attr;
        String srt = (String)RespObjMap2.get('referenceId');
        return srt?.replace('@', '');
    }
}