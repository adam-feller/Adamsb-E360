@isTest
public class MenuSurveyFlowControllerTest {

    @IsTest
    static void cloneContentVersion(){
        //Create new Survey
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Survey__c testSurvey = new Survey__c(Account__c=testAccount.Id, Survey_Type__c='Menu');
        insert testSurvey;
        Id surveyId = testSurvey.Id;
        //insert new document
        List<ContentVersion> listCV = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        insert cv;
        listCV.add(cv);

        List<MenuSurveyFlowController.cloneFileRequest> inputs = new List<MenuSurveyFlowController.cloneFileRequest>();
        MenuSurveyFlowController.cloneFileRequest input = new MenuSurveyFlowController.cloneFileRequest();
        input.surveyId = testSurvey.Id;
        input.files = listCV;
        inputs.add(input);
        Test.startTest();
        MenuSurveyFlowController.cloneContentVersion(inputs);
        Test.stopTest();

        List<ContentDocumentLink> cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:surveyId];
        System.assertEquals(1, cdl.size(), 'ContentDocumentLink was not created');
    }
}