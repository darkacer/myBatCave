public with sharing class UtilityClass {
    public UtilityClass() {}
    private static Map<String,Schema.SObjectType> schemaInst = null;
    
    private static Map<String, Schema.SObjectType> getSchemaInstance() {
        if (schemaInst == null) 
            schemaInst = Schema.getGlobalDescribe();
        return schemaInst;
    }

    public static Map<String,Id> getRecordTypeByDevName(String sObjectAPIName) {
        Map<String, Id> recordTypeInfos = new Map<String, Id>();
        for(Schema.RecordTypeInfo recType: getSchemaInstance().get(sObjectAPIName).getDescribe().getRecordTypeInfos()){
            if(recType.isActive()){
                recordTypeInfos.put(recType.getDeveloperName(), recType.getRecordTypeId());
            }
        }
        return recordTypeInfos;
    }
}
