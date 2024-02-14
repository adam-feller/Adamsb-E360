public without sharing class ProductDAO {

    public static List<Product2> getProductByBrandNames(List<String> productBrands) {
        return [SELECT Id 
                FROM Product2 
                WHERE Brand__c IN :productBrands];
    }

    public static List<Product2> getProductByIds(Set<String> productIds) {
        return [SELECT Id, SKU_External_Id__c, Name, Territories__c, RecordTypeId, Price__c, QuantityUnitOfMeasure, Units_per_Case__c, isActive
                FROM Product2 
                WHERE Id IN :productIds];
    }

    public static List<Product2> getProductByIdSubBrandBrand(Set<String> skuIds, Set<String> subbrandIds, Set<String> brandIds, Id skuProductRecordTypeId) {
        return [SELECT Id, Name, Territories__c, RecordTypeId, Subbrandid__c, BrandId__c, Pkg_Name__c, QuantityUnitOfMeasure
                FROM Product2 
                WHERE (Id IN :skuIds
                OR Subbrandid__c IN :subbrandIds
                OR BrandId__c IN :brandIds)
                AND RecordTypeId = :skuProductRecordTypeId];
    }

    public static List<Product2> getProductByExternalIds(Set<String> productExternalIds) {
        return [SELECT Id, SKU_External_Id__c, Name, Pkg_Name__c, Cases_per_layer__c, Cases_per_pallet__c, Price__c, SKU_Package_Type__c, Territories__c, isActive,
                Case_equivalent__c, Sub_Style__c, Seasonal__c, Draft_Or_Package__c, QuantityUnitOfMeasure,Subbrandid__c, BrandId__c, 
                Subbrandid__r.Subbrand_External_Id__c, BrandId__r.Brand_External_Id__c, Subbrand_External_Id__c, Brand_External_Id__c,Units_per_Case__c
                FROM Product2 
                WHERE SKU_External_Id__c IN :productExternalIds];
    }
    
    public static List<Product2> getProductByExternalIdsCBS(Set<String> productExternalIds, List<Integer> SalesPointer) {
        return [SELECT Id, SKU_External_Id__c, Name, Territories__c, isActive
                FROM Product2 
                WHERE SKU_External_Id__c IN :productExternalIds AND Product2.Sales_Pointer__c IN :SalesPointer];
    }
    
    public static List<Product2> getProductByBrandExternalIds(Set<String> productBrandExternalIds) {
        return [SELECT Id, Brand_External_Id__c, BrandId__r.Brand_External_Id__c, Name, Territories__c, isActive, RecordTypeId
                FROM Product2 
                WHERE BrandId__r.Brand_External_Id__c IN :productBrandExternalIds
                OR Brand_External_Id__c IN :productBrandExternalIds];
    }

    public static List<Product2> getProductByBrandExternalIdsCBS(Set<String> productBrandExternalIds, List<Integer> SalesPointer) {
        return [SELECT Id, Brand_External_Id__c, BrandId__r.Brand_External_Id__c, Name, Territories__c, isActive, RecordTypeId
                FROM Product2 
                WHERE  Product2.Sales_Pointer__c IN :SalesPointer
                AND (BrandId__r.Brand_External_Id__c IN :productBrandExternalIds
                OR Brand_External_Id__c IN :productBrandExternalIds)];
    }

    public static List<Product2> getProductBySubBrandExternalIds(Set<String> productSubBrandExternalIds) {
        return [SELECT Id, Subbrand_External_Id__c, Subbrandid__r.Subbrand_External_Id__c, Name, Territories__c, BrandId__c,
                BrewerId__c, Subbrandid__c, Subbrandid__r.SubbrandId__c, Pkg_Name__c, QuantityUnitOfMeasure, isActive, RecordTypeId
                FROM Product2 
                WHERE Subbrand_External_Id__c IN :productSubBrandExternalIds
               	OR Subbrandid__r.Subbrand_External_Id__c IN :productSubBrandExternalIds];

    }

    public static List<Product2> getProductBySubBrandExternalIdsCBS(Set<String> productSubBrandExternalIds, List<Integer> SalesPointer) {
        return [SELECT Id, Subbrand_External_Id__c, Subbrandid__r.Subbrand_External_Id__c, Name, Territories__c, BrandId__c,
                BrewerId__c, Subbrandid__c, Subbrandid__r.SubbrandId__c, Pkg_Name__c, QuantityUnitOfMeasure, isActive, RecordTypeId
                FROM Product2 
                WHERE Product2.Sales_Pointer__c IN :SalesPointer
                AND (Subbrand_External_Id__c IN :productSubBrandExternalIds
                OR Subbrandid__r.Subbrand_External_Id__c IN :productSubBrandExternalIds)];

    }

    public static List<Product2> getBrandByBrandExternalIds(Set<String> productBrandExternalIds, Id brandRecordTypeId) {
        return [SELECT Id, Brand_External_Id__c, BrandId__r.Brand_External_Id__c, Name, Territories__c, isActive
                FROM Product2 
                WHERE Brand_External_Id__c IN :productBrandExternalIds
                AND RecordTypeId = :brandRecordTypeId];
    }

    public static List<Product2> getAllActiveSKUProducts() {
        Id skuRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
        return [SELECT Id, BrewerId__r.Name, BrandId__r.Name, Subbrandid__r.Name, Name, Product_Description_Beerline__c, Product_Description_VIP__c, 
                SKU_Package_Type__c, DRAFT_OR_PACKAGE__c, SKU_External_Id__c, QuantityUnitOfMeasure, Territories__c 
                FROM Product2 WHERE IsActive = true AND RecordTypeId = :skuRecordTypeId 
                ORDER BY BrewerId__r.Name, BrandId__r.Name, Subbrandid__r.Name LIMIT 50000];
    }

    public static List<Product2> getSubBrandByBrandExternalIds(Set<String> productBrandExternalIds, Id subbrandRecordTypeId) {
        return [SELECT Id,  Subbrand_External_Id__c,Subbrandid__r.Brand_External_Id__c, Name, Territories__c, isActive
                FROM Product2 
                WHERE Subbrand_External_Id__c IN :productBrandExternalIds
                AND RecordTypeId = :subbrandRecordTypeId];
    }

}