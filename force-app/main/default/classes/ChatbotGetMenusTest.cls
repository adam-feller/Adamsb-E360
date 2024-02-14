@isTest
private class ChatbotGetMenusTest {
    @isTest
    private static void testGetMenus() {
        ChatbotGetMenus.MenuInput input = new ChatbotGetMenus.MenuInput();
        input.languageCode = 'es';
        input.associatedDialog = 'Guest Main Menu';

        List<List<ChatbotGetMenus.MenuOutput>> output = ChatbotGetMenus.getMenus(new List<ChatbotGetMenus.MenuInput>{input});
        System.assertEquals('Logging In', output[0][0].englishChoice);
        System.assertEquals('FAQ', output[0][1].englishChoice);
    }
}