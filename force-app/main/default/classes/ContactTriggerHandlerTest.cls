@isTest
private class ContactTriggerHandlerTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Contact c = TestFactory.createContact(testAccount.Id, 'Test', 'Contact', 'test@gmail.com');
        c.Receive_Delivery_Notifications__c = true;
        c.WebContact__c = true;
        update c;
    }

    static Contact getContact(){
        return [SELECT Id, Email, Receive_Delivery_Notifications__c, WebContact__c
                FROM Contact
                LIMIT 1];
    }

    static Account getAccount(){
        return [SELECT Id, Opted_in_for_Delivery_Notifications__c, Web_Contact__c
                FROM Account
                LIMIT 1];
    }

    @isTest
    public static void testUpdateAccountContactRelationForChangedEmail(){
        Contact testContact = getContact();
        Contact testContactOld = getContact();
        testContactOld.Email = 'test1@gamil.com';
        testContact.Email = 'test@gmail.com';
        update testContact;

        Test.startTest();
            ContactTriggerHandler.updateAccountContactRelationForChangedEmail(new List<Contact>{testContact}, 
                                                                new Map<Id, Contact>{testContactOld.Id => testContactOld});
        Test.stopTest();

        List<AccountContactRelation> accountContactRelationList = [SELECT Id, ExternalId__c, AccountId, Account.ExternalId__c, ContactId, Contact.Email FROM AccountContactRelation];

        System.assertEquals(accountContactRelationList[0].ExternalId__c, '72245*test@gmail.com', 'ExternalId should be 72245*test@gmail.com');
    }

    @isTest
    public static void testDeleteContact(){
        Contact testContact = getContact();
        Account testAccount = getAccount();
        System.assertEquals(true, testAccount.Opted_in_for_Delivery_Notifications__c, 'Delivery Notifications should be true');
        System.assertEquals(true, testAccount.Web_Contact__c, 'Web Contact should be true');
        Test.startTest();
           delete testContact;
        Test.stopTest();

        testAccount = getAccount();
        System.assertEquals(false, testAccount.Opted_in_for_Delivery_Notifications__c, 'Delivery Notifications should be false');
        System.assertEquals(false, testAccount.Web_Contact__c, 'Web Contact should be false');
    }

    @isTest
    public static void testUpdateContact(){
        Contact testContact = getContact();
        Account testAccount = getAccount();
        System.assertEquals(true, testAccount.Opted_in_for_Delivery_Notifications__c, 'Delivery Notifications should be true');
        System.assertEquals(true, testAccount.Web_Contact__c, 'Web Contact should be true');
        
        Test.startTest();
            testContact.Receive_Delivery_Notifications__c = false;
            testContact.WebContact__c = false;
            update testContact;
        Test.stopTest();

        testAccount = getAccount();
        System.assertEquals(false, testAccount.Opted_in_for_Delivery_Notifications__c, 'Delivery Notifications should be false');
        System.assertEquals(false, testAccount.Web_Contact__c, 'Web Contact should be false');
    }
}