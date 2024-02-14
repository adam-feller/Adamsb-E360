public without sharing class DisplayProductDAO {

    public static List <Display_Product__c> fetchDisplayProduct(Set<Id> accountIds){
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        return [SELECT Id, Name, Number_of_Cases__c, Ad_Price__c, Primary_Secondary__c, Account__c, Start_Date__c,
                End_Date__c, Product__r.Name, Account__r.OwnerId, Percentage__c, Product__c, Family_Brand_Pack__c
                FROM Display_Product__c
                WHERE Account__c IN :accountIds
                AND (Start_Date__c <= TODAY AND End_Date__c >= TODAY)
                AND RecordTypeId = :processedDisplayProductRecordTypeId
                ORDER BY Primary_Secondary__c ASC, Product__r.Name ASC];
    }

    public static List <Display_Product__c> fetchDisplayProductByUserId(Set<Id> userIds){
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        return [SELECT Id, Name, Number_of_Cases__c, Ad_Price__c, Primary_Secondary__c, Account__c, Start_Date__c,
                End_Date__c, Product__r.Name, Account__r.OwnerId, Account__r.Name, Percentage__c, Product__c, Family_Brand_Pack__c
                FROM Display_Product__c
                WHERE Account__r.OwnerId IN :userIds
                AND Number_of_Cases__c = null
                AND (Start_Date__c <= TODAY AND End_Date__c >= TODAY)
                AND RecordTypeId = :processedDisplayProductRecordTypeId];
    }

    public static List <Display_Product__c> fetchDisplayProductNullZeroCasesCBS(Set<Id> accountIds, List<Integer> SalesPointer){
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        return [SELECT Id, Name, Number_of_Cases__c, Ad_Price__c, Primary_Secondary__c, Account__c, Start_Date__c,
                End_Date__c, Product__r.Name, Account__r.OwnerId, Percentage__c, Product__c, Family_Brand_Pack__c
                FROM Display_Product__c
                WHERE Account__c IN :accountIds
                AND (Start_Date__c <= TODAY AND End_Date__c >= TODAY)
                AND (Number_of_Cases__c = null OR Number_of_Cases__c = 0)
                AND RecordTypeId = :processedDisplayProductRecordTypeId
                AND Product__r.Sales_Pointer__c IN :SalesPointer
                ORDER BY Primary_Secondary__c ASC, Product__r.Name ASC];
    }

    public static List <Display_Product__c> fetchDisplayProductNullZeroCases(Set<Id> accountIds){
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        return [SELECT Id, Name, Number_of_Cases__c, Ad_Price__c, Primary_Secondary__c, Account__c, Start_Date__c,
                End_Date__c, Product__r.Name, Account__r.OwnerId, Percentage__c, Product__c, Family_Brand_Pack__c
                FROM Display_Product__c
                WHERE Account__c IN :accountIds
                AND (Start_Date__c <= TODAY AND End_Date__c >= TODAY)
                AND (Number_of_Cases__c = null OR Number_of_Cases__c = 0)
                AND RecordTypeId = :processedDisplayProductRecordTypeId
                ORDER BY Primary_Secondary__c ASC];
    }

    public static List <Display_Product__c> getBatchDisplayProducts(Id batchRecordTypeId){
        return [SELECT Id, Product_Brand_Id__c, Chain__c, BU__c, Ad_Price__c, End_Date__c, Family_Brand_Pack__c,
                Percentage__c, Primary_Secondary__c, Start_Date__c, LastModifiedDate, Batch_Processed_DateTime__c,
                Processed__c, Sales_Org__c
                FROM Display_Product__c 
                WHERE Processed__c = false
                AND RecordTypeId = :batchRecordTypeId];
    }

    public static List <Display_Product__c> getBatchDisplayProductsUpdate(Id batchRecordTypeId){
        return [SELECT Id, Product_Brand_Id__c, Chain__c, BU__c, Ad_Price__c, End_Date__c, Family_Brand_Pack__c,
                Percentage__c, Primary_Secondary__c, Start_Date__c, LastModifiedDate, Batch_Processed_DateTime__c,
                Processed__c, Parent_Display_Product__c, Inactive__c, Sales_Org__c, Parent_Display_Product__r.Inactive__c
                FROM Display_Product__c 
                WHERE RecordTypeId = :batchRecordTypeId
                AND End_Date__c >= TODAY];
    }

    public static List<Display_Product__c> insertDisplayProducts(List<Display_Product__c> displayProductsToInsert){
        insert displayProductsToInsert;
        return displayProductsToInsert;
    }

    public static List<Display_Product__c> updateDisplayProducts(List<Display_Product__c> displayProductsToUpdate){
        update displayProductsToUpdate;
        return displayProductsToUpdate;
    }

    public static List<Display_Product__c> deleteDisplayProducts(List<Display_Product__c> displayProductsToDelete){
        delete displayProductsToDelete;
        return displayProductsToDelete;
    }
}