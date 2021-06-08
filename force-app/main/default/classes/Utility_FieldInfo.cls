public with sharing class Utility_FieldInfo {
    public static Map<String,FieldDataType> getFieldsDataType(String ObjectName) {
        Map<String,FieldDataType> dataTypeResult = new Map<String,FieldDataType>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
        for (Schema.SObjectField sfield: fieldMap.Values()) {
            String dType;
            Schema.DescribeFieldResult dfield = sfield.getDescribe();

            if(dfield.getType() == Schema.DisplayType.Reference) {
                String relationObject;
                for (Schema.SObjectType reference: dfield.getReferenceTo()) {
                    if(dfield.getRelationshipOrder() == 0 || dfield.getRelationshipOrder() == 1) {
                        dType = 'Master-Detail (' + reference.getDescribe().getLabel() + ')'; 
                        dataTypeResult.put(dfield.getName(), new FieldDataType(dfield.getLabel(),dType));
                    } else {
                        if(String.isEmpty(relationObject)) {
                            relationObject = reference.getDescribe().getLabel();
                        } else {
                            relationObject += ',' + reference.getDescribe().getLabel();
                        }
                        dType = 'Lookup(' + relationObject + ')'; 
                        dataTypeResult.put(dfield.getName(), new FieldDataType(dfield.getLabel(),dType));
                    }
                }
            }

            else if(dfield.isCalculated()){
                if(dfield.getCalculatedFormula() == null){
                    dType = 'Roll-Up Summary'; 
                }
                else if(dfield.getType() == Schema.DisplayType.Double){
                    dType = 'Formula (Number)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.Boolean){
                    dType = 'Formula (Checkbox)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.DateTime){
                    dType = 'Formula (Date/Time)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.Date){
                    dType = 'Formula (Date)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.Percent){
                    dType = 'Formula (Percent)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.Currency){
                    dType = 'Formula (Currency)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.Time){
                    dType = 'Formula (Time)'; 
                }
                else if(dfield.getType() == Schema.DisplayType.String){
                    dType = 'Formula (Text)'; 
                }
            }

            else if(dfield.getType() == Schema.DisplayType.TextArea) {
                if(dfield.getLength() <= 255 && !dfield.isHtmlFormatted()) {
                    dType = 'Text Area('+dfield.getLength()+')';
                }
                else if((dfield.getLength() >= 256 && dfield.getLength() <= 131072) && !dfield.isHtmlFormatted()) {
                    dType = 'Long Text Area('+dfield.getLength()+')';
                }
                else if((dfield.getLength() >= 256 && dfield.getLength() <= 131072) && dfield.isHtmlFormatted()) {
                    dType = 'Rich Text Area('+dfield.getLength()+')';
                }
            }
            
            else if(dfield.isAutoNumber()) {
                dType = 'AutoNumber';
            }
            else if(dfield.getType() == Schema.DisplayType.Picklist ) {
                dType = 'Picklist';
            }       
            else if(dfield.getType() == Schema.DisplayType.String) {
                dType = 'Text('+dfield.getLength()+')';
            }
            else if(dfield.getType() == Schema.DisplayType.Currency ) {
                dType = 'Currency('+ (dfield.getPrecision() - dfield.getScale()) + ', ' + dfield.getScale() + ')';
            }
            else if(dfield.getType() == Schema.DisplayType.DateTime ) {
                dType = 'Date/Time';
            }
            else if(dfield.getType() == Schema.DisplayType.Date ) {
                dType = 'Date';
            }
            else if(dfield.getType() == Schema.DisplayType.MultiPicklist ) {
                dType = 'Picklist (Multi-Select)';
            }
            else if(dfield.getType() == Schema.DisplayType.Time ) {
                dType = 'Time';
            }
            else if(dfield.getType() == Schema.DisplayType.Email ) {
                dType = 'Email';
            }
            else if(dfield.getType() == Schema.DisplayType.Phone ) {
                dType = 'Phone';
            }
            else if(dfield.getType() == Schema.DisplayType.Address ) {
                dType = 'Address';
            }
            else if(dfield.getType() == Schema.DisplayType.EncryptedString ) {
                dType = 'Text (Encrypted)('+dfield.getLength()+')';
            }
            else if(dfield.getType() == Schema.DisplayType.URL ) {
                dType = 'URL';
            }
            else if(dfield.getType() == Schema.DisplayType.Integer){
                dType = 'Integer('+dfield.getDigits()+', '+dfield.getPrecision()+')';
            }
            else if(dfield.getType() == Schema.DisplayType.Double){
                dType = 'Number('+ (dfield.getPrecision() - dfield.getScale()) + ', ' + dfield.getScale() + ')';
            }
            else if(dfield.getType() == Schema.DisplayType.Boolean){
                dType = 'Checkbox'; 
            }
            else if(dfield.getType() == Schema.DisplayType.Id){
                dType = 'Id'; 
            }
            else{
                dType = 'Unknown';
            }
            dataTypeResult.put(dfield.getName(), new FieldDataType(dfield.getLabel(),dType));
            
        }
        
        return dataTypeResult;
    }

    public class FieldDataType{
        @AuraEnabled
        public String fieldLabel {get; set;}
        @AuraEnabled
        public String fieldDataType {get; set;}
        public FieldDataType(String fieldLabel, String fieldDataType){
            this.fieldLabel = fieldLabel;
            this.fieldDataType = fieldDataType;
        }
    }
}