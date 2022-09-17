public with sharing class CloneSObjectDAGUtility {
    
    public static void main(CloneSObjectDAG.WrapperClass wrapperClass) {
        for(CloneSObjectDAG.WrapperClass wap : wrapperClass) {
            if(!wap.hasSelfRelationship) {
                //convertSobjectListToList(wap.records, wap.fieldsToRef);
            }
        }
    }

    private static Map<String, Object> convertSobjectToMap(sObject sObject, Set<String> fieldsToRef) {
        Map<String, Object> map = new Map<String, Object>();
        for(String key : sObject.fields.keySet()) {
            if(sObject.fields.get(key) != null) {
                if(fieldsToRef != null && fieldsToRef.contains(key)) {
                    map.put(key, '@' + sObject.fields.get(key));
                } else {
                    map.put(key, sObject.fields.get(key));
                }
            }
        }
        return map;
    }

    private static List<Object> convertSobjectListToList(List<sObject> sObjectList, Set<String> fieldsToRef) {
        List<Object> list = new List<Object>();
        for(sObject sObject : sObjectList) {
            list.add(convertSobjectToMap(sObject), fieldsToRef);
        }
        return list;
    }

    private static createAttachmentFile(CloneSObjectDAG.WrapperClass wap) {
        String fileName = wap.sObjectName + '.json';


    }


}
