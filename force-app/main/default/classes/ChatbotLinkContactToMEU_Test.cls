@isTest
public class ChatbotLinkContactToMEU_Test {
    private static String createTestData() {
        //Create and retrieve the User for Messaging
        MessagingEndUser meu = new MessagingEndUser();
        meu.Name = '+11234567890';
        meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        meu.MessageType = 'Text';
        meu.MessagingPlatformKey = '123';
        insert meu;

        //Create and retrieve the Test Message
        MessagingSession ms = new MessagingSession();
        ms.MessagingEndUserId = meu.Id;
        ms.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
        ms.Status = 'Waiting';
        insert ms;

        Contact c = new Contact();
        c.LastName = 'Test';
        c.Phone = '1234567890';
        insert c;

        return meu.Id;
    }    
    
    static testMethod void correctPhoneNumber() {
        string meuId = createTestData();

        List<ChatbotLinkContactToMEU.ResponseInput> riList = new List<ChatbotLinkContactToMEU.ResponseInput>();
        ChatbotLinkContactToMEU.ResponseInput ri = new ChatbotLinkContactToMEU.ResponseInput();
        ri.messagingEndUserId = meuId;
        ri.messagingEndUserName = '+11234567890';
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotLinkContactToMEU.ResponseOutput> roList = ChatbotLinkContactToMEU.linkContacttoMEU(riList);
        Test.stopTest();

        ChatbotLinkContactToMEU.ResponseOutput ro = roList[0];

        System.assertEquals(true, ro.isSuccess);

    }

    static testMethod void blankPhoneNumber() {
        string meuId = createTestData();

        List<ChatbotLinkContactToMEU.ResponseInput> riList = new List<ChatbotLinkContactToMEU.ResponseInput>();
        ChatbotLinkContactToMEU.ResponseInput ri = new ChatbotLinkContactToMEU.ResponseInput();
        ri.messagingEndUserId = meuId;
        ri.messagingEndUserName = '';
        riList.add(ri);

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotLinkContactToMEU.ResponseOutput> roList = ChatbotLinkContactToMEU.linkContacttoMEU(riList);
        Test.stopTest();

        ChatbotLinkContactToMEU.ResponseOutput ro = roList[0];

        System.assertEquals(false, ro.isSuccess);
    }
}