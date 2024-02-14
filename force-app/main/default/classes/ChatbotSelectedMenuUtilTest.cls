@isTest
private class ChatbotSelectedMenuUtilTest {
    @isTest
    private static void testPopulateVariable() {
        ChatbotSelectedMenuUtil.ResponsesInput input = new ChatbotSelectedMenuUtil.ResponsesInput();
        ChatbotGetMenus.MenuOutput selectedMenu = new ChatbotGetMenus.MenuOutput();
        selectedMenu.englishChoice = 'Hello';
        selectedMenu.translatedChoice = 'Hola';
        input.selectedMenu = selectedMenu;

        List<ChatbotSelectedMenuUtil.ResponsesOutput> output = ChatbotSelectedMenuUtil.populateVariable(new List<ChatbotSelectedMenuUtil.ResponsesInput>{input});
        System.assertEquals('Hello', output[0].selectedMenuEnglish);
    }
}