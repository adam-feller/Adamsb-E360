@isTest
public class InactiveAccountHandlerTest {

    static testMethod void testUpdate() {
        Account testAccount = TestFactory.createAccount('Test Account', '20135', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Test.startTest();
        testAccount.IsActive__c = false;
        testAccount.Sell_Type__c = 'PRESELL';
        testAccount.License_1__c = '235235';
        testAccount.License_2__c = '534543';
        testAccount.License3__c = '234234';
        testAccount.Account_Manager_Route__c = '1234';
        testAccount.Account_Manager_Route_2__c = '1234';
        testAccount.Account_Manager_Route_3__c = '1234';
        testAccount.Account_Manager_Route_4__c = '1234';
        testAccount.Account_Manager_Route_5__c = '1234';
        testAccount.Account_Manager_Route_6__c = '1234';
        testAccount.Sales_Manager_Route__c = '5678';
        testAccount.Sales_Manager_Route_2__c = '5678';
        testAccount.Sales_Manager_Route_3__c = '5678';
        testAccount.Sales_Manager_Route_4__c = '5678';
        testAccount.Sales_Manager_Route_5__c = '5678';
        testAccount.Sales_Manager_Route_6__c = '5678';
        update testAccount;
        Test.stopTest();
        testAccount = [SELECT License_1__c, License_2__c, License3__c,
                       Account_Manager_Route__c,
                       Account_Manager_Route_2__c,
                       Sales_Manager_Route__c,
                       Sales_Manager_Route_2__c
                       FROM Account WHERE id = :testAccount.Id];
        System.assertEquals(testAccount.License_1__c, null, 'Inactive Licence 1 is not null');
        System.assertEquals(testAccount.License_2__c, null, 'Inactive Licence 2 is not null');
        System.assertEquals(testAccount.License3__c, null, 'Inactive Licence 3 is not null');
        System.assertEquals(testAccount.Account_Manager_Route__c, null, 'Inactive Account mgr route is not null');
        System.assertEquals(testAccount.Account_Manager_Route_2__c, null, 'Inactive Account mgr 2 route not null');
        System.assertEquals(testAccount.Sales_Manager_Route__c, null, 'Sales Mgr route is not null');
        System.assertEquals(testAccount.Sales_Manager_Route_2__c, null, 'Sales Mgr route 2 is not null');
    } 
    
    static testMethod void testInsert() {
        Test.startTest();
        Account testAccount = new Account();
        testAccount.Name = 'Account extraordinary name';
        testAccount.Account_Type__c = 'None';
        testAccount.VIP_Account_Number__c = '12345';
        testAccount.VIP_Instance__c = 'PVA';
        testAccount.ExternalId__c = '12345';
        testAccount.Chain__c = 'FOOD LION';
        testAccount.Beer_Company__c = 'PVA';
        testAccount.Warehouse__c = 'PDVA-CHANTILLY';
        testAccount.Store_Number__c = '12345';
        testAccount.Territories__c = '10';
        testAccount.IsActive__c = false;
        testAccount.Sell_Type__c = 'PRESELL';
        testAccount.License_1__c = '235235';
        testAccount.License_2__c = '534543';
        testAccount.License3__c = '234234';
        testAccount.Account_Manager_Route__c = '1234';
        testAccount.Account_Manager_Route_2__c = '1234';
        testAccount.Account_Manager_Route_3__c = '1234';
        testAccount.Account_Manager_Route_4__c = '1234';
        testAccount.Account_Manager_Route_5__c = '1234';
        testAccount.Account_Manager_Route_6__c = '1234';
        testAccount.Sales_Manager_Route__c = '5678';
        testAccount.Sales_Manager_Route_2__c = '5678';
        testAccount.Sales_Manager_Route_3__c = '5678';
        testAccount.Sales_Manager_Route_4__c = '5678';
        testAccount.Sales_Manager_Route_5__c = '5678';
        testAccount.Sales_Manager_Route_6__c = '5678';
        insert testAccount;
        Test.stopTest();
        testAccount = [SELECT License_1__c, License_2__c, License3__c,
                       Account_Manager_Route__c,
                       Account_Manager_Route_2__c,
                       Sales_Manager_Route__c,
                       Sales_Manager_Route_2__c
                       FROM Account WHERE id = :testAccount.Id];
        System.assertEquals(testAccount.License_1__c, null, 'Inactive Licence 1 is not null');
        System.assertEquals(testAccount.License_2__c, null, 'Inactive Licence 2 is not null');
        System.assertEquals(testAccount.License3__c, null, 'Inactive Licence 3 is not null');
        System.assertEquals(testAccount.Account_Manager_Route__c, null, 'Inactive Account mgr route is not null');
        System.assertEquals(testAccount.Account_Manager_Route_2__c, null, 'Inactive Account mgr 2 route not null');
        System.assertEquals(testAccount.Sales_Manager_Route__c, null, 'Sales Mgr route is not null');
        System.assertEquals(testAccount.Sales_Manager_Route_2__c, null, 'Sales Mgr route 2 is not null');
    } 
}