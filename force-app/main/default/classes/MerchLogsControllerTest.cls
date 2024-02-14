@IsTest
public class MerchLogsControllerTest {

    @testSetup static void setupChecklists() {
        //Create an Account with associated Merch Checklist
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Merch_Checklist__c mc = TestFactory.createMerchChecklist(testAccount.Id, System.Today());
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId(); 
        //Create 3 Tasks with different Statuses
        Task testTask = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Open', testAccount.Id, System.today());
        testTask.Merch_Checklist__c = mc.Id;
        update testTask;
        Task testTask2 = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Completed', testAccount.Id, System.today());
        testTask2.Merch_Checklist__c = mc.Id;
        update testTask2;        
        Task testTask3 = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'In Progress', testAccount.Id, System.today());
        testTask3.Merch_Checklist__c = mc.Id;
        update testTask3;             
    }
    
    @IsTest
    static void getMerchChecklistsForAccountTestMethod() {        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        Test.StartTest(); 
            List<String> mcList = MerchLogsController.getMerchChecklistsForAccount(testAccount.Id);
        Test.StopTest();
        
        //Assertion
        System.assertEquals(1, mcList.size(), '1 Merch Checklist should have been returned');
    }

    @IsTest
    static void getMerchDetailsByMerchIdTestMethod() {        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Merch_Checklist__c testMC = [SELECT Id FROM Merch_Checklist__c WHERE Account__c =: testAccount.Id];
        
        Test.StartTest(); 
            Merch_Checklist__c mc = MerchLogsController.getMerchDetailsByMerchId(testMC.Id);
        Test.StopTest();
        
        //Assertion
        System.assertEquals(testMC.Id, mc.Id, 'Should have found the Merch Checklist');
    }

    @IsTest
    static void getMerchTasksByMerchIdTestMethod() {        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Merch_Checklist__c testMC = [SELECT Id FROM Merch_Checklist__c WHERE Account__c =: testAccount.Id];
        
        Test.StartTest(); 
            String tasks = MerchLogsController.getMerchTasksByMerchId(testMC.Id, 10);
        Test.StopTest();
        
        //Assertion
        System.assertNotEquals('', tasks, 'Should have found the Merch Checklist Tasks');
    }
    
    @IsTest
    static void getMiscMerchTasksByAccountIdTestMethod() {        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        Test.StartTest(); 
            List<Task> taskList = MerchLogsController.getMiscMerchTasksForAccount(testAccount.Id);
        Test.StopTest();
        
        //Assertion
        System.assertEquals(0, taskList.size(), '0 Misc Merch Tasks should have been returned');  
    }
    
    @IsTest
    static void getMerchTasksByAccountIdTestMethod() {        
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        
        Test.StartTest(); 
            String merchTasks = MerchLogsController.getMerchTasksByAccountId(testAccount.Id,10);
        Test.StopTest();
        
        //Assertion
        System.assertNotEquals('', merchTasks, 'Should have found the Account Merch Tasks');  
    }
    
}