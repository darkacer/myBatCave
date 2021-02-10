public without sharing class CloneSobjects {
    Boolean preserveId;
    Boolean isDeepClone;
    Boolean preserveReadonlyTimestamps;
    Boolean preserveAutonumber;

    public static Map<Id, Id> templateToNewSobjectIdMap = new Map<Id, Id>();

    public CloneSobjects() {
        this.preserveId = false;
        this.isDeepClone = true;
        this.preserveReadonlyTimestamps = false;
        this.preserveAutonumber = false;
    }

    public CloneSobjects(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber) {
        this.preserveId = preserveId;
        this.isDeepClone = isDeepClone;
        this.preserveReadonlyTimestamps = preserveReadonlyTimestamps;
        this.preserveAutonumber = preserveAutonumber;
    }

    /**
     * @description Interface to override execute method by new class
     */
    public interface OverRideSobjectFields {
        Object execute(SObject obj);
    }

    public class ReturnId implements OverRideSobjectFields {
        public Id execute(Sobject obj) {
            return obj.Id;
        }
    }

    public class ReturnTemplateFieldValue implements OverRideSobjectFields {
        private String fieldName;
        public ReturnTemplateFieldValue(String fieldName) {
            this.fieldName = fieldName;
        }
        public Object execute(Sobject obj) {
            return obj.get(this.fieldName);
        }
    }

    public class ReturnParentFieldFromTemplate implements OverRideSobjectFields{
        private String fieldName;
        public ReturnParentFieldFromTemplate(String fieldName) {
            this.fieldName = fieldName;
        }
        public Object execute(Sobject obj) {
            return templateToNewSobjectIdMap.get((Id)obj.get(this.fieldName));
        }
    }

    public CloneSobjects CloneSobjectsFrom(List<sObject> sObjectList, Map<String, OverRideSobjectFields> overRideMapping) {
        List<SObject> clonedSobjectList = new List<SObject>();
        for(sObject obj : sObjectList) {
            clonedSobjectList.add(CloneSobjectsFrom(obj, overRideMapping));
        }
        insertSobject(clonedSobjectList, sObjectList);
        return this;
    }

    private sObject CloneSobjectsFrom(sObject obj, Map<String, OverRideSobjectFields> overRideMapping) {
        sObject tempObject = obj.clone(
            this.preserveId,
            this.isDeepClone,
            this.preserveReadonlyTimestamps,
            this.preserveAutonumber
        );
        if(overRideMapping != null) {
            for(String fieldName : overRideMapping.keySet()) {
                tempObject.put(fieldName, overRideMapping.get(fieldName).execute(obj));
            }
        }
        return tempObject;
    }

    private void insertSobject(List<SObject> sObjectList, List<SObject> templateSobjectList) {
        try {
            Insert sObjectList;
            for(Integer i = 0; i < sObjectList.size(); i++) {
                templateToNewSobjectIdMap.put(templateSobjectList[i].Id, sObjectList[i].Id);
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }
}