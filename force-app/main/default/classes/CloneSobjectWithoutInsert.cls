public with sharing class CloneSobjectWithoutInsert {
    public CloneSobjectWithoutInsert() {

    }

    public static void demo() {
        Id attachingToId = 'a097F00000BC6czQAD';
        List<Account> accList = [Select Id, name, description, BillingCity from Account Where name like 'Edge Communications%'];
        List<Contact> conList = [Select Id, lastname from contact where Accountid = :accList[0].Id];
        List<Opportunity> oppList = [Select Id, name, Amount, CloseDate, AccountId, StageName From Opportunity Where Accountid = :accList[0].Id];

        Map<String, CloneSObjects.OverRideSobjectFields> overRideAccountMap = new Map<String, CloneSObjects.OverRideSobjectFields> {
            // only copies fields from template's records
            'ShippingCity' => new CloneSObjects.ReturnTemplateFieldValue('BillingCity')
        };

        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapContact = new Map<String, CloneSObjects.OverRideSobjectFields> {
            // copies fields from parent records
            'AccountId' => new CloneSObjects.RetrunParentRrefFromTemplate('AccountId')
        };
            
        Map<String, CloneSObjects.OverRideSobjectFields> overRideMapOpp = new Map<String, CloneSObjects.OverRideSobjectFields> {
            'AccountId' => new CloneSObjects.RetrunParentRrefFromTemplate('AccountId')
        };

        CloneSObjects testDemo = new CloneSObjects()
                                .cloneSobjectsFrom(accList, overRideAccountMap, false, true)
                                .cloneSobjectsFrom(conList, overRideMapContact, false, true)
                                .cloneSobjectsFrom(oppList, overRideMapOpp, false, false);
        // system.debug('Cloned records: ' + testDemo.getGeneratedRecords());
        insertAttachments(testDemo, attachingToId);
        
    }

    private static void insertAttachments(CloneSObjects cloneInstance, Id attachingToId) {
        Map<String, List<sObject>> dataMap = new Map<String, List<sObject>>();
        Set<String> sobjectSequence = new Set<String>();
        
        for(SObject sobj : cloneInstance.getGeneratedRecords()) {
            String sobjectName = String.valueOf(sobj.getSObjectType());
            if(!dataMap.containsKey(sobjectName)) {
                dataMap.put(sobjectName, new List<sObject>());
            }
            dataMap.get(sobjectName).add(sObj);
            sobjectSequence.add(sobjectName);
        }
        List<Attachment> listOfAttachments = new List<Attachment>();
        DateTime dt = DateTime.now();
        String dateTimeStr = dt.format('yyyy/MM/dd hh:mm:ss');
        listOfAttachments.add(generateFullPlan(sobjectSequence, dateTimeStr, attachingToId));
        for(String objName :sobjectSequence) {
            Attachment attachment = new Attachment();
            attachment.ParentId = attachingToId;
            attachment.Name = dateTimeStr + objName + '.json';
            attachment.Body = Blob.valueOf(convertListToJson(dataMap.get(objName)));
            listOfAttachments.add(attachment);
        }

        try {
            insert listOfAttachments;
        } catch(Exception e) {
            System.debug('Error in inserting attachments');
        }
    }

    private static Attachment generateFullPlan(Set<String> sobjectSequence, String dt, Id attachingToId) {
        List<Object> objSeq = new List<Object>();

        for(String obj :sobjectSequence) {
            List<String> fileNameList = new List<String>{dt + obj + '.json'};

            Map<String, Object> objMap = new Map<String, Object>{
                'saveRefs'    => true,
                'resolveRefs' => true,
                'sObject'     => obj,
                'files'       => fileNameList
            };
            objSeq.add(objMap);
        }
        
        Attachment attachment = new Attachment();
        attachment.ParentId = attachingToId;
        attachment.Name = dt + ' FullPlan.json';
        attachment.Body = Blob.valueOf(JSON.serialize(objSeq));

        return attachment;
    }

    private static String convertListToJson(List<sObject> sObjectList) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        List<Object> sObjectMapList = new List<Object>();
        for(sObject sObj : sObjectList) {
            Map<String, Object> attributeMap = new Map<String, Object>();
            Map<String, Object> sobjectMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sObj));
            Id sObjectid = sobjectMap.containsKey('Id') ? (Id)sobjectMap.get('Id') : (Id)sobjectMap.get('id');
            sobjectMap.remove('Id');
            sobjectMap.remove('id');
            attributeMap.put('type', String.valueOf(sobj.getSObjectType()));
            attributeMap.put('referenceId', sObjectid);
            sobjectMap.put('attributes', attributeMap);
            System.debug('sobjectMap => ' + sobjectMap);
            sObjectMapList.add(sobjectMap);
        }
        gen.writeObjectField('records', sObjectMapList);
        return gen.getAsString();
    }
}
