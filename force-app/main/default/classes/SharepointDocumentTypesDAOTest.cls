@isTest
public class SharepointDocumentTypesDAOTest {

    @isTest
    static void TestGetSharePointDocumentByDocumentType() {
        Test.startTest();
            List<Sharepoint_Document_Types__c> result = SharepointDocumentTypesDAO.getSharepointDocumentTypeValues('Other');
        Test.stopTest();

        System.assert(result.isEmpty(), 'No Other file found');
    }
}