public with sharing class permissionSetController {

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
    public static List<fieldPermissionsWrapper> getPermissionInfo(String permissionSetIds, String objectName, Boolean isSystemPermission){
        if(!isSystemPermission){
            return getFieldLevelPermissions(permissionSetIds, objectName);
        }
        else{
            return getSystemPermissions(permissionSetIds);
        }
    }

    @AuraEnabled
    public static List<fieldPermissionsWrapper> getFieldLevelPermissions(String permissionSetIds, String objectName){

        Map<Id, String> permissionInput = new Map<Id, String>();
        for(inputWrapper r: (List<inputWrapper>)JSON.deserialize(permissionSetIds, List<inputWrapper>.class)){
            permissionInput.put(r.value, r.label);
        }

        Map<String, Map<String, FieldPermissions>> flsMap= new Map<String, Map<String, FieldPermissions>>();
        Map<String, Map<String, FieldPermissions>> flsMapExt= new Map<String, Map<String, FieldPermissions>>();
        Map<String,Utility_FieldInfo.FieldDataType> fieldMap = new Map<String,Utility_FieldInfo.FieldDataType>();
        List<fieldPermissionsWrapper> lstfieldPermissionsWrapper = new List<fieldPermissionsWrapper>();
        fieldMap = Utility_FieldInfo.getFieldsDataType(objectName);

        for(FieldPermissions fls: [SELECT Parent.Name,SObjectType, Field,PermissionsRead,PermissionsEdit
                                        FROM FieldPermissions
                                        Where SObjectType=:objectName
                                        And Parent.Id IN :permissionInput.keySet() Order By Parent.Name]){
            String fName = fls.Field.substring(fls.Field.lastIndexOf('.')+1, fls.Field.length());
                             
            if(!flsMap.containsKey(fls.Parent.Name)) {
                flsMap.put(fls.Parent.Name, new Map<String,FieldPermissions>{fName => fls});
            }       
            else if(flsMap.containsKey(fls.Parent.Name)){
                flsMap.get(fls.Parent.Name).put(fName, fls);
            }                               
        }
               
        for(String sfield : fieldMap.keySet())
        {            
            fieldInfoWrapper fieldWrap = new fieldInfoWrapper();
            fieldPermissionsWrapper fpsWrap = new fieldPermissionsWrapper();
            fieldWrap.fieldLabel = fieldMap.get(sfield).fieldLabel;
            fieldWrap.fieldAPIName = sfield;
            fieldWrap.fieldType = fieldMap.get(sfield).fieldDataType;
            List<fieldAccessWrapper> fieldAccessList = new List<fieldAccessWrapper>();
            for(String psName :permissionInput.values()){
                fieldAccessWrapper fieldAccessInfo = new fieldAccessWrapper();
                if(flsMap.containskey(psName)){
                    if(flsMap.get(psName).containsKey(fieldWrap.fieldAPIName)){                       
                        FieldPermissions fdPerm = flsMap.get(psName).get(fieldWrap.fieldAPIName);
                        fieldAccessInfo.ParentName = fdPerm.Parent.Name;
                        fieldAccessInfo.PermissionsRead = fdPerm.PermissionsRead;
                        fieldAccessInfo.PermissionsEdit = fdPerm.PermissionsEdit;
                    }
                    else{
                        fieldAccessInfo.ParentName = psName;
                        fieldAccessInfo.PermissionsRead = false;
                        fieldAccessInfo.PermissionsEdit = false;
                    }
                }
                else{
                    fieldAccessInfo.ParentName = psName;
                    fieldAccessInfo.PermissionsRead = false;
                    fieldAccessInfo.PermissionsEdit = false;
                }
                fieldAccessList.add(fieldAccessInfo);
            }  
            fpsWrap.fieldInfo = fieldWrap;               
            fpsWrap.fieldPermissionsInfo = fieldAccessList;
            lstfieldPermissionsWrapper.add(fpsWrap);   
        }      
        return lstfieldPermissionsWrapper;
    }

    @AuraEnabled
    public static List<fieldPermissionsWrapper> getSystemPermissions(String permissionSetIds){
        Map<Id, String> permissionInput = new Map<Id, String>();
        Map<String, String> fieldAttributes = new Map<String, String>();
        List<fieldPermissionsWrapper> lstfieldPermissionsWrapper = new List<fieldPermissionsWrapper>();
        Set<String> ignoreFields = new Set<String>{'Id','Name','LicenseId','ProfileId','IsOwnedByProfile','Description','CreatedDate','CreatedById','LastModifiedDate','LastModifiedById','SystemModstamp','NamespacePrefix','HasActivationRequired','Type','PermissionSetGroupId','Label'};
        Set<Id> pIds = new Set<Id>{};
        String strFields = '';
        
        for(inputWrapper r: (List<inputWrapper>)JSON.deserialize(permissionSetIds, List<inputWrapper>.class)){
            permissionInput.put(r.value, r.label);
            pIds.add(r.value);
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PermissionSet').getDescribe().fields.getMap();
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {  
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldAttributes.put(dfield.getLabel(), dfield.getname());
        }

        for(String fieldName : fieldMap.keyset() ){
            if(strFields == null || strFields == ''){
                strFields = fieldName;
            }
            else{
                strFields = strFields + ' , ' + fieldName;
            }
        }

        String query = 'SELECT  ' + strFields + ' FROM PermissionSet WHERE Id IN:pIds';
        Map<Id, PermissionSet> psMap = new Map<Id, PermissionSet>((List<PermissionSet>)database.Query(query));

        for(String flabel: fieldAttributes.keyset())
        {            
            String fieldLabel = flabel;
            String fieldName = fieldAttributes.get(flabel);
            if(!ignoreFields.contains(fieldName)){
                fieldInfoWrapper fieldWrap = new fieldInfoWrapper();
                fieldPermissionsWrapper fpsWrap = new fieldPermissionsWrapper();
                fieldWrap.fieldLabel = fieldLabel;
                fieldWrap.fieldAPIName = fieldName;
                fieldWrap.fieldType = 'System Permission';
                List<fieldAccessWrapper> fieldAccessList = new List<fieldAccessWrapper>();
                for(String pId :permissionInput.keyset()){
                    fieldAccessWrapper fieldAccessInfo = new fieldAccessWrapper();                    
                    fieldAccessInfo.ParentName = (String)psMap.get(pId).get('Label');
                    fieldAccessInfo.PermissionsRead = Boolean.valueOf(psMap.get(pId).get(fieldName));
                    fieldAccessInfo.PermissionsEdit = Boolean.valueOf(psMap.get(pId).get(fieldName));
                    fieldAccessList.add(fieldAccessInfo);
                }  
                fpsWrap.fieldInfo = fieldWrap;               
                fpsWrap.fieldPermissionsInfo = fieldAccessList;
                lstfieldPermissionsWrapper.add(fpsWrap);   
            }
        }        
        return lstfieldPermissionsWrapper;
    }


    public class fieldLevelPermissionWrapper{
        @AuraEnabled
        public fieldInfoWrapper fieldInfo {get; set;}
        @AuraEnabled
        public FieldPermissions fls {get; set;}
    }

    public class fieldInfoWrapper{
        @AuraEnabled
        public String fieldLabel {get; set;}
        @AuraEnabled
        public String fieldAPIName {get; set;}
        @AuraEnabled
        public String fieldType {get; set;}
    }

    public class fieldAccessWrapper{
        @AuraEnabled
        public String ParentName {get; set;}
        @AuraEnabled
        public String ObjectName {get; set;}
        @AuraEnabled
        public Boolean PermissionsRead {get; set;}
        @AuraEnabled
        public Boolean PermissionsEdit {get; set;}
        @AuraEnabled
        public Boolean PermissionsReadExt {get; set;}
        @AuraEnabled
        public Boolean PermissionsEditExt {get; set;}
        @AuraEnabled
        public Boolean IsPermissionDifference {get; set;}
    }

    public class fieldPermissionsWrapper{
        @AuraEnabled
        public fieldInfoWrapper fieldInfo {get; set;}
        @AuraEnabled
        public List<fieldAccessWrapper> fieldPermissionsInfo {get; set;}
    }

    public class inputWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public Id value {get; set;}
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
}