public with sharing class ShoppingCart {
    public ShoppingCart() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(){
        List<Product2> productList = [Select Id, Name, ProductCode, (Select id, UnitPrice from PricebookEntries limit 1) From Product2 Limit 20];
        for(Integer i = 0; i < productList.size(); i++) {
            if (productList[i].PricebookEntries.size() == 0) productList.remove(i);
        }
        return productList;
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getProuctById(Id Id){
        return [Select Id, Name, ProductCode, (Select id, UnitPrice from PricebookEntries limit 1) From Product2 Where Id = :Id Limit 1];
    }
}
