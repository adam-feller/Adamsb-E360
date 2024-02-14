public with sharing class WarehouseDAO {

    public static List<Warehouse__c> getWarehousesByIds(Set<Id> warehouseIds){
        return  [SELECT ID, Name, Warehouse_ID__c, Warehouse_Dim_ID__c, ISR_1__c, LayerPalletThreshold__c, MonLeadDays__c, TueLeadDays__c, 
                WedLeadDays__c, ThuLeadDays__c, FriLeadDays__c, SatLeadDays__c, SunLeadDays__c, OrderCutoff__c, Geographic_Region__c,
                CutoffOffsetFri__c, CutoffOffsetMon__c, CutoffOffsetSat__c, CutoffOffsetSun__c, CutoffOffsetThu__c, CutoffOffsetTue__c, CutoffOffsetWed__c
                FROM Warehouse__c
                WHERE Id IN :warehouseIds];
    }

    public static List<Warehouse__c> getWarehouseByName(String warehouseName){
        return  [SELECT ID, Name, Warehouse_ID__c, Warehouse_Dim_ID__c, ISR_1__c
                FROM Warehouse__c
                WHERE name = :warehouseName];
    }

    public static List<Warehouse__c> getAllWarehouses(){
        return [SELECT ID, Name, Warehouse_ID__c, Warehouse_Dim_ID__c, ISR_1__c
                FROM Warehouse__c];
    }
}