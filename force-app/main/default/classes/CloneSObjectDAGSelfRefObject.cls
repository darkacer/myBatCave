public class CloneSObjectDAGSelfRefObject {
    private static String timeNow = String.valueOf(System.now()).deleteWhiteSpace();
    private static Id DAG_recordId = '0067F000004qj3uQAA';
    private static String DAG_refObjectName;
    private static string DAG_parentFieldName = 'Parent_Object__c';
    private static Integer DAG_counter = 0;
    private static Map<String, String> childToParentMap = new Map<String, String>();
    private static Map<String, Object> idToRecordMap = new Map<String, Object>();
    
    public static List<Attachment> DAG_main(String str, String parentRefName, Id recId, String refObjName) {
        DAG_recordId = recId;
        DAG_refObjectName = refObjName;
        DAG_parentFieldName = parentRefName;
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(str);
        
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
        
        // level tree travsersal
        List<String> level1 = parentToChildMap.get(null);

        // loop over parent to child map to form jsons
        List<Attachment> attachmentList = new List<Attachment>();

        attachmentList = reccursiveMethod(level1, parentToChildMap, attachmentList);
        
        system.debug('attachmentList.size' +attachmentList.size());
        
        
        
        return attachmentList;
    }
    
    private static String decorateObject(List<String> keyList) {
        List<Object> tempList = new List<Object>();
        for(string refName :keyList) {
            tempList.add(idToRecordMap.get(refName));
        }
        Map<String, Object> tempMap = new Map<String, Object>();
        
        tempMap.put('records', tempList);
        return (String)JSON.serializePretty(tempMap);
    }
    
    private static string getParentRef(Object obj) {
        Map<String, Object> RespObjMap = (map<String, Object>)obj;
        String srt = (String)RespObjMap.get(DAG_parentFieldName);
        return srt?.replace('@', '');
    }
    
    private static string getSelfRef(Object obj) {
        map<String, Object> RespObjMap = (map<String, Object>)obj;
        Object attr = RespObjMap.get('attributes');
        map<String, Object> RespObjMap2 = (map<String, Object>)attr;
        String srt = (String)RespObjMap2.get('referenceId');
        return srt?.replace('@', '');
    }

    public static String generatCounterFileName(Integer DAG_counter, String DAG_refObjectName) {
        return DAG_refObjectName + 'part'+ DAG_counter++ + '-' + timeNow +'.json';
    }

    private static List<Attachment> reccursiveMethod(List<String> childs, Map<String, List<String>> parentToChildMap, List<Attachment> attachmentList) {
        System.debug('childs ' + childs);
        System.debug('parentToChildMap ' + parentToChildMap);
        
        Attachment tempattachment = new Attachment();
        tempattachment.ParentId = DAG_recordId;
        tempattachment.Name = generatCounterFileName(DAG_counter++, DAG_refObjectName);
        tempattachment.Body = Blob.valueOf(decorateObject(childs));
        attachmentList.add(tempattachment);

        List<String> newchildsList = getChilds(childs, parentToChildMap);
        if(newchildsList.size() > 0) {
            reccursiveMethod(newchildsList, parentToChildMap, attachmentList);
        }
        return attachmentList;   
    }

    private static List<String> getChilds(List<String> keys, Map<String, List<String>> parentToChildMap) {
        List<String> childs = new List<String>();
        for(String key :keys) {
            if(parentToChildMap.containsKey(key)) {
                childs.addAll(parentToChildMap.get(key));
            }
        }
        return childs;
    }
}
