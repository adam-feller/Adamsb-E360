@isTest
private class MerchChecklistPDFControllerTest {

    static testMethod void MerchChecklistPDFControllerTestMethod(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.SalesOrg__c = 'PVA';
        update testAccount;
        
        //Create a Merch Checklist
        Merch_Checklist__c testChecklist = new Merch_Checklist__c(Account__c = testAccount.Id, Requested_Completion_Date__c = System.today());
        insert testChecklist;
        
        //Create a Merch Task associated to the checklist
		Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();
        Task testTask = new Task(Subject = 'Test', ActivityDate = System.today(), Location__c = '	Front Lobby', RecordTypeId = taskRecordTypeId, Account__c = testAccount.Id, WhatId = testAccount.Id, Merch_Checklist__c = testChecklist.Id);
        insert testTask;
        
        Test.StartTest(); 
        	PageReference pageRef = Page.MerchChecklistPDF; 
        	pageRef.getParameters().put('id', String.valueOf(testChecklist.Id));
        	Test.setCurrentPage(pageRef);
        	MerchChecklistPDFController controller = new MerchChecklistPDFController();
        Test.StopTest();
        
        //Assertions
        System.assertEquals(1, controller.tasks.size(), '1 task should have been found');
    }

}