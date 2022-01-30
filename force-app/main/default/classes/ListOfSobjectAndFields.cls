public class ListOfSobjectAndFields {
	
    private static Map<String, String> sObjectNameToApiName = new Map<String, String>();
    private static Map<String, Map<String, String>> sObjectApiNameTo_FieldLabelToApiName = new Map<String, Map<String, String>>();
    
    private static List<String> sObjectNameAndFieldName_label = new List<String>{
        'Account,Account Name', 'Discount Tier,Tier Name', 'Mother,Daughters'
    };
    
    public static void main() {
        populatesObjectNameToApiName();
        
        for(String str : sObjectNameAndFieldName_label) {
            List<String> l = str.split(',');
            String sObjApiName = getSobjectApiNameFromLabel(l[0]);
            String fieldLabelName = l[1];
            if(!fullMapHas(sObjApiName)) {
                updateFullMap(sObjApiName);
            }
            String fieldApiName = sObjectApiNameTo_FieldLabelToApiName.get(sObjApiName).get(fieldLabelName);
            System.debug(sObjApiName + ',' + l[0] + ',' +  fieldApiName + ',' + fieldLabelName);
        }
    }
    
    public static Map<String, String> populatesObjectNameToApiName() {
        map<String, SObjectType> objs = Schema.getGlobalDescribe();
        for(String key: objs.keySet()){
            sObjectNameToApiName.put(objs.get(key).getDescribe().getLabel(), key);
        }
        return sObjectNameToApiName;
    }
    
    private static String getSobjectApiNameFromLabel(String sObjectLabel) {
        return sObjectNameToApiName.get(sObjectLabel);
    }
    
    private static Boolean fullMapHas(String sObjectApiName) {
        return sObjectApiNameTo_FieldLabelToApiName.containsKey(sObjectApiName);
    }
    
    private static void updateFullMap(String sObjectApiName) {
        // if() return;
        Map<String, String> fieldsMap = new Map<String, String>();
        Map<string,SObjectField> fList = schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();
        for(string str: fList.keySet()){
            fieldsMap.put(fList.get(str).getDescribe().getLabel(), str);
        }
        //system.debug('updating map for ' + sObjectApiName + fieldsMap);
        sObjectApiNameTo_FieldLabelToApiName.put(sObjectApiName, fieldsMap);
    }
}