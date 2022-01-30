public class JSON_Utility {
    private static Set<String> removeSensitiveKeyValue = new Set<String>{'c', 'secret', 'XML', 'lastName'};
        
        public static void callerMethod() {
            //String bodyArgs = '{"name":"test", "GlossSeeAlso": [{"1": [11, 22, {"secret":"joker", "notsecret":"batman"}]}, "XML"], "ssn":"324234234", "email":"test@mail.com", "array":["1", "2", "4"]}';
            String bodyArgs = '{"firstName":{"key":{"innerKey":["abc", "zyx"]}}, "lastName":"Deokar", "arr":[{"1":["a", "b", {"c": "cat"}]}, "2", "3"]}';
            Object bodyObj = (Object)JSON.deserializeUntyped(bodyArgs);
            /*
            Map<String, Object> mapObj = new Map<String, Object>();
            if (bodyObj instanceof List<Object>){
                List<Object> lstObjs = (List<Object>)JSON.deserializeUntyped(bodyArgs);
                for (Object lstObj : lstObjs){
                    Map<String,Object> parseLstObj = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(lstObj));
                    mapObj.putAll(parseLstObj);
                }
            } else {
                mapObj = (Map<String,Object>)JSON.deserializeUntyped(bodyArgs);
            }
            system.debug('mapObj ' + mapObj);
            */
            // Map<String, String> newMappedValues = new Map<String, String>();
            //System.debug(removeAttributes(mapObj, newMappedValues));
            
            //system.debug(JSON.serialize(removeAttributes(mapObj, newMappedValues)));
            system.debug(removeAttributes(bodyObj));
        }
    
    
    // real method
    public static String removeAttributes(Object jsonObj) {
        String ret = '';
        if(jsonObj instanceof String) {
            ret = JSON.serialize(jsonObj) ;
        } else if(jsonObj instanceof Map<String,Object>) {
            Map<String, String> freshMap = new Map<String, String>();
            Map<String, Object> temp = (Map<String, Object>)jsonObj;
            for(String key : temp.keySet()) {
                if (!removeSensitiveKeyValue.contains(key)){
                    freshMap.put(JSON.serialize(key), removeAttributes(temp.get(key)));
                }
            }
            ret =  String.valueOf(freshMap);
        } else if(jsonObj instanceof List<Object>) {
            List<String> stringList = new List<String>();
            for(Object obj : (List<Object>)jsonObj) {
                stringList.add(removeAttributes(obj));
            }
            ret = '[' + String.join(stringList, ',') + ']';
        }
        ret = ret.replace('\\', '');
        ret = ret.replace('=', ':');
        system.debug('rrrt'+ret);
        return ret;
    }
    
    public static Map<String, String> removeAttributes(Map<String,Object> jsonObj, Map<String, String> mappedKeys)  {
        for(String key : jsonObj.keySet()) {
            if (removeSensitiveKeyValue.contains(key)){
                jsonObj.remove(key);
            } else {
                if(jsonObj.get(key) instanceof Map<String,Object>) {
                    removeAttributes((Map<String,Object>)jsonObj.get(key), mappedKeys);
                } else if(jsonObj.get(key) instanceof List<Object>) {
                    for(Object listItem : (List<Object>)jsonObj.get(key)) {
                        system.debug('listItem ' + listItem);
                        if(listItem instanceof Map<String,Object>)  {
                            removeAttributes((Map<String,Object>)listItem, mappedKeys);
                        }
                    }
                    mappedKeys.put(key, String.valueOf(jsonObj.get(key)));
                } else {
                    mappedKeys.put(key, String.valueOf(jsonObj.get(key)));
                }
            }
        }
        return mappedKeys;
    }
}