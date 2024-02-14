@isTest
public with sharing class CommandCenterMyTasksControllerTest {
    @TestSetup
    static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
		Id genRecordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Task').getRecordTypeId();        
        Task testTask = TestFactory.createTaskByRecordType('Test Task', genRecordTypeTask, 'Open', testAccount.Id, System.today());

        Product2 testProd = TestFactory.createProduct('Test Product', '12345', 'MillerCoors', '123*B');
       
        Id processedDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        Display_Product__c testDisplayProd = new Display_Product__c();
        testDisplayProd.RecordTypeId = processedDisplayProductRecordTypeId;
        testDisplayProd.Account__c = testAccount.Id;
        testDisplayProd.Product__c = testProd.Id;
        testDisplayProd.Start_Date__c = System.today() - 1;
        testDisplayProd.End_Date__c = System.today() + 1;
        insert testDisplayProd;

        testTask.Display_Product__c = testDisplayProd.Id;
        update testTask;
    }

    @isTest
    static void testGetTasksByIdAndStatus(){

        Test.startTest();
        List<CommandCenterMyTasksController.TaskWrapper> taskWrapperList = CommandCenterMyTasksController.getTaskData();
        Test.stopTest();

        System.assertEquals(2, taskWrapperList.size(), '2 records should be returned');
    }
}