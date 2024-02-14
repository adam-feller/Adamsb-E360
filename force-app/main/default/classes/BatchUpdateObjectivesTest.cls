@isTest
private class BatchUpdateObjectivesTest {

    @TestSetup
    private static void setup(){
        //Create Account
        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        testAccount.Status__c = 'A';
        testAccount.RecordTypeId = retailRecordTypeId;
        testAccount.Sell_Type__c = 'INSIDE SALES';
        testAccount.Displayable_Status__c = 'Displayable';
        testAccount.Premise__c = 'Off Premise';
        testAccount.Warehouse__c = 'PDVA-CHANTILLY';
        //testAccount.SalesOrg__c = 'PVA';
        update testAccount;
		
        //Create Objective
        Objective__c testObj = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        testObj.Status__c = 'Ready for Execution';
        testObj.Case_Minimum__c = 6;
        testObj.FiltersInclude__c = '{"Display Status":true,"Premise Type":true}';
        testObj.FiltersLong__c = '{"Display Status":"01","Premise Type":"Off Premise"}';
        testObj.ProductFiltersInclude__c = '{"Brand":true}';
        testObj.ProductFiltersLong__c = '{"Brand":"COORS LIGHT"}';
        testObj.Goal_Type__c = 'House Goal';
        testObj.Number_of_Photos_Allowed__c = 25;
        testObj.Parent_Child_Independent__c = 'Local';
        update testObj;
        
        //Create Product
        Objective_Product__c testObjProd = TestFactory.createObjectiveProduct(testObj.Id, '01t6g000003eP0HAAU');
        
        //Create Location
        Objective_Location__c testObjLoc = TestFactory.createObjectiveLocation(testObj.Id, 'PVA', 'PDVA-CHANTILLY', 10);
        update testObjLoc;
    }

    @isTest
    static void testScheduleBatchUpdateObjectives(){
       
        Test.startTest();
        	BatchUpdateObjectives batchUpdateObjectives = new BatchUpdateObjectives();
        	batchUpdateObjectives.query = 'SELECT Id, Name, Objective_Type__c, Picture_Required__c, FiltersLong__c, FiltersInclude__c, ProductFiltersLong__c,' + 
                				 ' ProductFiltersInclude__c, Display_Location__c, Parent_Child_Independent__c,' + 
                				 ' (SELECT Id, BU__c, Warehouse__c, SalesOrg__c FROM Objective_Locations__r)' +  	//Get related Locations
                                 ' FROM Objective__c' +
                                 ' WHERE Active__c = true AND Status__c = \'Ready for Execution\' and Parent_Child_Independent__c != \'Cascade\'';
            Database.executebatch(batchUpdateObjectives);
        Test.stopTest();
        
        //Get all the Objective Accounts (should only be 1)
        List<Objective_Account__c> objAccList = [SELECT Id FROM Objective_Account__c];
		//Assertion
        System.assertEquals(0, objAccList.size(), 'One Objective Account should have been created.');
    }
}