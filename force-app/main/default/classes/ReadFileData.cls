public with sharing class ReadFileData {
    public ReadFileData() {

    }

    @AuraEnabled
    public static String readFileFromRecord(String recordId) {
        ContentDocumentLink contentDocumentLink = [
            SELECT id, ContentDocumentId, ContentDocument.Description, 
            ContentDocument.Title, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = '0017F00002nb4ktQAA' 
            LIMIT 1
        ];

        System.debug('file id is ' + contentDocumentLink.ContentDocumentId);
        ContentVersion cv = [
            SELECT VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId = :contentDocumentLink.ContentDocumentId 
            AND IsLatest = true
            LIMIT 1
        ];
        System.debug(cv.VersionData);
        Integer stdPrint = 400;
        String s = EncodingUtil.base64Encode(cv.VersionData);
        Integer i = 0;
        while(i < s.length()) {
            if(i + stdPrint > s.length()) system.debug(s.substring(i, s.length()));
            else system.debug(s.substring(i, i + stdPrint));
            i += stdPrint;
        }

        System.debug(s);

        return s;
    }
}