@isTest
public class ChatbotAuthorizationCheck_Test {
    public static string createDataSingleAuth() { 
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
        insert ms;

        return createdMEU.Id;
    }

    public static string createDataMultipleAuth() { 
        //Create and retrieve the Account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;

        Account createdAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        //Create and retrieve the Account
        Account a2 = new Account();
        a2.Name = 'TestAccount2';
        insert a2;

        Account createdAccount2 = [SELECT Id FROM Account WHERE Name = 'TestAccount2' LIMIT 1];

        //Create and retrieve the Contact
        Contact c = new Contact();
        c.AccountId = createdAccount.Id;
        c.LastName = 'Testerson';
        c.Phone = '1234567890';
        insert c;

        Contact createdContact = [SELECT Id FROM Contact LIMIT 1];

        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = createdAccount2.Id;
        acr.ContactId = createdContact.Id;
        insert acr;

        //Create and retrieve the TTO_Authorization
        TTO_Authorization__c ttoAuth = new TTO_Authorization__c();
        ttoAuth.Account__c = createdAccount.Id;
        ttoAuth.Contact__c = createdContact.Id;
        insert ttoAuth;

        //Create and retrieve the TTO_Authorization
        TTO_Authorization__c ttoAuth2 = new TTO_Authorization__c();
        ttoAuth2.Account__c = acr.AccountId;
        ttoAuth2.Contact__c = createdContact.Id;
        insert ttoAuth2;

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
        insert ms;

        return createdMEU.Id;
    }

    public static string createDataRep() { 
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

        //Create and retrieve the User for Messaging
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = '+11234567890';
        meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        meu.MessageType = 'Text';
        meu.MessagingPlatformKey = '123';
        meu.Is_Rep__c = true;
        insert meu;

        MessagingEndUser createdMEU = [SELECT Id FROM MessagingEndUser LIMIT 1];

        //Create and retrieve the Test Message
        MessagingSession ms = new MessagingSession();
        ms.MessagingEndUserId = createdMEU.Id;
        ms.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        ms.Status = 'Waiting';
        insert ms;

        return createdMEU.Id;
    }
    
    static testMethod void getAuthRecordSingle() {
		string meuId = createDataSingleAuth();

        List<ChatbotAuthotizationCheck.ResponseInput> riList = new List<ChatbotAuthotizationCheck.ResponseInput>();
        ChatbotAuthotizationCheck.ResponseInput ri = new ChatbotAuthotizationCheck.ResponseInput();
        ri.messagingUserId = meuId;
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotAuthotizationCheck.ResponseOutput> roList = ChatbotAuthotizationCheck.checkAuthorizationRecords(riList);
        Test.stopTest();

        ChatbotAuthotizationCheck.ResponseOutput ro = roList[0];

        System.assertEquals(true, ro.isAuthSingle);
        System.assertEquals(false, ro.isAuthMultiple);
    }

    static testMethod void getAuthRecordMultiple() {
		string meuId = createDataMultipleAuth();

        List<ChatbotAuthotizationCheck.ResponseInput> riList = new List<ChatbotAuthotizationCheck.ResponseInput>();
        ChatbotAuthotizationCheck.ResponseInput ri = new ChatbotAuthotizationCheck.ResponseInput();
        ri.messagingUserId = meuId;
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotAuthotizationCheck.ResponseOutput> roList = ChatbotAuthotizationCheck.checkAuthorizationRecords(riList);
        Test.stopTest();

        ChatbotAuthotizationCheck.ResponseOutput ro = roList[0];

        System.assertEquals(false, ro.isAuthSingle);
        System.assertEquals(true, ro.isAuthMultiple);
    }

    static testMethod void getAuthRecordRep() {
		string meuId = createDataRep();

        List<ChatbotAuthotizationCheck.ResponseInput> riList = new List<ChatbotAuthotizationCheck.ResponseInput>();
        ChatbotAuthotizationCheck.ResponseInput ri = new ChatbotAuthotizationCheck.ResponseInput();
        ri.messagingUserId = meuId;
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotAuthotizationCheck.ResponseOutput> roList = ChatbotAuthotizationCheck.checkAuthorizationRecords(riList);
        Test.stopTest();

        ChatbotAuthotizationCheck.ResponseOutput ro = roList[0];

        System.assertEquals(true, ro.isRep);
    }
}