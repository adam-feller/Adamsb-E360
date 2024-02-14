@isTest
private class ContentDocumentLinkDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        Account testAccount2 = TestFactory.createAccount('Test Account2', '201', 'PVA', 'PDVA-CHANTILLY', null, '12346');
        ContentNote testContentNote = TestFactory.createContentNote('Test Note');
        TestFactory.createContentDocumentLink(testAccount.Id, testContentNote.Id);
    }

    static Account getAccount(String name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    static ContentNote getContentNote(){
        return [SELECT Id, Title
                FROM ContentNote
                LIMIT 1];
    }

    @isTest
    static void testGetContentDocumentLinkByAccountId(){
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            List<ContentDocumentLink> contentDocumentLinkList = ContentDocumentLinkDAO.getContentDocumentLinkByAccountId(new Set<Id>{testAccount.Id});
        Test.stopTest();

        System.assertEquals(contentDocumentLinkList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testGetContentDocumentLinkExternalIdAndAccountId(){
        Account testAccount = getAccount('Test Account');

        Test.startTest();
            List<ContentDocumentLink> contentDocumentLinkList = ContentDocumentLinkDAO.getContentDocumentLinkExternalIdAndAccountId(testAccount.Id, new Set<String>{'item:1234'});
        Test.stopTest();

        System.assertEquals(contentDocumentLinkList.size(), 0, '0 records should be returned');
    }

    @isTest
    static void testInsertContentDocumentLinks(){
        Account testAccount = getAccount('Test Account2');
        ContentNote testContentNote = getContentNote();

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink();
        testContentDocumentLink.LinkedEntityId = testAccount.Id;
        testContentDocumentLink.ContentDocumentId = testContentNote.Id;
        testContentDocumentLink.ShareType = 'I';
        testContentDocumentLink.Visibility = 'AllUsers';

        Test.startTest();
            List<ContentDocumentLink> contentDocumentLinkList = ContentDocumentLinkDAO.insertContentDocumentLinks(new List<ContentDocumentLink>{testContentDocumentLink});
        Test.stopTest();

        List<ContentDocumentLink> returnedContentDocumentLinkList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id];

        System.assertEquals(returnedContentDocumentLinkList.size(), 1, '1 record should be returned');
    }
}