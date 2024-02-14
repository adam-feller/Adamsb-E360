@isTest
private class ContentNoteDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '12345');
        ContentNote testContentNote = TestFactory.createContentNote('Test Note');
        TestFactory.createContentDocumentLink(testAccount.Id, testContentNote.Id);
    }

    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }

    static ContentNote getContentNote(String title){
        return [SELECT Id, Title, CreatedDate
                FROM ContentNote
                WHERE Title = :title
                LIMIT 1];
    }

    @isTest
    static void testGetContentNoteByIdAndTodaysCreatedDate(){
        ContentNote testContentNote = getContentNote('Test Note');

        Test.startTest();
            List<ContentNote> contentNoteList = ContentNoteDAO.getContentNoteByIdAndTodaysCreatedDate(new Set<Id>{testContentNote.Id});
        Test.stopTest();

        System.assertEquals(contentNoteList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testInsertContentNotes(){
        ContentNote testContentNote = new ContentNote();
        testContentNote.Title = 'Test Note2';
        testContentNote.Content = Blob.valueOf('');

        Test.startTest();
            List<ContentNote> testContentNoteList = ContentNoteDAO.insertContentNotes(new List<ContentNote>{testContentNote});
        Test.stopTest();

        List<ContentNote> returnedContentNoteList = [SELECT Id FROM ContentNote WHERE Title = 'Test Note2'];

        System.assertEquals(returnedContentNoteList.size(), 1, '1 record should be returned');
    }

    @isTest
    static void testUpdateContentNotes(){
        ContentNote testContentNote = getContentNote('Test Note');
        testContentNote.Title = 'Test Note3';

        Test.startTest();
            List<ContentNote> testContentNoteList = ContentNoteDAO.updateContentNotes(new List<ContentNote>{testContentNote});
        Test.stopTest();

        List<ContentNote> returnedContentNoteList = [SELECT Id FROM ContentNote WHERE Title = 'Test Note3'];

        System.assertEquals(returnedContentNoteList.size(), 1, '1 record should be returned');
    }
}