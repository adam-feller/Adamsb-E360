@isTest
public class DownloadPhotosTest {
    @testSetup static void setupChecklists() {
        //Create an Account with associated Merch Checklist
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Merch_Checklist__c mc = TestFactory.createMerchChecklist(testAccount.Id, System.Today());
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId(); 
        //Create 3 Tasks with different Statuses
        Task testTask = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Open', testAccount.Id, System.today());
        testTask.Merch_Checklist__c = mc.Id;
        update testTask;
/*
        Task testTask2 = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Completed', testAccount.Id, System.today());
        testTask2.Merch_Checklist__c = mc.Id;
        update testTask2;        
        Task testTask3 = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'In Progress', testAccount.Id, System.today());
        testTask3.Merch_Checklist__c = mc.Id;
        update testTask3;             
*/
    }
    
    public static testmethod void testGetPhotos() {     
        //Create an Account with associated Merch Checklist
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Merch_Checklist__c mc = TestFactory.createMerchChecklist(testAccount.Id, System.Today());
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId(); 
        //Create 3 Tasks with different Statuses
        Task testTask = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Open', testAccount.Id, System.today());
        testTask.Merch_Checklist__c = mc.Id;
        update testTask;
        
        //Create File (ContentDocumentLink)
        Blob bodyBlob=Blob.valueOf('ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='picture', 
            PathOnClient ='/picture.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = testTask.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
            
        //Start the test execution
        Test.startTest();

        //Define Page
        PageReference pg = Page.DownloadPhotos;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', mc.Id);
               
        //Test the Method
        List<DownloadPhotos.PhotoWrapper> lstPhotoWrapper = DownloadPhotos.getPhotos(mc.Id);

        //stop the test execution
        Test.stopTest();      
        
        System.assertEquals(1, lstPhotoWrapper.size());
    }
    
    public static testmethod void testGetTasksHavePhotos() {     
        //Create an Account with associated Merch Checklist
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Merch_Checklist__c mc = TestFactory.createMerchChecklist(testAccount.Id, System.Today());
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId(); 
        //Create 3 Tasks with different Statuses
        Task testTask = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Open', testAccount.Id, System.today());
        testTask.Merch_Checklist__c = mc.Id;
        update testTask;
        
        //Create File (ContentDocumentLink)
        Blob bodyBlob=Blob.valueOf('ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='picture', 
            PathOnClient ='/picture.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = testTask.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
            
        //Start the test execution
        Test.startTest();

        //Define Page
        PageReference pg = Page.DownloadPhotos;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', mc.Id);
               
        //Test the Method
        Boolean testHasPhotos= DownloadPhotos.getTasksHavePhotos(mc.Id);

        //stop the test execution
        Test.stopTest();      
        
        System.assertEquals(true, testHasPhotos);
    }
}