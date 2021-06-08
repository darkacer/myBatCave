@istest(SeeAllData=true)
private class auditTrailControllerTest {
    static Testmethod void  testSetupAuditTrail(){
        List<PermissionSet> ps = [SELECT Id,Label FROM PermissionSet Where NOT Label LIKE '%00%' LIMIT 1];
        String inp = '[{"value":"'+ps[0].Id+'","label":"'+ps[0].Label+'"}]';
        Test.startTest();
            auditTrailController.getAdutiDetails('','','FLS');
            auditTrailController.getAdutiDetails('','','');
            auditTrailController.getPermissionSets();
            permissionSetController.getAllObjects();
            Utility_FieldInfo.getFieldsDataType('Account');
            permissionSetController.getPermissionInfo(inp, 'Account', true);
            permissionAuditController.getAllObjects();
            permissionAuditController.getObjectFields('Account');
            permissionAuditController.getAccessDetails('Account', 'Name');
        Test.stopTest();
    }
}