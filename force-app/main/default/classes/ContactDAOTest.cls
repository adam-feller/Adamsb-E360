@isTest
private class ContactDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');

        TestFactory.createContact(testAccount.Id, 'Test', 'User', 'test2@gmail.com');

    }

    static Account getAccount(){
        return [SELECT Id, Name
                FROM Account
                LIMIT 1];
    }

    @isTest
    static void testGetContactsByAccountId(){
        Account testAccount = getAccount();

        Test.startTest();
            List<Contact> contactList = ContactDAO.getContactsByAccountId(testAccount.Id);
        Test.stopTest();

        System.assertEquals(contactList.size(), 1, 'contactList should return 1 record');
    }
}