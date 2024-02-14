@isTest
private class ContentVersionDAOTest {

    @TestSetup
    private static void setup(){
        List<ExternalDataSource> externalDataSourceList = [SELECT Id FROM ExternalDataSource];
        TestFactory.createContentVersion('Test.pdf', 'File', 'Test.pdf', externalDataSourceList[0].Id, 
                                        '123456', 'E', 'H');
    }

    @isTest
    static void testGetContentVersionByDataSourceAndExternalIdsSet(){
        List<ExternalDataSource> externalDataSourceList = [SELECT Id FROM ExternalDataSource];

        Test.startTest();
            List<ContentVersion> contentVersionList = ContentVersionDAO.getContentVersionByDataSourceAndExternalIdsSet(externalDataSourceList[0].Id, new Set<String>{'123456'});
        Test.stopTest();

        System.assertEquals(contentVersionList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testInsertContentVersions(){
        List<ExternalDataSource> externalDataSourceList = [SELECT Id FROM ExternalDataSource];

        ContentVersion testContentVersionObj = new ContentVersion();
        testContentVersionObj.Title = 'Test2.pdf';
        testContentVersionObj.Description = 'File';
        testContentVersionObj.PathOnClient = 'Test2.pdf';
        testContentVersionObj.ExternalDataSourceId = externalDataSourceList[0].Id;
        testContentVersionObj.ExternalDocumentInfo2 = '123457';
        testContentVersionObj.ContentLocation = 'E';
        testContentVersionObj.Origin = 'H';

        Test.startTest();
            List<ContentVersion> testContentVersionList = ContentVersionDAO.insertContentVersions(new List<ContentVersion>{testContentVersionObj});
        Test.stopTest();

        List<ContentVersion> returnedContentVersionList = [SELECT Id FROM ContentVersion WHERE Title = 'Test2.pdf'];

        System.assertEquals(returnedContentVersionList.size(), 1, '1 record should be returned');
    }
}