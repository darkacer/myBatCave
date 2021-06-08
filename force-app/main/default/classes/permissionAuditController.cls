public with sharing class permissionAuditController{

    @AuraEnabled(cacheable = true)
    public static List<ObjectWrapper> getAllObjects(){
        List<ObjectWrapper> allObjects = new List<ObjectWrapper>();
        Set<String> ignoreObjects = new Set<String>{'__ka','__kav','__Feed','__ViewStat','__VoteStat','__DataCategorySelection',
                                                    '__xo','__mdt','__Share ','__Tag','__History','__pr','__hd','__hqr','__hst',
                                                    '__latitude__s','__longitude__s','__e','__p','__ChangeEvent'};
        for (Schema.SObjectType sch : Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objResult = sch.getDescribe();
            String objName = objResult.getName();
            String objLabel = objResult.getLabel();
            if(objName.contains('__')){
                if(!ignoreObjects.contains(objName.substring(objName.lastindexOf('__'), objName.length()))){    
                    allObjects.add(new ObjectWrapper(objLabel, objName));
                }
            }
            else{
                allObjects.add(new ObjectWrapper(objLabel, objName));
            }
        }
        allObjects.sort();
        return allObjects;
    }

    @AuraEnabled
    public static List<FieldWrapper> getObjectFields(String objectName){
        List<FieldWrapper> allFields = new List<FieldWrapper>();
        Map<String,Utility_FieldInfo.FieldDataType> fieldMap = new Map<String,Utility_FieldInfo.FieldDataType>();

        fieldMap = Utility_FieldInfo.getFieldsDataType(objectName);

        for(String fld: fieldMap.keySet()){
            allFields.add(new FieldWrapper(fieldMap.get(fld).fieldLabel, fld));
        }
        allFields.sort();
        return allFields;
    }

    @AuraEnabled
    public static List<permissionWrapper> getAccessDetails(String objectName, String fieldName){
        List<permissionWrapper> listAccessDetails = new List<permissionWrapper>();

        for(ObjectPermissions obj: [SELECT Id,SobjectType, PermissionsCreate, PermissionsDelete, PermissionsEdit, 
                                    PermissionsModifyAllRecords, PermissionsRead, PermissionsViewAllRecords, 
                                    Parent.Label, Parent.IsOwnedByProfile 
                                    FROM ObjectPermissions 
                                    WHERE SobjectType =:objectName]){
            permissionWrapper perm = new permissionWrapper();
            perm.PermissionsCreate = obj.PermissionsCreate;
            perm.PermissionsDelete = obj.PermissionsDelete;
            perm.PermissionsEdit = obj.PermissionsEdit;                           
            perm.PermissionsModifyAllRecords = obj.PermissionsModifyAllRecords;
            perm.PermissionsRead = obj.PermissionsRead;
            perm.PermissionsViewAllRecords = obj.PermissionsViewAllRecords;
            perm.Name = obj.SobjectType;
            perm.ParentName = obj.Parent.Label;
            perm.Type = 'Object';
            perm.IsObject = True;
            perm.ParentType = (obj.Parent.IsOwnedByProfile ? 'Profile' : 'PermissionSet');
            listAccessDetails.add(perm);                           
        }

        if(String.isNotBlank(fieldName)){
            String filter = objectName+'.'+fieldName;
            for(FieldPermissions obj: [SELECT Parent.Name,SObjectType,Field,PermissionsRead,
                                        PermissionsEdit,Parent.Label,Parent.IsOwnedByProfile
                                        FROM FieldPermissions 
                                        WHERE SObjectType = :objectName AND Field =:filter]){
                permissionWrapper perm = new permissionWrapper();
                perm.PermissionsCreate = False;
                perm.PermissionsDelete = False;
                perm.PermissionsEdit = obj.PermissionsEdit;                           
                perm.PermissionsModifyAllRecords = False;
                perm.PermissionsRead = obj.PermissionsRead;
                perm.PermissionsViewAllRecords = False;
                perm.Name = obj.Field.substring(obj.Field.indexOf('.')+1, obj.Field.length());
                perm.ParentName = obj.Parent.Label;
                perm.Type = 'Field';
                perm.IsField = True;
                perm.ParentType = (obj.Parent.IsOwnedByProfile ? 'Profile' : 'PermissionSet');
                listAccessDetails.add(perm);                           
            }
        }
        return listAccessDetails;
    }

    public class permissionWrapper{
        @AuraEnabled
        public Boolean PermissionsCreate {get; set;}
        @AuraEnabled
        public Boolean PermissionsDelete {get; set;}
        @AuraEnabled
        public Boolean PermissionsEdit {get; set;}
        @AuraEnabled
        public Boolean PermissionsModifyAllRecords {get; set;}
        @AuraEnabled
        public Boolean PermissionsRead {get; set;}
        @AuraEnabled
        public Boolean PermissionsViewAllRecords {get; set;}
        @AuraEnabled
        public Boolean IsOwnedByProfile {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String ParentName {get; set;}
        @AuraEnabled
        public String ParentType {get; set;}
        @AuraEnabled
        public String Type {get; set;}
        @AuraEnabled
        public Boolean IsObject {get; set;}
        @AuraEnabled
        public Boolean IsField {get; set;}
    }

    public class ObjectWrapper implements Comparable {
        @AuraEnabled
        public String objectLabel {get; set;}
        @AuraEnabled
        public String objectName {get; set;}
        public ObjectWrapper(String objectLabel, String objectName) {
            this.objectLabel = objectLabel;
            this.objectName = objectName;
        }
        public Integer compareTo(Object ObjToCompare) {
            return objectLabel.CompareTo(((ObjectWrapper)ObjToCompare).objectLabel);
        }
    }

    public class FieldWrapper implements Comparable {
        @AuraEnabled
        public String fieldLabel {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
        public FieldWrapper(String fieldLabel, String fieldName) {
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName;
        }
        public Integer compareTo(Object ObjToCompare) {
            return fieldLabel.CompareTo(((FieldWrapper)ObjToCompare).fieldLabel);
        }
    }
}