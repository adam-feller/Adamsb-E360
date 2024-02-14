@isTest
private class AccountTermTypeDAOTest {

    @isTest
    static void testGetAccountTermTypeErrorCodes(){
        Test.startTest();
            List<Account_Term_Type__mdt> accountTermTypeList = AccountTermTypeDAO.getAccountTermTypeErrorCodes();
        Test.stopTest();

        System.assertNotEquals(accountTermTypeList.size(), 0, 'accountTermTypeList should return more than 0 records');
    }
}