System.debug('hi myname');
List<Contact> listName = [Select id, name, picture__c from Contact limit 2];
System.debug(listName);

String type='Contact';
Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
Schema.SObjectType leadSchema = schemaMap.get(type);
Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
for (String fieldName: fieldMap.keySet()) {
    String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
    Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
    System.debug(fieldName + ' => ' + fielddataType);
}

public static String getDataType(String objectApi, String fieldName) {
    return String.valueOf(Schema.getGlobalDescribe()
                .get(objectApi).getDescribe().fields.getMap()
                .get(fieldName).getDescribe().getType());
}
System.debug(getDataType('Contact', 'picture__c'));

System.debug('out ' + UtilityClass.getRecordTypeByDevName('Account'));