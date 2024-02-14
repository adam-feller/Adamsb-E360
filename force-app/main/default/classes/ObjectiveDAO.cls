public without sharing class ObjectiveDAO {

    public static List<Objective__c> getObjectives() {
        return [SELECT Id, Name, Priority__c, BU__c, Objective_Type__c, Start_Date__c, End_Date__c, Parent_Child_Independent__c, 
                Child_Objective_Product_Selection_Type__c, Account_Universe_Selection__c, Parent_Objective__c, Update_Allowed__c, PowerBI_Report_Link__c
                FROM Objective__c];
    }

    public static List<Objective__c> getObjectivesByIds(Set<Id> objectiveIds) {
        return [SELECT Id, Objective_Type__c, FiltersInclude__c, FiltersLong__c, ProductFiltersInclude__c, ProductFiltersLong__c,
                Child_Objective_Product_Selection_Type__c, Parent_Objective__c, Parent_Child_Independent__c
                FROM Objective__c
                WHERE Id IN :objectiveIds];
    }

    @AuraEnabled
    public static List<Objective__c> getObjectiveById(Id objectiveId) {
        return [SELECT Id, Name, Picture_Required__c, Requires_Approval__c, DSOF_Qualifier__c, Display_Location__c, Objective_Type__c, BU__c,
                Status__c, Goal_Type__c, Start_Date__c, End_Date__c, Notes__c, Draft_Bonus__c, Format_Type__c, Sub_Type__c, 
                CBS_WCD_Pointers__c, Case_Minimum__c, Number_of_Photos_Allowed__c, Programming__c, Payout_Notes__c,
                Qualifier_Notes__c, FiltersInclude__c, FiltersLong__c, ProductFiltersInclude__c, ProductFiltersLong__c, Lookback_Period__c, 
                Parent_Child_Independent__c, Child_Objective_Product_Selection_Type__c, Account_Universe_Selection__c, Parent_Objective__c, 
                Update_Allowed__c, PowerBI_Report_Link__c, RecordTypeId
                FROM Objective__c
                WHERE Id = :objectiveId];
    }

    public static List<Product2> getObjectiveProducts(String recordId) {
        List<Product2> objProdList = [SELECT Id FROM Product2 WHERE Id IN (SELECT Product__c FROM Objective_Product__c WHERE Objective__c = :recordId)];
        List<id> prodIdList = new List<id>();
        if (objProdList.size() > 0) {
            for (Product2 singleProd : objProdList) {
            	prodIdList.add(singleProd.Id);
         	}
        } else {
            prodIdList = null;
        }        
        return [SELECT Id, Name, BrewerId__r.Name, BrandId__r.Name, Subbrandid__r.Name, DRAFT_OR_PACKAGE__c, SKU_Package_Type__c, SKU_External_Id__c, 
                Product_Description_VIP__c, Product_Description_Beerline__c, RecordTypeId 
                FROM Product2 WHERE (Id IN :prodIdList OR BrandId__c IN :prodIdList OR Subbrandid__c IN :prodIdList)];
    }


    public static List<Objective__c> getObjectiveByStatusReadyForExecution() {
        return [SELECT Id 
                FROM Objective__c 
                WHERE Processed__c = false 
                AND Status__c = 'Ready For Execution'];
    }

    public static List<Objective__c> getObjectivesByBUAccountSync(Set<String> buSet) {
        return [SELECT Id, Objective_Type__c, FiltersLong__c, FiltersInclude__c, ProductFiltersLong__c, ProductFiltersInclude__c, Picture_Required__c
                FROM Objective__c
                WHERE End_Date__c >= TODAY
                AND Id IN (SELECT Objective__c FROM Objective_Location__c WHERE BU__c IN :buSet)];
    }

    public static List<Objective__c> updateObjectives(List<Objective__c> objectivesToUpdate) {
        update objectivesToUpdate;
        return objectivesToUpdate;
    }

    public static List<Objective__c> insertObjectives(List<Objective__c> objectivesToInsert) {
        insert objectivesToInsert;
        return objectivesToInsert;
    }
}