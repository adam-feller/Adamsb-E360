public class ScheduleBatchUpdateObjectives implements Schedulable {

    public void execute(SchedulableContext sc) {
        BatchUpdateObjectives batchUpdateObjectives = new BatchUpdateObjectives();
        batchUpdateObjectives.query = 'SELECT Id, Name, Objective_Type__c, Picture_Required__c, FiltersLong__c, FiltersInclude__c, ProductFiltersLong__c,' + 
                				 ' ProductFiltersInclude__c, Display_Location__c, Parent_Child_Independent__c,' + 
                				 ' (SELECT Id, BU__c, Warehouse__c, SalesOrg__c FROM Objective_Locations__r)' +  	//Get related Locations
                                 ' FROM Objective__c' +
                                 ' WHERE Active__c = true AND Status__c = \'Ready for Execution\' and Parent_Child_Independent__c != \'Cascade\'';
        Database.executebatch(batchUpdateObjectives, 5);   //Keep batch size low to avoid too many soql queries/too many query rows
    }
    
}