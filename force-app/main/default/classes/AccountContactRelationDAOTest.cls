@isTest
private class AccountContactRelationDAOTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Contact testContact = TestFactory.createContact(testAccount.Id, 'test', 'user', 'test2@gmail.com');
    }

    static AccountContactRelation getAccountContactRelation(){
        return [SELECT Id
                FROM AccountContactRelation
                LIMIT 1];
    }

    static Contact getContact(){
        return [SELECT Id
                FROM Contact
                LIMIT 1];
    }

    @isTest
    static void testGetAccountContactRelation(){
        Contact testContact = getContact();

        Test.startTest();
            List<AccountContactRelation> accountContactRelationList = AccountContactRelationDAO.getAccountContactRelation(new Set<Id>{testContact.Id});
        Test.stopTest();

        System.assertEquals(accountContactRelationList.size(), 1, 'accountContactRelationList should return 1 record');
    }

    @isTest
    static void testUpdateAccountContactRelation(){
        AccountContactRelation testAccountContactRelation = getAccountContactRelation();

        Test.startTest();
            List<AccountContactRelation> accountContactRelationList = AccountContactRelationDAO.updateAccountContactRelation(new List<AccountContactRelation>{testAccountContactRelation});
        Test.stopTest();

        System.assertEquals(accountContactRelationList.size(), 1, 'accountContactRelationList should return 1 record');
    }
}