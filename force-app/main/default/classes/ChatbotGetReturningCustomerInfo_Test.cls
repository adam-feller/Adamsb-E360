@isTest
public class ChatbotGetReturningCustomerInfo_Test {
    public static string createDataReturningCustomer() {
        //Create and retrieve the Account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;

        Account createdAccount = [SELECT Id FROM Account LIMIT 1];

        //Create and retrieve the Contact
        Contact c = new Contact();
        c.AccountId = createdAccount.Id;
        c.LastName = 'Testerson';
        c.Phone = '1234567890';
        insert c;

        Contact createdContact = [SELECT Id FROM Contact LIMIT 1];

        //Create and retrieve the TTO_Authorization
        TTO_Authorization__c ttoAuth = new TTO_Authorization__c();
        ttoAuth.Account__c = createdAccount.Id;
        ttoAuth.Contact__c = createdContact.Id;
        insert ttoAuth;

        //Create and retrieve the User for Messaging
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = '+11234567890';
        meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        meu.MessageType = 'Text';
        meu.MessagingPlatformKey = '123';
        meu.ContactId = createdContact.Id;
        insert meu;

        MessagingEndUser createdMEU = [SELECT Id FROM MessagingEndUser LIMIT 1];

        //Create and retrieve the Test Message
        MessagingSession ms = new MessagingSession();
        ms.MessagingEndUserId = createdMEU.Id;
        ms.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        ms.Status = 'Waiting';
        ms.Selected_Account__c = createdAccount.Id;
        insert ms;

        return createdMEU.Id;
    }

    public static string createDataNonReturningCustomer() {
        //Create and retrieve the Account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;

        Account createdAccount = [SELECT Id FROM Account LIMIT 1];

        //Create and retrieve the Contact
        Contact c = new Contact();
        c.AccountId = createdAccount.Id;
        c.LastName = 'Testerson';
        c.Phone = '1234567890';
        insert c;

        Contact createdContact = [SELECT Id FROM Contact LIMIT 1];

        //Create and retrieve the TTO_Authorization
        TTO_Authorization__c ttoAuth = new TTO_Authorization__c();
        ttoAuth.Account__c = createdAccount.Id;
        ttoAuth.Contact__c = createdContact.Id;
        insert ttoAuth;

        //Create and retrieve the User for Messaging
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = '+11234567890';
        meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        meu.MessageType = 'Text';
        meu.MessagingPlatformKey = '123';
        meu.ContactId = createdContact.Id;
        insert meu;

        MessagingEndUser createdMEU = [SELECT Id FROM MessagingEndUser LIMIT 1];

        return createdMEU.Id;
    }

    static testMethod void isReturningCustomer() {
        string meuId = createDataReturningCustomer();

        List<ChatbotGetReturningCustomerInfo.ResponseInput> riList = new List<ChatbotGetReturningCustomerInfo.ResponseInput>();
        ChatbotGetReturningCustomerInfo.ResponseInput ri = new ChatbotGetReturningCustomerInfo.ResponseInput();
        ri.messagingUserId = meuId;
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotGetReturningCustomerInfo.ResponseOutput> roList = ChatbotGetReturningCustomerInfo.getReturningCustomerInfo(riList);
        Test.stopTest();

        ChatbotGetReturningCustomerInfo.ResponseOutput ro = roList[0];

        System.assertEquals(true, ro.isReturning);
    }

    static testMethod void isNotReturningCustomer() {
        string meuId = createDataNonReturningCustomer();

        List<ChatbotGetReturningCustomerInfo.ResponseInput> riList = new List<ChatbotGetReturningCustomerInfo.ResponseInput>();
        ChatbotGetReturningCustomerInfo.ResponseInput ri = new ChatbotGetReturningCustomerInfo.ResponseInput();
        ri.messagingUserId = meuId;
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotGetReturningCustomerInfo.ResponseOutput> roList = ChatbotGetReturningCustomerInfo.getReturningCustomerInfo(riList);
        Test.stopTest();

        ChatbotGetReturningCustomerInfo.ResponseOutput ro = roList[0];

        System.assertEquals(false, ro.isReturning);
    }
}