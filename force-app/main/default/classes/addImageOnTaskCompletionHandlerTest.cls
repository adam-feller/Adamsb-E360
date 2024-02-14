@isTest
public class addImageOnTaskCompletionHandlerTest {
    @isTest
    public static void taskTriggerTest(){
        
        Task testTask = new Task();
        testTask.Status = 'Open';
        testTask.Subject = 'Happy Little Test Task';
        testTask.Required_Image__c = true;
        testTask.ActivityDate = Date.today();
        insert testTask;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class'); 
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.VersionData=bodyBlob;
        testContentInsert.PathOnClient ='test';
        testContentInsert.Title ='SampleTitle'; 
        insert testContentInsert;
        
        ContentVersion cvobj = [select id,ContentDocumentId from ContentVersion where id =: testContentInsert.id];
        
        //List<ContentVersion> cvList = [select id,ContentDocumentId from ContentVersion where id =: testContentInsert.id];
        List<ContentDocument> cdList = new List<ContentDocument>();
        ContentDocument cd = new ContentDocument();
        cd.id = cvobj.ContentDocumentId;
        cdList.add(cd);
        
        Test.startTest();
        addImageOnTaskCompletionHandler.checkTaskStatus(testTask.Id);
        addImageOnTaskCompletionHandler.updateImageId(testTask.Id, cvobj.ContentDocumentId);
        addImageOnTaskCompletionHandler.deleteImageOnTask(cdList);
        Test.stopTest();
        
    }
}