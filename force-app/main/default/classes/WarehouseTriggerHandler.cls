public class WarehouseTriggerHandler {
    public static void beforeInsertHandler(List<Warehouse__c> newWarehouses){
        setCutoffOffsetDays(newWarehouses);
    }
    
    public static void beforeUpdateHandler(List<Warehouse__c> newWarehouses, Map<Id, Warehouse__c> oldWarehousesMap){
        setCutoffOffsetDays(newWarehouses);
    }
    
	public static void afterUpdateHandler(List<Warehouse__c> newWarehouses, Map<Id, Warehouse__c> oldWarehousesMap){
        //To update future Outbound Calls if the Primary ISR changes
        Set<Id> warehouseIds = new Set<Id>();
        for (Warehouse__c wh : newWarehouses) {            
            //Only need to call the updateOutboundCallTasks method if the Primary ISR has changed
            if (wh.ISR_1__c != oldWarehousesMap.get(wh.Id).ISR_1__c) {
                warehouseIds.add(wh.Id);
            }
        }
        if (warehouseIds.size() > 0) {
            updateOutboundCallTasks(warehouseIds);
        }
    }
    
    public static void setCutoffOffsetDays(List<Warehouse__c> newWarehouses){
        for (Warehouse__c wrh: newWarehouses){
            wrh.CutoffOffsetSun__c = calculateOffset(0,wrh);
            wrh.CutoffOffsetMon__c = calculateOffset(1,wrh);
            wrh.CutoffOffsetTue__c = calculateOffset(2,wrh);
            wrh.CutoffOffsetWed__c = calculateOffset(3,wrh);
            wrh.CutoffOffsetThu__c = calculateOffset(4,wrh);
            wrh.CutoffOffsetFri__c = calculateOffset(5,wrh);
            wrh.CutoffOffsetSat__c = calculateOffset(6,wrh);
        }
    }
    
    /*
     * deliveryDay
     * 0 - Sunday, 1 - Monday
     */
    private static integer calculateOffset(Integer deliveryDay, Warehouse__c wrh){
       Integer min = 7; 
       if (wrh.SunLeadDays__c == math.mod(7+deliveryDay,7) &&  wrh.SunLeadDays__c != 0) min=math.min(min,(Integer) wrh.SunLeadDays__c);
       if (wrh.MonLeadDays__c == math.mod(6+deliveryDay,7) &&  wrh.MonLeadDays__c != 0) min=math.min(min,(Integer) wrh.MonLeadDays__c);
       if (wrh.TueLeadDays__c == math.mod(5+deliveryDay,7) &&  wrh.TueLeadDays__c != 0) min=math.min(min,(Integer) wrh.TueLeadDays__c);
       if (wrh.WedLeadDays__c == math.mod(4+deliveryDay,7) &&  wrh.WedLeadDays__c != 0) min=math.min(min,(Integer) wrh.WedLeadDays__c);
       if (wrh.ThuLeadDays__c == math.mod(3+deliveryDay,7) &&  wrh.ThuLeadDays__c != 0) min=math.min(min,(Integer) wrh.ThuLeadDays__c);
       if (wrh.FriLeadDays__c == math.mod(2+deliveryDay,7) &&  wrh.FriLeadDays__c != 0) min=math.min(min,(Integer) wrh.FriLeadDays__c);
       if (wrh.SatLeadDays__c == math.mod(1+deliveryDay,7) &&  wrh.SatLeadDays__c != 0) min=math.min(min,(Integer) wrh.SatLeadDays__c);
       
       system.debug(min);
       return min == 7 ? null : min;
    }
    
    private static void updateOutboundCallTasks(Set<Id> warehouseIds) {
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        //Put all the Accounts for the Warehouses in a Map
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account a :  [SELECT Id, Warehouse_Lookup__r.Id, Warehouse_Lookup__r.ISR_1__c FROM Account WHERE Warehouse_Lookup__c IN :warehouseIds]) {
            accountMap.put(a.Id, a);
        }
       
        BatchUpdateCallPrimaryISR batchUpdateCallPrimaryISR = new BatchUpdateCallPrimaryISR();        
        batchUpdateCallPrimaryISR.accountMap = accountMap;
        batchUpdateCallPrimaryISR.accountIds = accountMap.keySet();
        batchUpdateCallPrimaryISR.today = System.today();
     	batchUpdateCallPrimaryISR.query = 'SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId IN :accountIds AND ActivityDate > :today AND Status = \'Open\'' + 
            ' AND RecordTypeId = \'' + callTaskRecordTypeId + '\'';
        System.debug(batchUpdateCallPrimaryISR.query);
        Database.executebatch(batchUpdateCallPrimaryISR, 1000);       
    }   
    
}