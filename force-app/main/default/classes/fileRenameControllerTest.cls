@IsTest
public with sharing class fileRenameControllerTest {

    @TestSetup
    private static void setup() {
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Objective__c testObjective = TestFactory.createObjective('Test Objective', 'HDI', 'Display');
        Objective_Account__c testObjAcc = TestFactory.createObjectiveAccount(testObjective.Id, 'Incomplete', testAccount.Id);
        Objective_Submission__c testObjSubmission = new Objective_Submission__c();
        testObjSubmission.Objective_Account__c = testObjAcc.Id;
        insert testObjSubmission;
        
    }
    static Objective_Submission__c getObjectiveSubmission() {
        return [SELECT Id
                FROM Objective_Submission__c
                LIMIT 1];
    }
    static ContentDocumentLink getContentDocumentLink(String id) {
        return [SELECT Id, LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :id];
    }
    static ContentDocument getContentDocument(Id cdId) {
        return [SELECT Id, Title
                FROM ContentDocument
                WHERE Id = :cdId];
    }
    static testMethod void fileRenameControllerTest() {
        Test.StartTest(); 
        
        Objective_Submission__c testObjSubmission = getObjectiveSubmission();
        fileRenameController.uploadPhotos('Test File Name', 'image/png', 'Base64 Data', (String)testObjSubmission.Id);
        ContentDocumentLink cdl = getContentDocumentLink(testObjSubmission.Id);
        ContentDocument cd = getContentDocument(cdl.ContentDocumentId);

        Test.StopTest();
        
        System.assertEquals(cd.Title, 'Test File Name', 'The ContentDoucment Title should be same as the value passed');
        System.assertEquals(cdl.LinkedEntityId, testObjSubmission.Id, 'The ContentDoucmentLink should be related to the Test Account');
        System.assertEquals(cdl.ContentDocumentId, cd.Id, 'The ContentDoucmentLink should be related to the ContentDocument');
        
    }

}