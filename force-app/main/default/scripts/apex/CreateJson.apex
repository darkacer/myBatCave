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

    private String timeNow = String.valueOf(System.now());
    
    public  void main(List<WrapperClass> wapList, Id attachmentRecord) {
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
            
        }

        planAttachment.body = Blob.valueOf(JSON.serializePretty(planBodyArray));
        attachmentList.add(planAttachment);

        if(!attachmentList.isEmpty()) {
            insert attachmentList;
        }
    }

    public  Map<String,Object> generatePlanRecord(String objectName, String fileName) {
        Map<String, Object> retObject = new Map<String,Object>();
        retObject.put('saveRefs', true);
        retObject.put('resolveRefs', true);
        retObject.put('sObject', objectName);
        retObject.put('files', new List<String>{fileName});
        return retObject;
    }

    private  Map<String, Object> convertSobjectToMap(sObject sObj, Set<String> fieldsToRef, String sObjectName) {
        Map<String, Object> sObjMap = new Map<String, Object>();
        fieldsToRef = convertToLowerCase(fieldsToRef);
        for(String key : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keySet()) {
            if(sObj.isSet(key) && sObj.get(key) != null) {
                if(fieldsToRef != null && fieldsToRef.contains(key.toLowerCase())) {
                    sObjMap.put(key, '@' + (Id)sObj.get(key));
                } else {
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
    private  List<Object> convertSobjectListToList(List<sObject> sObjectList, Set<String> fieldsToRef, String sObjectName) {
        List<Object> listOfSObj = new List<Object>();
        for(sObject sObj : sObjectList) {
            listOfSObj.add(convertSobjectToMap(sObj, fieldsToRef, sObjectName));
        }
        return listOfSObj;
    }

    private  Attachment createAttachmentFile(String sObjectName, String body, Id attachmentRecord) {
        String fileName = getFileName(sObjectName);

        Attachment at = new Attachment(
            ParentId = attachmentRecord,
            body = Blob.valueOf(body),
            Name = fileName
        );
        return at;
    }

    private  Set<String> convertToLowerCase(Set<String> inputSet) {
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
    false,
    'custom_parent__c'
);
listOfWrapperClasses.add(genericRecords);


new CloneSObjectDAGUtility().main(listOfWrapperClasses, attachmentRecord);
