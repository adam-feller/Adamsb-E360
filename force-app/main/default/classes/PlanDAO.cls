public without sharing class PlanDAO {

    public static List<Plan__c> getPlansForFilterDate(Date filterDate){
        return [SELECT Id, Name, Original_Delivery_Date__c, Call_Dates__c, Delivery_Percentages__c,
                Delivery_Frequencies__c, Premise_Types__c, Sell_Types__c, Warehouses__c, Delivery_Dates__c,
                Call_Percentages__c, Reschedule_Reason__c, Cities_Selected__c
                FROM Plan__c
                WHERE Original_Delivery_Date__c >= :filterDate];
    }

    public static List<Plan__c> getPlansByIds(Set<Id> planIds){
        return [SELECT Id, Name, Original_Delivery_Date__c, Call_Dates__c, Delivery_Percentages__c,
                Delivery_Frequencies__c, Premise_Types__c, Sell_Types__c, Warehouses__c, Delivery_Dates__c,
                Call_Percentages__c, Reschedule_Reason__c, Cities_Selected__c
                FROM Plan__c
                WHERE Id IN :planIds];
    }

    public static List<Plan__c> insertPlans(List<Plan__c> plansToInsert){
        insert plansToInsert;
        return plansToInsert;
    }

    public static List<Plan__c> updatePlans(List<Plan__c> plansToUpdate){
        update plansToUpdate;
        return plansToUpdate;
    }
}