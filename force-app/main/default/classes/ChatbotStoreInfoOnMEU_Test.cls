@isTest
public class ChatbotStoreInfoOnMEU_Test {
    public static string createData() {
        //Create and retrieve the Account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;

        Account createdAccount = [SELECT Id, Name FROM Account LIMIT 1];

        //Create and retrieve the User for Messaging
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = '+11234567890';
        meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        meu.MessageType = 'Text';
        meu.MessagingPlatformKey = '123';
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

    static testMethod void associateSelectedAccount() {
        //Create and retrieve the Account
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;

        Account createdAccount = [SELECT Id, Name FROM Account LIMIT 1];

        //Create and retrieve the User for Messaging
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = '+11234567890';
        meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        meu.MessageType = 'Text';
        meu.MessagingPlatformKey = '123';
        insert meu;

        MessagingEndUser createdMEU = [SELECT Id FROM MessagingEndUser LIMIT 1];

        //Create and retrieve the Test Message
        MessagingSession ms = new MessagingSession();
        ms.MessagingEndUserId = createdMEU.Id;
        ms.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        ms.Status = 'Waiting';
        ms.Selected_Account__c = a.Id;
        insert ms;

        List<ChatbotStoreInfoOnMEU.ResponseInput> riList = new List<ChatbotStoreInfoOnMEU.ResponseInput>();
        ChatbotStoreInfoOnMEU.ResponseInput ri = new ChatbotStoreInfoOnMEU.ResponseInput();
        ri.routableId = ms.Id;
        ChatbotAuthotizationCheck.AccountOption ao = new ChatbotAuthotizationCheck.AccountOption();
        ao.Name = createdAccount.Name;
        ao.Id = createdAccount.Id;
        ri.selectedAccount = ao;
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotStoreInfoOnMEU.ResponseOutput> roList = ChatbotStoreInfoOnMEU.setAccountInfo(riList);
        Test.stopTest();

        System.assertEquals(true, roList[0].didSucceed);
    }
}