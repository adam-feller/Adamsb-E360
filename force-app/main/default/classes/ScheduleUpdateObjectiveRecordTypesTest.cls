@isTest
private class ScheduleUpdateObjectiveRecordTypesTest {
 	
    @TestSetup
    private static void setup(){
        //Create a User
		Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole preSalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole salesManagerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User testSalesManager = TestFactory.createUser(systemAdminProfile.Id, salesManagerRole.Id, 'testSalesMgr1@gmail.com', null);       
        
        System.runAs(testSalesManager) {
        	//Create Account
        	Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        	Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        	testAccount.Status__c = 'A';
        	testAccount.RecordTypeId = retailRecordTypeId;
        	testAccount.Sell_Type__c = 'INSIDE SALES';
        	testAccount.Displayable_Status__c = 'Displayable';
        	testAccount.Premise__c = 'Off Premise';
        	testAccount.Warehouse__c = 'PDVA-CHANTILLY';
        	testAccount.SalesOrg__c = 'PVA';
        	update testAccount;
			
	        //Create Objective
	        Objective__c testObj = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
	        testObj.Status__c = 'Ready for Execution';
	        testObj.Case_Minimum__c = 6;
	        testObj.FiltersInclude__c = '{"Active":true,"Off Premise":true}';
	        testObj.FiltersLong__c = '{"Display Status":"01","Premise Type":"Off Premise"}';
	        testObj.Goal_Type__c = 'House Goal';
	        testObj.Number_of_Photos_Allowed__c = 25;
	        testObj.Parent_Child_Independent__c = 'Local';
	        update testObj;
	        
	        //Create Objective Account with wrong Record Type (should be Display)
	        Id recordTypeIdObjAcc = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get('Reset').getRecordTypeId();    
	        Objective_Account__c testObjAcc = TestFactory.createObjectiveAccountRecordTypeId(testObj.Id, 'Incomplete', testAccount.Id, recordTypeIdObjAcc);            
	        
            //Create Objective Submission with wrong Record Type (should be Display)
	        Id recordTypeIdObjSub = Schema.SObjectType.Objective_Submission__c.getRecordTypeInfosByName().get('Reset').getRecordTypeId();	        
	        Objective_Submission__c testObjSub = TestFactory.createObjectiveSubmission(testObjAcc.Id);
            testObjSub.RecordTypeId = recordTypeIdObjSub;
            update testObjSub;
        }
    }
    
    @isTest
    static void testScheduleUpdateObjectives() {
        
        Test.startTest();        	
			ScheduleUpdateObjectiveRecordTypes tsc = new ScheduleUpdateObjectiveRecordTypes();
			tsc.execute(null);
        Test.stopTest();
        
        //Assert that the record types were updated
        //Objective Account
        Id recordTypeIdObjAcc = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get('Display').getRecordTypeId();
        Objective_Account__c objAccCheck = [SELECT RecordTypeId FROM Objective_Account__c LIMIT 1];
        System.assertEquals(objAccCheck.RecordTypeId, recordTypeIdObjAcc);
        //Objective Submission
        Id recordTypeIdObjSub = Schema.SObjectType.Objective_Submission__c.getRecordTypeInfosByName().get('Display').getRecordTypeId();
        Objective_Submission__c objSubCheck = [SELECT RecordTypeId FROM Objective_Submission__c LIMIT 1];
        System.assertEquals(objSubCheck.RecordTypeId, recordTypeIdObjSub);
    }
}