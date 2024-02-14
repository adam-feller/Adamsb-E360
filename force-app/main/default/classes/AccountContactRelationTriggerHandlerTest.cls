@isTest
private class AccountContactRelationTriggerHandlerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2346');
        Contact c = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test2@gmail.com');
        c.Receive_Delivery_Notifications__c = true;
        c.WebContact__c = true;
        update c; 
    }

    static Account getAccount(){
        return [SELECT Id, Name, Opted_in_for_Delivery_Notifications__c, Web_Contact__c
                FROM Account
                LIMIT 1];
    }

    static Contact getContact(){
        return [SELECT Id, Name, Receive_Delivery_Notifications__c, WebContact__c
                FROM Contact
                LIMIT 1];
    }
    
    static AccountContactRelation getACR(){
        return [SELECT Id, IsActive
                FROM AccountContactRelation
                LIMIT 1];
    }


    @isTest
    static void testProcessAccountContactRelationIntegration(){
        Account testAccount = getAccount();
        Contact testContact = getContact();
        AccountContactRelation testAccountContactRelation = new AccountContactRelation();
        testAccountContactRelation.AccountId = testAccount.Id;
        testAccountContactRelation.ContactId = testContact.Id;

        Test.startTest();
            AccountContactRelationTriggerHandler.processAccountContactRelationIntegration(new List<AccountContactRelation>{testAccountContactRelation});
        Test.stopTest();

        List<AccountContactRelation> accountContactRelationList = [SELECT Id, ExternalId__c FROM AccountContactRelation];

        System.assertEquals(accountContactRelationList[0].ExternalId__c, '72245*test2@gmail.com', 'ExternalId should be 72245*test2@gmail.com');
    }
    @isTest
    static void testUpdateACRInactive(){
        AccountContactRelation testACR = getACR();
        Account testAccount = getAccount();
        System.assertEquals(true, testACR.IsActive, 'ACR IsActive should be true');
        System.assertEquals(true, testAccount.Opted_in_for_Delivery_Notifications__c, 'Account should be true');
        System.assertEquals(true, testAccount.Web_Contact__c, 'Account Web Contact should be true');

        Test.startTest();
        testACR.IsActive = false;
        update testACR;
        Test.stopTest();

        testAccount = getAccount();
        System.assertEquals(false, testAccount.Opted_in_for_Delivery_Notifications__c, 'Account Delivery Notifications should be false');
        System.assertEquals(false, testAccount.Web_Contact__c, 'Account Web Contact should be false');
    }
}