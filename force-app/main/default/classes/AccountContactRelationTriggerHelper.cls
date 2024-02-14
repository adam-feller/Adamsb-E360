public class AccountContactRelationTriggerHelper {

    public static void beforeInsert(List<AccountContactRelation> acrList){
        AccountContactRelationTriggerHandler.processAccountContactRelationIntegration(acrList);
        
    }

    public static void beforeUpdate(List<AccountContactRelation> acrList, Map<Id, AccountContactRelation> acrOldMap){
        AccountContactRelationTriggerHandler.processAccountContactRelationIntegration(acrList);
        
    }
    
    public static void afterInsert(List<AccountContactRelation> acrList){
        AccountContactRelationTriggerHandler.processAccountRollup(acrList, new Map<Id, AccountContactRelation>());
        
    }

    public static void afterUpdate(List<AccountContactRelation> acrList, Map<Id, AccountContactRelation> acrOldMap){
        AccountContactRelationTriggerHandler.processAccountRollup(acrList, acrOldMap);
    }

    public static void afterDelete(List<AccountContactRelation> acrList){
        AccountContactRelationTriggerHandler.processAccountRollup(acrList, new Map<Id, AccountContactRelation>());

    }
}