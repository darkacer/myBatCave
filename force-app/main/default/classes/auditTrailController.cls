public with sharing class auditTrailController {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPermissionSets() {
        Map<String, String> mapPermissionSet = new Map<String, String>();
        for(PermissionSet PS: [SELECT Id,Name,Label 
                                FROM PermissionSet Order By Label ASC]){
            mapPermissionSet.put(PS.Label, PS.Name);
        }
        return mapPermissionSet;
    }

    @AuraEnabled
    public static List<AuditDataWrapper> getAdutiDetails(String permissionSetName, String dateFilter, String actionType){ 
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        if(actionType == 'FLS'){
            listAuditDetails = getFLSInfo(permissionSetName,dateFilter,actionType);
        }
        else if(actionType == 'fieldDelete'){
            listAuditDetails = getFieldDeletionInfo(permissionSetName,dateFilter,actionType);
        } 
        else if(actionType == 'fieldCreate'){
            listAuditDetails = getFieldCreationInfo(permissionSetName,dateFilter,actionType);
        }      
        else if(actionType == 'workFlow'){
            listAuditDetails = getWorkFlowInfo(permissionSetName,dateFilter,actionType);
        }
        else if(actionType == 'validation'){
            listAuditDetails = getValidationRulesInfo(permissionSetName,dateFilter,actionType);
        }
        else if(actionType == 'flows'){
            listAuditDetails = getFlowsInfo(permissionSetName,dateFilter,actionType);
        }
        else if(actionType == 'emailAlerts'){
            listAuditDetails = getEmailAlertsInfo(permissionSetName,dateFilter,actionType);
        }
        else if(actionType == 'picklist'){
            listAuditDetails = getPicklistsInfo(permissionSetName,dateFilter,actionType);
        }
        
        else{
            List<AuditDataWrapper> listAllAuditDetails = new List<AuditDataWrapper>();
            //listAllAuditDetails = getFLSInfo(permissionSetName,dateFilter,actionType);
            listAllAuditDetails = (getFieldDeletionInfo(permissionSetName,dateFilter,actionType));
            listAllAuditDetails.addAll(getFieldCreationInfo(permissionSetName,dateFilter,actionType));
            listAllAuditDetails.addAll(getWorkFlowInfo(permissionSetName,dateFilter,actionType));
            listAllAuditDetails.addAll(getValidationRulesInfo(permissionSetName,dateFilter,actionType));
            listAllAuditDetails.addAll(getFlowsInfo(permissionSetName,dateFilter,actionType));
            listAllAuditDetails.addAll(getEmailAlertsInfo(permissionSetName,dateFilter,actionType)); 
            listAllAuditDetails.addAll(getPicklistsInfo(permissionSetName,dateFilter,actionType));
            return listAllAuditDetails;
        }
        return listAuditDetails;
    } 

    public static List<AuditDataWrapper> getFLSInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Map<String, String> mapAccessLevel = new Map<String, String>{
                                                                    'No Access to Read/Write' => 'increased',
                                                                    'No Access to Read Only' => 'increased',
                                                                    'Read Only to Read/Write' => 'increased',
                                                                    'Read Only to No Access' => 'decreased',
                                                                    'Read/Write to No Access' => 'decreased',
                                                                    'Read/Write to Read Only' => 'decreased',
                                                                    'Read Only to No Access' => 'removed',
                                                                    'Read/Write to No Access' => 'removed'
                                                                };

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action=\'PermSetFlsChanged\' ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry))
        {
            if(audit.Display.contains(permissionSetName)){
                String auditMessage = audit.Display;
                String objectName = auditMessage.substring(auditMessage.indexOf('field-level security for ')+25, auditMessage.lastindexOf(': '));
                String fieldName = auditMessage.substring(auditMessage.lastindexOf(': ')+2, auditMessage.indexOf(' was changed from '));
                String accesChange = auditMessage.substring(auditMessage.indexOf('was changed from ')+17, auditMessage.length());
                if(!mapAuditDetails.containsKey(objectName)){
                    mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
                }
                else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                    mapAuditDetails.get(objectName).put(fieldName, audit);
                }
            }
        }
        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String msg =  mapAuditDetails.get(oName).get(fName).Display;
                String accessChange = msg.substring(msg.indexOf('was changed from ')+17, msg.length());
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.access = accessChange;
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                audit.indicator = mapAccessLevel.get(accessChange)  == 'removed' ? 'utility:close' : mapAccessLevel.get(accessChange) == 'decreased' ? 'utility:jump_to_bottom' : 'utility:jump_to_top';
                listAuditDetails.add(audit);
            }

       }
       return listAuditDetails;
    }

    public static List<AuditDataWrapper> getFieldDeletionInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN (\'deletedCF\',\'deletedCFCustom\',\'hardDeletedCFCustom\') ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry)){
            if(audit.Section == 'Custom Objects'){
                String auditMessage = audit.Display;
                String objectName = auditMessage.substring(auditMessage.lastIndexOf('from')+5, auditMessage.length());
                String fieldName = auditMessage.substring(auditMessage.indexOf('Deleted custom field')+21 , auditMessage.lastindexOf(' from'));
                if(!mapAuditDetails.containsKey(objectName)){
                    mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
                }
                else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                    mapAuditDetails.get(objectName).put(fieldName, audit);
                }
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String msg =  mapAuditDetails.get(oName).get(fName).Display;
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.access = 'Deleted custom field';
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                audit.indicator = 'utility:close';
                listAuditDetails.add(audit);
            }
       }

        return listAuditDetails;
    }

    public static List<AuditDataWrapper> getFieldCreationInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Set<String> customFields = new Set<String>{'createdCFCustom','createdCF','createdCFFormulaCustom', 
                                                   'createdCFLookupCustom', 'createdCFMasterDetailCustom',
                                                   'createdCF_RSFCustom'};
        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN :customFields AND CreatedBy.Name != Null ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry)){
            
            String auditMessage = audit.Display;
            String objectName='';
            String fieldName='';
            if(audit.Action == 'createdCFLookupCustom'){
                objectName = auditMessage.substring(auditMessage.lastIndexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf('Created custom lookup relationship ')+35, auditMessage.lastindexOf(' on '));
            }
            else if(audit.Action == 'createdCFCustom'){
                objectName = auditMessage.substring(auditMessage.lastindexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf('Created custom field ')+21, auditMessage.lastindexOf(' on '));
            }
            else if(audit.Action == 'createdCF'){
                if(String.isNotBlank(audit.Section)){
                    objectName = audit.Section.substring(audit.Section.indexOf('Customize ')+10, audit.Section.length());
                    fieldName = auditMessage.substring(auditMessage.indexOf(': ')+2, auditMessage.length());
                }
            }
            else if(audit.Action == 'createdCFFormulaCustom'){
                objectName = auditMessage.substring(auditMessage.lastindexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf('Created custom formula field ')+29 , auditMessage.lastindexOf(' on '));
            }
            else if(audit.Action == 'createdCFMasterDetailCustom'){
                objectName = auditMessage.substring(auditMessage.lastindexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf(': ')+2, auditMessage.lastindexOf(' on '));
            }
            else if(audit.Action == 'createdCF_RSFCustom'){
                objectName = auditMessage.substring(auditMessage.lastIndexof(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf('Created roll up summary field ')+30, auditMessage.lastindexOf(' on '));
            }
            if(!mapAuditDetails.containsKey(objectName)){
                mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
            }
            else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                mapAuditDetails.get(objectName).put(fieldName, audit);
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                SetupAuditTrail auditTrail = mapAuditDetails.get(oName).get(fName);
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.access = auditTrail.Action == 'createdCFLookupCustom' ? 'Created custom lookup relationship' :
                               auditTrail.Action == 'createdCF' ? 'Created custom lookup relationship' :  
                               auditTrail.Action == 'createdCFFormulaCustom' ? 'Created custom formula field' :  
                               auditTrail.Action == 'createdCFMasterDetailCustom' ? 'Created custom master detail relationship' :  
                               auditTrail.Action == 'createdCF_RSFCustom' ? 'Created roll up summary field' :  'Created custom field';             
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                audit.indicator = 'utility:add';
                listAuditDetails.add(audit);
            }
       }

        return listAuditDetails;
    }

    public static List<AuditDataWrapper> getWorkFlowInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Set<String> workFlowActions = new Set<String>{'activatedworkflowrule','changedworkflowrule','createdworkflowrule', 
                                                      'deactivatedworkflowrule', 'deletedworkflowrule',
                                                      'createdfieldupdate', 'deletedfieldupdate'};

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN :workFlowActions AND CreatedBy.Name != Null ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry)){
            String auditMessage = audit.Display;
            String objectName = auditMessage.substring(auditMessage.lastIndexOf('Object: ')+8 , auditMessage.length());
            String fieldName = '';
            if(audit.Action != 'createdfieldupdate' &&  audit.Action!='deletedfieldupdate'){
                fieldName = auditMessage.substring(auditMessage.indexOf('workflow rule ')+14 , auditMessage.lastindexOf(' for Object:'));
            }else{
                fieldName = auditMessage.substring(21,auditMessage.lastindexOf(' for Object:'));
            }
            if(!mapAuditDetails.containsKey(objectName)){
                mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
            }
            else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                mapAuditDetails.get(objectName).put(fieldName, audit);
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String msg =  mapAuditDetails.get(oName).get(fName).Display;
                String action = mapAuditDetails.get(oName).get(fName).Action;
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.access = (action != 'createdfieldupdate' &&  action!= 'deletedfieldupdate') ? 
                               msg.substring(0,msg.indexOf('workflow rule')+13):
                               msg.substring(0,msg.indexOf(' Field Update ')+13);
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                if(action != 'createdfieldupdate' &&  action!= 'deletedfieldupdate'){
                    audit.indicator = (msg.startsWithIgnoreCase('Deactivated') ? 'utility:sentiment_negative' : 
                                      msg.startsWithIgnoreCase('Activated') ? 'utility:smiley_and_people' : 
                                      msg.startsWithIgnoreCase('Changed') ? 'utility:edit' : 
                                      msg.startsWithIgnoreCase('Deleted')  ? 
                                       'utility:close' : 'utility:add');
                }
                else{
                    audit.indicator = (action == 'createdfieldupdate' ? 'utility:add' : 'utility:close');
                }
                    
                listAuditDetails.add(audit);
            }
       }
        return listAuditDetails;
    }

    public static List<AuditDataWrapper> getValidationRulesInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Set<String> validRules = new Set<String>{'changedValidationActive','newValidation','removedValidation'};

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN :validRules ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry)){
            String auditMessage = audit.Display;
            String objectName = '';
            String fieldName = auditMessage.substring(auditMessage.indexOf('"')+1, auditMessage.lastIndexOf('"'));
            if(audit.Action == 'removedValidation'){
                objectName = auditMessage.substring(auditMessage.indexOf('Removed ')+8, auditMessage.lastIndexOf('validation "'));
            }
            else if(audit.Action == 'changedValidationActive'){
                objectName = auditMessage.substring(auditMessage.indexOf('flag for ')+9, auditMessage.lastIndexOf('validation "'));
            }
            else if(audit.Action == 'newValidation'){
                objectName = auditMessage.substring(auditMessage.indexOf('New ')+4, auditMessage.lastIndexOf('validation rule "'));
            }
            if(!mapAuditDetails.containsKey(objectName)){
                mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
            }
            else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                mapAuditDetails.get(objectName).put(fieldName, audit);
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String msg =  mapAuditDetails.get(oName).get(fName).Display;
                String action = mapAuditDetails.get(oName).get(fName).Action;
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.access = (action == 'newValidation') ? 
                               'New validation rule created':
                               (action == 'removedValidation') ?
                               'Removed validation rule' :
                               (msg.indexOf('from 1 to 0') > -1 ? 'Dectivated validation rule' : 'Activated validation rule');
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                if(action =='newValidation'){
                    audit.indicator = 'utility:add';
                }
                else if(action =='removedValidation'){
                    audit.indicator = 'utility:close';
                }
                else{
                    audit.indicator = (msg.indexOf('from 1 to 0') > -1 ? 'utility:close' : 'utility:add');
                }   
                listAuditDetails.add(audit);
            }
       }
        return listAuditDetails;
    }

    public static List<AuditDataWrapper> getFlowsInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Set<String> flowActions = new Set<String>{'deletedinteractiondefinition','activatedinteractiondefversion',
                                                 'createdinteractiondefversion', 'activatedinteractiondefinition',
                                                 'deletedinteractiondefversion','deactivatedinteractiondefversion',
                                                 'createdinteractiondefinition', 'deactivatedinteractiondefinition'};

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN :flowActions ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry)){
            String auditMessage = audit.Display;
            String objectName = 'Flow';
            String version = (audit.Action != 'createdinteractiondefinition' ? auditMessage.substring(auditMessage.indexof(' flow ')+6, auditMessage.indexOf(' "')) : '');
            String fieldName = auditMessage.substring(auditMessage.indexOf('Unique Name "')+13, auditMessage.lastIndexOf('"'));
            if(!mapAuditDetails.containsKey(objectName)){
                mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName+'#'+version => audit});
            }
            else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                mapAuditDetails.get(objectName).put(fieldName+'#'+version, audit);
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String msg =  mapAuditDetails.get(oName).get(fName).Display;
                String action = mapAuditDetails.get(oName).get(fName).Action;
                String version = (action != 'createdinteractiondefinition' ? msg.substring(msg.indexof(' flow ')+6, msg.indexOf(' "')) : '');
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = (fName.indexOf('#') > -1  ? fName.substring(0, fName.indexOf('#')) : fName);
                audit.access = (action == 'activatedinteractiondefversion') ? 
                               'New version activated - ' + version:
                               (action == 'createdinteractiondefversion') ?
                               'Created a new version - ' + version:
                               (action == 'deactivatedinteractiondefversion') ?
                               'Deactivated a version - ' + version : 
                               (action == 'deactivatedinteractiondefinition') ?
                               'Deactivated Flow' : 
                               (action == 'activatedinteractiondefinition') ?
                               'Activated Flow' : 
                               (action == 'deletedinteractiondefversion') ?
                               'Deleted Flow version - ' + version : 
                               (action == 'deletedinteractiondefinition') ?
                               'Deleted Flow ': 
                               (action == 'createdinteractiondefinition') ?
                               'Created new Flow ' : 'Deleted a flow - ' + version;                           
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                audit.indicator = (action == 'activatedinteractiondefversion' || action == 'activatedinteractiondefinition') ? 
                                    'utility:smiley_and_people':
                                    (action == 'createdinteractiondefversion') ?
                                    'utility:add' :
                                    (action == 'createdinteractiondefinition') ?
                                    'utility:add' :
                                    (action == 'deactivatedinteractiondefversion' || action == 'deactivatedinteractiondefinition' ) ?
                                    'utility:sentiment_negative' : 'utility:close';   
                listAuditDetails.add(audit);
            }
       }
        return listAuditDetails;
    }

    public static List<AuditDataWrapper> getEmailAlertsInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Set<String> emailAlertActions = new Set<String>{'createdemailalert', 'deletedemailalert'};

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN :emailAlertActions ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';

        for(SetupAuditTrail audit :Database.Query(qry)){
            String auditMessage = audit.Display;
            String objectName = auditMessage.substring(auditMessage.lastindexOf(' for Object:')+13, auditMessage.length());
            String fieldName = auditMessage.substring(20,auditMessage.lastindexOf(' for Object:'));
            if(!mapAuditDetails.containsKey(objectName)){
                mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
            }
            else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                mapAuditDetails.get(objectName).put(fieldName, audit);
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String msg =  mapAuditDetails.get(oName).get(fName).Display;
                String action = mapAuditDetails.get(oName).get(fName).Action;
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.access = (action == 'createdemailalert') ? 
                               'Created new Email Alert': 'Deleted Email Alert';                           
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                audit.indicator = (action == 'createdemailalert') ? 
                                    'utility:add': 'utility:close';
                listAuditDetails.add(audit);
            }
       }
        return listAuditDetails;
    }

    public static List<AuditDataWrapper> getPicklistsInfo(String permissionSetName, String dateFilter, String actionType){
        List<AuditDataWrapper> listAuditDetails = new List<AuditDataWrapper>();
        Map<String, Map<String, SetupAuditTrail>> mapAuditDetails = new Map<String, Map<String, SetupAuditTrail>>();
        Set<String> picklistActions = new Set<String>{'changedPicklist', 'changedPicklistCustom','changedPicklistValueApiName',
                                                        'changedPicklistValueApiNameCustom',                                                        'createdPicklistWithColor','createdPicklistWithColorCustom',
                                                         'createGlobalPicklist', 'deactivatePicklistValueWithColor',
                                                        'deactivatePicklistValueWithColorCustom','deletedPicklistWithColor',
                                                        'deletedPicklistWithColorCustom'}; 

        String qry = 'SELECT Id,Section,Action,Display, CreatedBy.Name, CreatedDate '+
                      'FROM SetupAuditTrail WHERE Action IN :picklistActions ';

        if(String.IsNotBlank(dateFilter)){
            Date fromDate = Date.valueOf(dateFilter);
            qry+= 'AND CreatedDate>=:fromDate ';
        }
        qry+= 'Order By CreatedDate Desc';
        
        for(SetupAuditTrail audit :Database.Query(qry)){
            String auditMessage = audit.Display;
            String objectName = '';
            String fieldName = '';
            if(audit.Action == 'changedPicklist'){
                objectName = 'Global Value Sets';
                fieldName = auditMessage.substring(8, auditMessage.indexOf(' picklist value from'));
            }
            else if(audit.Action == 'changedPicklistCustom'){
                objectName = auditMessage.substring(auditMessage.indexOf(' picklist value on ')+19, auditMessage.indexOf(' from '));
                fieldName = auditMessage.substring(8, auditMessage.indexOf(' picklist value on'));
            }
            else if(audit.Action == 'createdPicklistWithColor'){
                objectName = (audit.Section == 'Global Value Sets' ? 'Global Value Sets' : 
                             audit.Section.contains('Customize') ? audit.Section.substring(10, audit.Section.length()) : 'Object');
                fieldName = auditMessage.substring(auditMessage.indexOf(' to ')+4, auditMessage.indexOf(' picklist with color '));
            }
            else if(audit.Action == 'changedPicklistValueApiNameCustom'){
                objectName = auditMessage.substring(auditMessage.indexOf(' picklist value on ')+19, auditMessage.indexOf(' from '));
                fieldName = auditMessage.substring(8, auditMessage.indexOf(' picklist value on'));
            }
            else if(audit.Action == 'createdPicklistWithColorCustom'){
                objectName = auditMessage.substring(auditMessage.lastIndexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf(' to ')+4, auditMessage.indexOf(' picklist with color '));
            }
            else if(audit.Action == 'createGlobalPicklist'){
                objectName = 'Global Values Sets';
                fieldName = auditMessage.substring(auditMessage.lastIndexOf(' : ')+3, auditMessage.length());
            }
            else if(audit.Action == 'deactivatePicklistValueWithColor'){
                objectName = (audit.Section == 'Global Value Sets' ? 'Global Value Sets' : 
                             audit.Section.contains('Customize') ? audit.Section.substring(10, audit.Section.length()) : 'Object');
                fieldName = auditMessage.substring(auditMessage.indexOf(' from ')+6, auditMessage.indexOf(' picklist with color'));
            }
            else if(audit.Action == 'deactivatePicklistValueWithColorCustom'){
                objectName = auditMessage.substring(auditMessage.lastIndexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf(' from ')+6, auditMessage.indexOf(' picklist with color'));
            }
            else if(audit.Action == 'deletedPicklistWithColor'){
                objectName = (audit.Section == 'Global Value Sets' ? 'Global Value Sets' : 
                             audit.Section.contains('Customize') ? audit.Section.substring(10, audit.Section.length()) : 'Object');
                fieldName = auditMessage.substring(auditMessage.indexOf(' from ')+6, auditMessage.indexOf(' picklist with color'));
            }
            else if(audit.Action == 'deletedPicklistWithColorCustom'){
                objectName = auditMessage.substring(auditMessage.lastIndexOf(' on ')+4, auditMessage.length());
                fieldName = auditMessage.substring(auditMessage.indexOf(' from ')+6, auditMessage.indexOf(' picklist with color'));
            }
            if(!mapAuditDetails.containsKey(objectName)){
                mapAuditDetails.put(objectName, new Map<String, SetupAuditTrail>{fieldName => audit});
            }
            else if(!mapAuditDetails.get(objectName).containsKey(fieldName)){
                mapAuditDetails.get(objectName).put(fieldName, audit);
            }
        }

        for(String oName: mapAuditDetails.keySet()){
            for(String fName: mapAuditDetails.get(oName).keySet()){
                String auditMessage =  mapAuditDetails.get(oName).get(fName).Display;
                String action = mapAuditDetails.get(oName).get(fName).Action;
                AuditDataWrapper audit = new AuditDataWrapper();
                audit.objectName = oName;
                audit.fieldName = fname;
                audit.indicator = 'utility:add';
                if(action == 'changedPicklist'){
                    audit.access = 'Changed ' + auditMessage.substring(auditMessage.indexOf(' value from ')+12, auditMessage.length());
                }
                else if(action == 'changedPicklistCustom'){
                    audit.access = 'Changed ' + auditMessage.substring(auditMessage.lastindexOf(' from ')+6, auditMessage.length());
                }
                else if(action == 'createdPicklistWithColor' || action == 'createdPicklistWithColorCustom'){
                    audit.access = auditMessage.substring(0, auditMessage.indexOf(' to '));
                }
                else if(action == 'changedPicklistValueApiNameCustom'){
                    audit.access = 'Changed ' + auditMessage.substring(auditMessage.lastindexOf(' from ')+6, auditMessage.length());
                }
                else if(action == 'createGlobalPicklist'){
                    audit.access = auditMessage;
                }
                else if(action == 'deactivatePicklistValueWithColor' || action == 'deactivatePicklistValueWithColorCustom'){
                    audit.access = auditMessage.substring(0, auditMessage.indexOf(' from '));
                    audit.indicator = 'utility:close';
                }
                else if(action == 'deletedPicklistWithColor' || action == 'deletedPicklistWithColorCustom'){
                    audit.access = auditMessage.substring(0, auditMessage.indexOf(' from '));
                    audit.indicator = 'utility:close';
                }                    
                audit.auditInstance = mapAuditDetails.get(oName).get(fName);
                listAuditDetails.add(audit);
            }
       }
        return listAuditDetails;
    }

    public class AuditDataWrapper{
        @AuraEnabled
        public String objectName {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public String access {get; set;}
        @AuraEnabled
        public String indicator {get; set;}
        @AuraEnabled
        public SetupAuditTrail auditInstance {get; set;}
    }
}