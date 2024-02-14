@IsTest
public class DisplayFilesControllerTest {

    @IsTest
    static void getContentsTestMethod() {
        //Create an Account with associated Task/with associated File
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        
        //Create a Task with the 'Merch Task' record Type
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();        
        Task testTask = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Open', testAccount.Id, System.today());
        
        //Simulate an uploaded photo
        Blob bodyBlob = Blob.valueOf('Body of file');            
        ContentVersion contentVersion = new ContentVersion(
                Title='Image1', 
                PathOnClient ='Image1.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
        insert contentVersion;

        ContentVersion contentVersionSaved = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = testTask.Id;
        contentlink.ContentDocumentId = contentVersionSaved.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Test.StartTest(); 
        	List<ContentVersion> cvList = DisplayFilesController.getContents(testTask.Id);
        Test.StopTest();
        
        //Assertion
        System.assertEquals(1, cvList.size(), '1 uploaded file should have been returned');
    }

    @IsTest(SeeAllData=true)
    static void postFeedTestMethod() {
        //Create an Account with associated Task
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        
        //Create a Task with the 'Merch Task' record Type
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();        
        Task testTask = TestFactory.createTaskByRecordType('Test Task', taskRecordTypeId, 'Open', testAccount.Id, System.today());
                
        Test.StartTest(); 
        	DisplayFilesController.postFeed(testTask.Id, 'This is a test');
        Test.StopTest();
        
        //Assertion
        List<FeedItem> fiList = [Select Id FROM FeedItem WHERE ParentId =: testTask.Id];
        System.assertEquals(1, fiList.size(), '1 feed item should be returned');
    }    
    
}