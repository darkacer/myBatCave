public without sharing class CloneSobjects {
    Boolean preserveId = false;
    Boolean isDeepClone = true;
    Boolean preserveReadonlyTimestamps = false;
    Boolean preserveAutonumber = false;

    /**
     * Instance set to maintain set of records cloned
     */
    private Set<SObject> newlyInsertedRecordSet = new Set<SObject>();

    /**
     * @description Returns set of records cloned in this instance
     */
    public Set<SObject> getClonedRecords() {
        return this.newlyInsertedRecordSet;
    }

    /**
     * Maintains map of template and cloned records when inserted
     */
    public static Map<Id, Id> templateToNewSobjectIdMap = new Map<Id, Id>();

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

    /**
     * @descrption Uses template record's fieldName to attach to cloned record's fieldName
     */
    public class ReturnTemplateFieldValue implements OverRideSobjectFields {
        private String fieldName;
        public ReturnTemplateFieldValue(String fieldName) {
            this.fieldName = fieldName;
        }
        public Object execute(Sobject obj) {
            return obj.get(this.fieldName);
        }
    }
    /**
     * @description Uses template record's parent field to find new parent's Id
     */
    public class ReturnParentFieldFromTemplate implements OverRideSobjectFields{
        private String fieldName;
        public ReturnParentFieldFromTemplate(String fieldName) {
            this.fieldName = fieldName;
        }
        public Object execute(Sobject obj) {
            return templateToNewSobjectIdMap.get((Id)obj.get(this.fieldName));
        }
    }

    /**
     * @description Returns class's instance for further chaining, inserts 
     * @param sObjectList - List of template SObject to be cloned
     * @param overRideMapping - Map of fieldName (string) to a overRide interface implementation instance
     */
    public CloneSobjects cloneSobjectsFrom(List<SObject> sObjectList, Map<String, OverRideSobjectFields> overRideMapping, Boolean isInsert) {
        List<SObject> clonedSobjectList = new List<SObject>();
        for(SObject obj : sObjectList) {
            clonedSobjectList.add(cloneSobjectsFrom(obj, overRideMapping));
        }
        if(isInsert) {
            clonedSobjectList = insertSobject(clonedSobjectList, sObjectList);
        }
        this.newlyInsertedRecordSet.addAll(clonedSobjectList);
        return this;
    }

    /**
     * @description Returns newly Cloned SObject, follows the override fieldmapping
     * @param obj - SObject to be cloned
     * @param overRideMapping - Map of fieldName (string) to a overRide interface implementation instance
     */
    private SObject cloneSobjectsFrom(SObject obj, Map<String, OverRideSobjectFields> overRideMapping) {
        SObject tempObject = obj.clone(
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

    /**
     * @description Inserts newly cloned Sobject list and maintains mapping from template to cloned record id in static map
     * @param sObjectList - List of SObject to be cloned
     * @param templateSobjectList - List of SObject to be cloned from
     */
    private List<SObject> insertSobject(List<SObject> sObjectList, List<SObject> templateSobjectList) {
        try {
            Insert sObjectList;
            for(Integer i = 0; i < sObjectList.size(); i++) {
                templateToNewSobjectIdMap.put(templateSobjectList[i].Id, sObjectList[i].Id);
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return sObjectList;
    }
}