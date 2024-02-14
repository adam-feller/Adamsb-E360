@IsTest
public with sharing class WarehouseDAOTest {

    @TestSetup
    private static void setup(){
        Warehouse__c testWarehouse = TestFactory.createWarehouse('PDC Warehouse', null, 'PDC' , null, null, null, null, null);
    }

    static Warehouse__c getWarehouse(String Name){
        return [SELECT Id, Name
                FROM Warehouse__c
                LIMIT 1];
    }

    @isTest
    static void testGetWarehouseByIds(){
        Warehouse__c testWarehouse = getWarehouse('PDC Warehouse');

        Test.startTest();
            List<Warehouse__c> warehouseList = warehouseDAO.getWarehousesByIds(new Set<Id>{testWarehouse.Id});
        Test.stopTest();

        System.assertEquals(warehouseList.size(), 1, 'warehouseList should return 1 record');
    }

    @isTest
    static void testGetWarehouseByName(){
        Warehouse__c testWarehouse = getWarehouse('PDC Warehouse');

        Test.startTest();
            List<Warehouse__c> warehouseList = warehouseDAO.getWarehouseByName(testWarehouse.Name);
        Test.stopTest();

        System.assertEquals(warehouseList.size(), 1, 'warehouseList should return 1 record');
    }

    @isTest
    static void testGetAllWarehouses(){

        Test.startTest();
            List<Warehouse__c> warehouseList = warehouseDAO.getAllWarehouses();
        Test.stopTest();

        System.assertEquals(warehouseList.size(), 1, 'warehouseList should return 1 record');
    }




}