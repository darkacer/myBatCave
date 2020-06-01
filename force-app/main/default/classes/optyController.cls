public class optyController {
	@AuraEnabled
    public static String getOppName(Id id) {
        return [SELECT ID, Name from Opportunity where ID =: id LIMIT 1][0].Name;
    }
    @AuraEnabled
    public static List<String> getOppDetails(Id id) {
        List<String> mylst = new List<String>();
        List<Opportunity> result = [SELECT ID, Name, CloseDate from Opportunity where ID =: id LIMIT 1];
        mylst.add(result[0].Name);
        mylst.add(String.Valueof(result[0].CloseDate));
        System.debug('helo' + mylst);
        return mylst;
    }
    
  
    @AuraEnabled
    public static Contact getContact() {
        return [select Id, Name from Contact where id = '0037F00000IP7e7QAD' Limit 1];
    }

}