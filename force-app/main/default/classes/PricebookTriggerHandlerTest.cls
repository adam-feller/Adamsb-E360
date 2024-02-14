@isTest
private class PricebookTriggerHandlerTest{
    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Invoice__c testInvoice = new Invoice__c();
        testInvoice.AccountId__c = testAccount.Id;
        testInvoice.External_Id__c = '123456';
        testInvoice.Name = 'TestInvoice';
        insert testInvoice;
    }
    static Invoice__c getInvoice(){
        return [SELECT Id, AccountId__c, External_Id__c, Name
                FROM Invoice__c
                LIMIT 1];
    }
    static Account getAccount(){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c
                FROM Account
                LIMIT 1];
    }
/*
    @isTest
    private static void afterInvoiceHandler_TEST(){
        Invoice__c testInvoice = getInvoice();
        Account testAccount = getAccount();
        Test.startTest();
        PricebookTriggerHandler.afterInvoiceHandler(new List<Invoice__c>{new Invoice__c(AccountId__c = testAccount.Id, External_Id__c = '123456', Name = 'TestInvoice')});
        Test.stopTest();
        List<Pricebook2> Pricebook2 = [SELECT ID FROM Pricebook2 WHERE AccountId__c = :testAccount.Id];
        //system.assertEquals(Pricebook2.size(),1, '1 Pricebook created');
    }
    */
}