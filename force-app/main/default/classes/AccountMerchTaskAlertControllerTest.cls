@isTest
public class AccountMerchTaskAlertControllerTest {
    
    @isTest
    static void testGetOpenMerchTasks(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        String merchTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();
        Task testTask = new Task(Subject='Clean Back Room', WhatId=testAccount.Id, RecordTypeId=merchTaskRecordTypeId, ActivityDate=System.Today(), Status='Open');
        insert testTask;
        
        Test.startTest();
            Integer num = AccountMerchTaskAlertController.getMerchTasksforToday(testAccount.Id);
        Test.stopTest();

        System.assertEquals(1, num, 'Should have found 1 Open Merch Task');
    }
    
    @isTest
    static void testGetOpenMerchTasksNoTasks(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');

        Test.startTest();
            Integer num = AccountMerchTaskAlertController.getMerchTasksforToday(testAccount.Id);
        Test.stopTest();

        System.assertEquals(0, num, 'Should not find any Open Merch Tasks');
    }


}