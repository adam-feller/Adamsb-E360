public without sharing class DeliveryDateDAO {

    public static List<Delivery_Date__c> getDeliveryDatesByIds(Set<Id> deliveryDateIds){
        return [SELECT Id, Delivery_Date__c, Account__c, Original_Delivery_Date__c, Status__c
                FROM Delivery_Date__c 
                WHERE Id IN :deliveryDateIds
                ORDER BY Delivery_Date__c];
    }

    public static List<Delivery_Date__c> getDeliveryDatesByAccountIds(Set<Id> accountIds){
        return [SELECT Id, Account__c, Delivery_Date__c, Original_Delivery_Date__c, Account__r.Warehouse__c
                FROM Delivery_Date__c 
                WHERE Account__c IN :accountIds
                ];
    }

    public static List<Delivery_Date__c> getDeliveryDatessByWarehouseDeliveryDate(Set<String> warehouses, Date deliveryDate, List<String> frequencyList, List<String> citiesList){
        return [SELECT Id, Account__c, Delivery_Date__c, Account__r.Warehouse__c
                FROM Delivery_Date__c
                WHERE Account__r.Warehouse__c IN :warehouses
                AND Account__r.Delivery_Frequency_Type__c IN :frequencyList
                AND Account__r.BillingCity IN :citiesList
                AND Delivery_Date__c = :deliveryDate 
                ];
    }

    public static List<Delivery_Date__c> getDeliveryDatesAccountDateStatus(Set<Id> accountIds, Date deliveryDateFilter, String status){
        return [SELECT Id, Delivery_Date__c, Account__c, Original_Delivery_Date__c, Status__c
                FROM Delivery_Date__c 
                WHERE Account__c IN :accountIds
                AND Delivery_Date__c >= :deliveryDateFilter
                AND Status__c = :status
                ORDER BY Delivery_Date__c];
    }

    public static List<Delivery_Date__c> getDeliveryDatesAccountDate(Set<Id> accountIds, Date deliveryDateFilter){
        return [SELECT Id, Delivery_Date__c, Account__c, Original_Delivery_Date__c, Status__c
                FROM Delivery_Date__c 
                WHERE Account__c IN :accountIds
                AND Delivery_Date__c >= :deliveryDateFilter
                ORDER BY Delivery_Date__c];
    }

    public static List<Delivery_Date__c> updateDeliveryDates(List<Delivery_Date__c> deliveryDatesToUpdate){
        update deliveryDatesToUpdate;
        return deliveryDatesToUpdate;
    }

    public static List<Delivery_Date__c> insertDeliveryDates(List<Delivery_Date__c> deliveryDatesToInsert){
        insert deliveryDatesToInsert;
        return deliveryDatesToInsert;
    }

    public static List<Delivery_Date__c> deleteDeliveryDates(List<Delivery_Date__c> deliveryDatesToInsert){
        delete deliveryDatesToInsert;
        return deliveryDatesToInsert;
    }
}