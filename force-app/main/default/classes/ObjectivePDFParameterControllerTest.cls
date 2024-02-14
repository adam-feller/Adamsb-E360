@IsTest
public class ObjectivePDFParameterControllerTest {

    @TestSetup
    private static void setup() {       
       	Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.SalesOrg__c = 'PVA';        
        update testAccount;
    }
    
    static testMethod void testGetObjective() {	
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        
        Objective__c obj = ObjectivePDFParameterController.getObjective(testObjective.Id);
        System.assertEquals(testObjective.Id, obj.Id);
    }    

    static testMethod void testGetObjectivesValid() {
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        //First Objective with Objective Account and Objective Submission (Active)
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        insert testObjectiveLocation;
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Location__c = testObjectiveLocation.Id;
        insert testObjectiveAccount;
        //First Objective Submission
        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Status__c = 'Approved';
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;

        //Second Objective with Objective Account and Objective Submission (Active)
        Objective__c testObjective2 = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation2 = new Objective_Location__c();
        testObjectiveLocation2.Objective__c = testObjective2.Id;
        insert testObjectiveLocation2;
        Objective_Account__c testObjectiveAccount2 = new Objective_Account__c();
        testObjectiveAccount2.Objective__c = testObjective2.Id;
        testObjectiveAccount2.Status__c = 'Incomplete';
        testObjectiveAccount2.Account__c = testAccount.Id;
        testObjectiveAccount2.Objective_Location__c = testObjectiveLocation2.Id;
        insert testObjectiveAccount2;
        Objective_Submission__c testObjectiveSubmission2 = new Objective_Submission__c();
        testObjectiveSubmission2.Status__c = 'Approved';
        testObjectiveSubmission2.Objective_Account__c = testObjectiveAccount2.Id;
        insert testObjectiveSubmission2;

        //Third Objective with Objective Account and Objective Submission (Inactive)
        Objective__c testObjective3 = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        testObjective3.Start_Date__c = System.today()-20;
        testObjective3.End_Date__c = System.today()-10;
        update testObjective3;
        Objective_Location__C testObjectiveLocation3 = new Objective_Location__c();
        testObjectiveLocation3.Objective__c = testObjective3.Id;
        insert testObjectiveLocation3;
        Objective_Account__c testObjectiveAccount3 = new Objective_Account__c();
        testObjectiveAccount3.Objective__c = testObjective2.Id;
        testObjectiveAccount3.Status__c = 'Incomplete';
        testObjectiveAccount3.Account__c = testAccount.Id;
        testObjectiveAccount3.Objective_Location__c = testObjectiveLocation3.Id;
        insert testObjectiveAccount3;
        Objective_Submission__c testObjectiveSubmission3 = new Objective_Submission__c();
        testObjectiveSubmission3.Status__c = 'Approved';
        testObjectiveSubmission3.Objective_Account__c = testObjectiveAccount3.Id;
        insert testObjectiveSubmission3;
        
        List<Map<String, String>> objList;
        //Test getting Objectives List (Active, no search)
        objList = ObjectivePDFParameterController.getObjectives('', 'Active', new List<String>{testObjective.Id});
        System.assertEquals(2, objList.size());        

        //Test getting Objectives List (Active, search for 'Test')
        objList = ObjectivePDFParameterController.getObjectives('Test', 'Active', new List<String>{testObjective.Id});
        System.assertEquals(2, objList.size());     
        
        //Test getting Objectives List (All, no search)
        objList = ObjectivePDFParameterController.getObjectives('', 'All', new List<String>{testObjective.Id});
        System.assertEquals(3, objList.size());   
        
        //Test getting Objectives List (All, search for 'Test')
        objList = ObjectivePDFParameterController.getObjectives('Test', 'All', new List<String>{testObjective.Id});
        System.assertEquals(3, objList.size());
        
		//Test getting Objectives List (Inactive, no search)
        objList = ObjectivePDFParameterController.getObjectives('', 'Inactive', new List<String>{testObjective.Id});
        System.assertEquals(2, objList.size());   
        
        //Test getting Objectives List (Inactive, search for 'Test')
        objList = ObjectivePDFParameterController.getObjectives('Test', 'Inactive', new List<String>{testObjective.Id});
        System.assertEquals(2, objList.size());   
    }
    
    static testMethod void testGetObjectivesInvalid() {	
		Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        testObjective.Parent_Child_Independent__c = 'Cascade';
        update testObjective;
        
        //Test getting Objectives List (no Objective that matches criteria)
        List<Map<String, String>> objList = ObjectivePDFParameterController.getObjectives('', 'Active', new List<String>{testObjective.Id});
        System.assertEquals('None Found', objList[0].get('value'));
    }    

    static testMethod void testGetLocationsValid() {	
		Account testAccount = [SELECT Id, VIP_Instance__c, SalesOrg__c, Warehouse__c FROM Account WHERE Name = 'Test Account'];
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        insert testObjectiveLocation;
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Location__c = testObjectiveLocation.Id;
        insert testObjectiveAccount;
        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Status__c = 'Approved';
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;
                
        //Test getting Locations List
        List<Map<String, String>> locList = ObjectivePDFParameterController.getLocations(testObjective.Id);        
        System.assertEquals(testAccount.VIP_Instance__c + ' / ' + testAccount.SalesOrg__c + ' / ' + testAccount.Warehouse__c, locList[0].get('value'));
    }
    
    static testMethod void testGetLocationsInvalid() {	
		Account testAccount = [SELECT Id, VIP_Instance__c, SalesOrg__c, Warehouse__c FROM Account WHERE Name = 'Test Account'];
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        insert testObjectiveLocation;
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Location__c = testObjectiveLocation.Id;
        insert testObjectiveAccount;
        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Status__c = 'Submitted for Approval';
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;
        
        //Test getting Locations List
        List<Map<String, String>> locList = ObjectivePDFParameterController.getLocations(testObjective.Id);        
        System.assertEquals('None Found', locList[0].get('value'));
    }    

    static testMethod void testGetSalesRepsValid() {	
		Account testAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Test Account'];
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        insert testObjectiveLocation;
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Location__c = testObjectiveLocation.Id;
        insert testObjectiveAccount;
        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Status__c = 'Approved';
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;
        
        //Test getting Locations List
        List<Map<String, String>> srList = ObjectivePDFParameterController.getSalesReps(testObjective.Id);        
        System.assertEquals(testAccount.OwnerId, srList[0].get('value'));
    }

    static testMethod void testGetSalesRepsInvalid() {	
		Account testAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Test Account'];
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'PVA', 'Display');
        Objective_Location__C testObjectiveLocation = new Objective_Location__c();
        testObjectiveLocation.Objective__c = testObjective.Id;
        insert testObjectiveLocation;
        Objective_Account__c testObjectiveAccount = new Objective_Account__c();
        testObjectiveAccount.Objective__c = testObjective.Id;
        testObjectiveAccount.Status__c = 'Incomplete';
        testObjectiveAccount.Account__c = testAccount.Id;
        testObjectiveAccount.Objective_Location__c = testObjectiveLocation.Id;
        insert testObjectiveAccount;
        Objective_Submission__c testObjectiveSubmission = new Objective_Submission__c();
        testObjectiveSubmission.Status__c = 'Submitted for Approval';
        testObjectiveSubmission.Objective_Account__c = testObjectiveAccount.Id;
        insert testObjectiveSubmission;
        
        //Test getting Locations List
        List<Map<String, String>> srList = ObjectivePDFParameterController.getSalesReps(testObjective.Id);        
        System.assertEquals('None Found', srList[0].get('value'));
    }    

}