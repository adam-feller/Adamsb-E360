@IsTest
public class FilePhotoUploadAdvancedHandlerTest {

    @IsTest
    public static void FilePhotoUploadAdvancedHandlerTestMethod() {
        
        Account acc = new Account(
            BillingStreet = '123 ST',
            BillingState = 'NY',
            BillingCountry = 'US',
            BillingPostalCode = '00000',
            BillingCity = 'City',
            Name = 'Test'
        );
        
        insert acc;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        insert cv;    
        
        ContentDocument cd = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        //create ContentDocumentLink record 
        ContentDocumentLink cdl = New ContentDocumentLink(
            LinkedEntityId = acc.id,
            ContentDocumentId = cd.Id,
            ShareType = 'V'
        );

        insert cdl;
        
        FilePhotoUploadAdvancedHandler.getFiles(acc.Id,'');
        FilePhotoUploadAdvancedHandler.deleteFile(cd.Id);
    }
    
    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'HDI', 'Display');
        Objective_Account__c testObjAcc = TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
        Objective_Submission__c testObjDisplay = new Objective_Submission__c();
        testObjDisplay.Objective_Account__c = testObjAcc.Id;
        insert testObjDisplay;
        
    }
    static Objective_Submission__c getObjectiveSubmission(){
        return [SELECT Id
                FROM Objective_Submission__c
                LIMIT 1];
    }
    static ContentDocumentLink getContentDocumentLink(String id){
        return [SELECT Id, LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :id];
    }
    static ContentDocument getContentDocument(Id cdId){
        return [SELECT Id, Title
                FROM ContentDocument
                WHERE Id = :cdId];
    }
    static testMethod void fileRenameControllerTest() {
        Test.StartTest(); 
        
        Objective_Submission__c testObjDisplay = getObjectiveSubmission();
        FilePhotoUploadAdvancedHandler.uploadPhotos('Test File Name', 'image/png', 'Base64 Data', (String)testObjDisplay.Id);
        ContentDocumentLink cdl = getContentDocumentLink(testObjDisplay.Id);
        ContentDocument cd = getContentDocument(cdl.ContentDocumentId);

        Test.StopTest();
        
        System.assertEquals(cd.Title, 'Test File Name', 'The ContentDoucment Title should be same as the value passed');
        System.assertEquals(cdl.LinkedEntityId, testObjDisplay.Id, 'The ContentDoucmentLink should be related to the Test Account');
        System.assertEquals(cdl.ContentDocumentId, cd.Id, 'The ContentDoucmentLink should be related to the ContentDocument');        
    }

}