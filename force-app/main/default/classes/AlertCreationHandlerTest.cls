@IsTest
public with sharing class AlertCreationHandlerTest {

    @TestSetup
    static void testSetup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        testAccount.VIP_Instance__c = 'GBX';
        update testAccount;
    }

    @IsTest
    static void testCreateAlertForPreventOrder(){
        Account acc = [SELECT id FROM Account LIMIT 1];
        acc.Terms__c = 'CREDIT HOLD';

        update acc;

        List<Alert__c> alertList = [SELECT Id
                                    FROM Alert__c
                                    WHERE Terms_Related_Alert__c = true];

        System.assertEquals(1, alertList.size());
    }

    @IsTest
    static void testCreateAlertForCustomerWarning(){
        Account acc = [SELECT id FROM Account LIMIT 1];
        acc.Terms__c = 'ONE CHARGE';

        update acc;

        List<Alert__c> alertList = [SELECT Id
                                    FROM Alert__c
                                    WHERE Terms_Related_Alert__c = true];

        System.assertEquals(1, alertList.size());
    }

    @IsTest
    static void testCreateAlertForARMaxWarning(){
        Account acc = [SELECT id FROM Account LIMIT 1];
        acc.Terms__c = 'CHECK';
        acc.AgeOldestOpenItem__c = 6;

        update acc;

        List<Alert__c> alertList = [SELECT Id
                                    FROM Alert__c
                                    WHERE Terms_Related_Alert__c = true];

        System.assertEquals(1, alertList.size());
    }
}