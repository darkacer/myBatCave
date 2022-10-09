public class WrapperClass {
    public List<sObject> records;
    public String sObjectName;
    public Set<String> fieldsToRef;
    public Boolean hasSelfRelationship;
    public String ifSelfRefThenFieldName;

    public WrapperClass(List<sObject> records,  Set<String> fieldsToRef, String sObjectName,Boolean hasSelfRelationship, String ifSelfRefThenFieldName) {
        this.records = records;
        this.sObjectName = sObjectName;
        this.fieldsToRef = fieldsToRef;
        this.hasSelfRelationship = hasSelfRelationship;
        this.ifSelfRefThenFieldName = ifSelfRefThenFieldName;
    }
}

public class CloneSObjectDAGUtility {
    String timeNow = String.valueOf(System.now()).deleteWhitespace();
    /// start self ref
    private List<Attachment> DAG_main(String str, String parentRefName, Id recId, String refObjName) {
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
    
    private String decorateObject(List<String> keyList) {
        List<Object> tempList = new List<Object>();
        for(string refName :keyList) {
            tempList.add(idToRecordMap.get(refName));
        }
        Map<String, Object> tempMap = new Map<String, Object>();
        
        tempMap.put('records', tempList);
        return (String)JSON.serializePretty(tempMap);
    }
    
    private string getParentRef(Object obj) {
        Map<String, Object> RespObjMap = (map<String, Object>)obj;
        String srt = (String)RespObjMap.get(DAG_parentFieldName);
        return srt?.replace('@', '');
    }
    
    private string getSelfRef(Object obj) {
        map<String, Object> RespObjMap = (map<String, Object>)obj;
        Object attr = RespObjMap.get('attributes');
        map<String, Object> RespObjMap2 = (map<String, Object>)attr;
        String srt = (String)RespObjMap2.get('referenceId');
        return srt?.replace('@', '');
    }

    public String generatCounterFileName(Integer DAG_counter, String DAG_refObjectName) {
        return DAG_refObjectName + 'part'+ DAG_counter++ + '-' + timeNow +'.json';
    }

    private List<Attachment> reccursiveMethod(List<String> childs, Map<String, List<String>> parentToChildMap, List<Attachment> attachmentList) {
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

    private List<String> getChilds(List<String> keys, Map<String, List<String>> parentToChildMap) {
        List<String> childs = new List<String>();
        for(String key :keys) {
            if(parentToChildMap.containsKey(key)) {
                childs.addAll(parentToChildMap.get(key));
            }
        }
        return childs;
    }
    //// end self ref
    
    public void main(List<WrapperClass> wapList, Id attachmentRecord) {
        List<Attachment> attachmentList = new List<Attachment>();

        Attachment planAttachment = new Attachment(
            parentId = attachmentRecord,
            Name = 'Plan-' + timeNow + '.json'
        );

        List<Object> planBodyArray = new List<Object>();

        for(WrapperClass wap : wapList) {

            List<Object> listObject = convertSobjectListToList(wap.records, wap.fieldsToRef, wap.sObjectName);
            System.debug(listObject);
            System.debug(JSON.serialize(listObject));

            Map<String, Object> objectAttachmentStructure = new Map<String, Object>();
            objectAttachmentStructure.put('records', listObject);

            if(!wap.hasSelfRelationship) {
                attachmentList.add(createAttachmentFile(wap.sObjectName, JSON.serializePretty(objectAttachmentStructure), attachmentRecord));
                planBodyArray.add(generatePlanRecord(wap.sObjectName, getFileName(wap.sObjectName)));
            } 
            else {
                List<Attachment> allSelfRefAttachmentList = DAG_main(
                    JSON.serializePretty(objectAttachmentStructure),
                    wap.ifSelfRefThenFieldName,
                    attachmentRecord,
                    wap.sObjectName
                );
                System.debug('allSelfRefAttachmentList ==== ' +allSelfRefAttachmentList);

                Integer i = 0;
                for(Attachment at :allSelfRefAttachmentList) {
                    planBodyArray.add(generatePlanRecord(wap.sObjectName, generatCounterFileName(i++, wap.sObjectName)));
                }

                attachmentList.addAll(allSelfRefAttachmentList);
            }
            
        }

        planAttachment.body = Blob.valueOf(JSON.serializePretty(planBodyArray));
        attachmentList.add(planAttachment);

        if(!attachmentList.isEmpty()) {
            insert attachmentList;
        }
    }

    public Map<String,Object> generatePlanRecord(String objectName, String fileName) {
        Map<String, Object> retObject = new Map<String,Object>();
        retObject.put('saveRefs', true);
        retObject.put('resolveRefs', true);
        retObject.put('sobject', objectName);
        retObject.put('files', new List<String>{fileName});
        return retObject;
    }

    private Map<String, Object> convertSobjectToMap(sObject sObj, Set<String> fieldsToRef, String sObjectName) {
        Map<String, Object> sObjMap = new Map<String, Object>();
        fieldsToRef = convertToLowerCase(fieldsToRef);
        for(String key : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keySet()) {
            if(sObj.isSet(key) && sObj.get(key) != null) {
                if(fieldsToRef != null && fieldsToRef.contains(key.toLowerCase())) {
                    sObjMap.put(key, '@' + (Id)sObj.get(key));
                } else if(!key.equalsIgnoreCase('id')){
                    sObjMap.put(key, sObj.get(key));
                }
            }
        }
        /* add the following to each map (record)
        "attributes": {
				"type": "Account",
				"referenceId": "AccountRef0"
		}
        */
        Map<String, Object> tempMap = new Map<String, Object>();
        tempMap.put('type', sObjectName);
        tempMap.put('referenceId', String.valueOf(sObj.get('Id')));
        sObjMap.put('attributes', tempMap);
        
        return sObjMap;
    }

    /** 
    converts List if sobject to object list 
    so Contact(id='1',name='abc',accountId='123')
    becomes [{name:'abc',id:'1','accountId':'@123'}]
     */
    private List<Object> convertSobjectListToList(List<sObject> sObjectList, Set<String> fieldsToRef, String sObjectName) {
        List<Object> listOfSObj = new List<Object>();
        for(sObject sObj : sObjectList) {
            listOfSObj.add(convertSobjectToMap(sObj, fieldsToRef, sObjectName));
        }
        return listOfSObj;
    }

    private Attachment createAttachmentFile(String sObjectName, String body, Id attachmentRecord) {
        String fileName = getFileName(sObjectName);

        Attachment at = new Attachment(
            ParentId = attachmentRecord,
            body = Blob.valueOf(body),
            Name = fileName
        );
        return at;
    }

    private Set<String> convertToLowerCase(Set<String> inputSet) {
        Set<String> returnSet = new Set<String>();
        if(inputSet == null || inputSet.isEmpty()) return returnSet;
        for(String str :inputSet) {
            returnSet.add(str.toLowerCase());
        }
        return returnSet;
    }

    private  String getFileName(String sObjectName) {
        return sObjectName + '-' + timeNow + '.json';
    }

}

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


Id attachmentRecord = '0017F00002l6spTQAQ';
Id DAG_recordId = attachmentRecord;
String DAG_refObjectName;
Integer DAG_counter = 0;
String DAG_parentFieldName = 'Parent_Object__c';
Map<String, String> childToParentMap = new Map<String, String>();
Map<String, Object> idToRecordMap = new Map<String, Object>();
List<WrapperClass> listOfWrapperClasses = new List<WrapperClass>();
List<Account> accList = [
    SELECT Id, name, description 
    FROM Account 
    WHERE id = '0017F00002l6spTQAQ'
];
WrapperClass accountRecords = new WrapperClass(
    accList,
    null,
    'Account',
    false,
    null
);
listOfWrapperClasses.add(accountRecords);

WrapperClass contactRecords = new WrapperClass(
    [
        SELECT Id, AccountId, account.name,account.description, lastname 
        FROM contact 
        WHERE Accountid = :accList[0].Id
    ],
    new Set<String> {
        'AccountId'
    },
    'Contact',
    false,
    null
);
listOfWrapperClasses.add(contactRecords);

WrapperClass opportunityRecords = new WrapperClass(
    [
        SELECT Id, name, Amount, CloseDate, AccountId, StageName 
        FROM Opportunity 
        WHERE Accountid = :accList[0].Id
    ],
    new Set<String> {
        'AccountId'
    },
    'Opportunity',
    false,
    null
);
listOfWrapperClasses.add(opportunityRecords);

WrapperClass genericRecords = new WrapperClass(
    [
        SELECT Id, Name, Value__c, custom_parent__c, Opportuntiy__c, Identifier__c 
        FROM Generic_Custom_JSON__c
        WHERE Identifier__c = 'testIden'
    ],
    new Set<String> {
        'Opportuntiy__c',
        'custom_parent__c'
    },
    'Generic_Custom_JSON__c',
    true,
    'custom_parent__c'
);
listOfWrapperClasses.add(genericRecords);


new CloneSObjectDAGUtility().main(listOfWrapperClasses, attachmentRecord);
