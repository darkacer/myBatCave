public with sharing class ShoppingCart {
    public ShoppingCart() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(){
        return [Select Id, Name, ProductCode From Product2 Limit 20];
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getProuctById(Id Id){
        return [Select Id, Name, ProductCode From Product2 Where Id = :Id Limit 1];
    }
}
