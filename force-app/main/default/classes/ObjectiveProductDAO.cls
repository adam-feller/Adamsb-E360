public without sharing class ObjectiveProductDAO {

    public static List<Objective_Product__c> getObjectiveProductByObjectiveIds(Set<Id> objectiveIds){
        return [SELECT Id, Product__r.Name, Product__r.Id, Product__r.Brand_Name__c, Ad_Price__c , Product__c, Objective__c, Priority__c, Manual_Product_Upload__c, 
                Percentage__c, Product__r.Territories__c, Product__r.RecordTypeId, Snowflake_Processing__c, Product__r.BrandId__c, Product__r.Subbrandid__c
                FROM Objective_Product__c 
                WHERE Objective__c IN :objectiveIds];
    }

    public static List <Objective_Product__c> fetchObjectiveProducts(String accountId){
        return [Select ID, Product__c, Ad_Price__c, Product__r.Name, Objective__c, Objective__r.End_Date__c, Objective__r.Status__c, Priority__c FROM Objective_Product__c 
                WHERE Objective__c in (SELECT Objective__c FROM Objective_Account__c WHERE Account__c = :accountId 
                AND (Objective__r.Start_Date__c < TODAY AND Objective__r.End_Date__c > TODAY))];
    
    }

    public static List<Objective_Product__c> insertObjectiveProducts(List<Objective_Product__c> objectiveProductsToInsert){
        insert objectiveProductsToInsert;
        return objectiveProductsToInsert;
    }

    public static List<Objective_Product__c> updateObjectiveProducts(List<Objective_Product__c> objectiveProductsToUpdate){
        update objectiveProductsToUpdate;
        return objectiveProductsToUpdate;
    }

    public static List<Objective_Product__c> deleteObjectiveProducts(List<Objective_Product__c> objectiveProductsToDelete){
        delete objectiveProductsToDelete;
        return objectiveProductsToDelete;
    }
}