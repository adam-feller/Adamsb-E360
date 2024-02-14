/**
 * Created by alexander.velitsky on 12/23/20.
 */

@IsTest
private class AccountChangeEventTrigerTest {

    @IsTest
    static void test_pricebookonAccountCreation() {
        Test.enableChangeDataCapture();

        TestFactory.createAccount('Test','1233445','HJL','HJL', null,'100');
        Test.getEventBus().deliver();

        Test.startTest();
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(accounts.size(), 1, '1 account should be returned');
    }

    @IsTest
    static void test_pricebookOnAccountUpdate() {
        Test.enableChangeDataCapture();
        Account testAccount = TestFactory.createAccount('Test','1233445','HJL','HJL', null,'100');
        testAccount.isActive__c = false;
        update testAccount;
        Test.getEventBus().deliver();

        testAccount.isActive__c = true;
        testAccount.Sales_Manager_Route_4__c = 'UNK';
        update testAccount;

        Test.getEventBus().deliver();

        List<Account> accounts = [SELECT Id, Sales_Manager_Route_4__c FROM Account];

        System.assertEquals(accounts[0].Sales_Manager_Route_4__c, 'UNK', 'Route should be UNK');
    }
}