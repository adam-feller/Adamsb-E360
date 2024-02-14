@isTest
private class OrderNotesRelatedListControllerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Pricebook2 testPriceBook = TestFactory.createPriceBook(testAccount.Id, testAccount.Name, true, 'Account Pricebook');
        TestFactory.createOrder(testAccount.Id, testPriceBook.Id, System.today(), 'Pending Draft');
        ContentNote testContentNote = TestFactory.createContentNote('Test Note');
        TestFactory.createContentDocumentLink(testAccount.Id, testContentNote.Id);
    }

    static Account getAccount(){
        return [SELECT Id
                FROM Account];
    }

    static ContentNote getContentNote(){
        return [SELECT Id
                FROM ContentNote
                LIMIT 1];
    }

    static Order getOrder(){
        return [SELECT Id
                FROM Order];
    }

    @isTest
    static void testGetNotes(){
        Account testAccount = getAccount();

        Test.startTest();
            List<OrderNotesRelatedListController.NoteWrapper> noteWrapperObj = OrderNotesRelatedListController.getNotes(testAccount.Id);
        Test.stopTest();

        System.assertEquals(noteWrapperObj.size(), 1, '1 note should be returned');
    }

    @isTest
    static void testInsertNewNote(){
        Account testAccount = getAccount();
        Order testOrder = getOrder();

        Test.startTest();
            OrderNotesRelatedListController.NoteWrapper noteWrapperObj = OrderNotesRelatedListController.insertNewNote(testAccount.Id, testOrder.Id, 'Test', 'Test');
        Test.stopTest();

        System.assertEquals(noteWrapperObj.title, 'Test', 'Title should be Test');
    }

    @isTest
    static void testSaveNoteUpdate(){
        ContentNote testContentNote = getContentNote();

        Test.startTest();
            OrderNotesRelatedListController.NoteWrapper noteWrapperObj = OrderNotesRelatedListController.saveNoteUpdate(testContentNote.Id, 'Test', 'Test');
        Test.stopTest();

        System.assertEquals(noteWrapperObj.title, 'Test', 'Title should be Test');
    }
}