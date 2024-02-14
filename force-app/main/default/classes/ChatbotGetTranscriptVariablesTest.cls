@isTest
private class ChatbotGetTranscriptVariablesTest {
    @isTest
    private static void testGetTranscriptVariables() {
        LiveChatVisitor chasitor = new LiveChatVisitor();
        insert chasitor;

        LiveChatTranscript transcript = new LiveChatTranscript(
            LiveChatVisitorId = chasitor.Id,
            First_Name__c = 'ChatbotGetTranscriptVariables',
            Last_Name__c = 'Test',
            Email__c = 'chatbotgettranscriptvariablestest@reyestest.com',
            Is_Authenticated__c = false,
            Business_Unit_ID__c = 'ABC',
            Account_Number__c = '12345',
            Language__c = 'en'
        );
        insert transcript;

        ChatbotGetTranscriptVariables.TranscriptInput input = new ChatbotGetTranscriptVariables.TranscriptInput();
        input.routableID = transcript.Id;

        List<ChatbotGetTranscriptVariables.TranscriptOutput> output = ChatbotGetTranscriptVariables.getTranscriptVariables(new List<ChatbotGetTranscriptVariables.TranscriptInput>{input});
        System.assertEquals('ChatbotGetTranscriptVariables', output[0].sFirstName);
    }
}