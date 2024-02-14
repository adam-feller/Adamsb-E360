public without sharing class StoreVisitTriggerHelper {
    
    public static void beforeInsert(List<CVS_Store_Visit__c> storeVisitList){
        StoreVisitTriggerHandler.formulaToFieldStamp(storeVisitList);
    }

    public static void beforeUpdate(List<CVS_Store_Visit__c> storeVisitList, Map<Id, CVS_Store_Visit__c> storeVisitListOldMap){
        StoreVisitTriggerHandler.formulaToFieldStamp(storeVisitList);
    }
}