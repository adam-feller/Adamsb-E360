public with sharing class RetailStoreDAO {

    public static List<RetailStore> getRetailStoreByIds(Set<Id> retailStoreIds){
        return [SELECT Id, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM RetailStore 
                WHERE Id IN :retailStoreIds];
    }

    public static List<RetailStore> getRetailStoreByBUAndWarehouse(List<String> bu, List<String> warehouse){
        return [SELECT Id, Name, Chain_Independent__c, Premise__c, VIP_Account_Number__c, Class__c, AccountId
                FROM RetailStore
                WHERE Beer_Company__c IN :bu
                AND Warehouse__c IN :warehouse];
    }

    public static String getStoreNumberById(Id retailStoreId) {
        String storeNbr = [SELECT VIP_Composite_Key__c FROM RetailStore WHERE Id = : retailStoreId LIMIT 1].VIP_Composite_Key__c;
        return storeNbr;
    }

    public static List<RetailStore> getRetailStoreByAccountIds(List<String> accountIds){
        return [SELECT Id 
                FROM RetailStore 
                WHERE AccountId IN :accountIds];
    }

    public static Map<String, RetailStore> getRetailStoreByStoreNumber(Set<String> storeNumber) {
        List <RetailStore> retailStoreList = [
                                    SELECT Id, Name, VIP_Composite_Key__c, Address__c, City__c, State__c, Zip_Code__c
                                    FROM RetailStore
                                    WHERE VIP_Composite_Key__c IN : storeNumber
        ];

        Map<String, RetailStore> result = new Map<String, RetailStore>();
        for(RetailStore retailstore : retailStoreList){
            result.put(retailstore.VIP_Composite_Key__c, retailstore);
        }

        return result;
    }
}