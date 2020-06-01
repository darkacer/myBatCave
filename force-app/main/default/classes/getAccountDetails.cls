public with sharing class getAccountDetails {
    public getAccountDetails() {
    }

    @AuraEnabled
    public static List<Account> getAccounts(){
        return [Select id, name from Account limit 12];
    }
    @AuraEnabled
    public static List<Account> getAccountsKey(String key){
        System.debug('this is me!!' + key);
        return [Select id, name from Account where name like :key];
    }

    @AuraEnabled
    public static List<Account> getAccountsdate(Date start, Date enddate){
        return [Select id, name from Account where createddate > :start AND createddate < :enddate];
    }

    @AuraEnabled
    public static List<Opportunity> getOpportinitysdate(Date start, Date enddate){
        return [Select id, name from Opportunity where createddate > :start AND createddate < :enddate];
    }
}