@isTest
private class ChatbotTranslationResponseTest {
    @isTest
    private static void testGetChatbotTranslation() {
        ChatbotTranslationResponse.TranslationInput input = new ChatbotTranslationResponse.TranslationInput();
        input.languageCode = 'es';
        input.associatedDialog = 'Draft Help Create Case';

        List<ChatbotTranslationResponse.TranslationOutput> output = ChatbotTranslationResponse.getChatbotTranslation(new List<ChatbotTranslationResponse.TranslationInput>{input});
        System.assertEquals('Siento mucho que esté teniendo problemas con sus borradores.  Elija una de estas opciones para su solicitud.', output[0].translation);
    }
}