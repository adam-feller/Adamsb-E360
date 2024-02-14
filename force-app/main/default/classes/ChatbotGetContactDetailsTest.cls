@isTest
private class ChatbotGetContactDetailsTest {
    @isTest
    private static void testGetContactDetails() {
        Contact con = new Contact(
            LastName = 'ChatbotGetContactDetailsTest',
            Email = 'chatbotgetcontactdetailstest@reyestest.com'
        );
        insert con;

        ChatbotGetContactDetails.ResponsesInput input = new ChatbotGetContactDetails.ResponsesInput();
        input.contactId = con.Id;

        List<ChatbotGetContactDetails.ResponsesOutput> output = ChatbotGetContactDetails.getContactDetails(new List<ChatbotGetContactDetails.ResponsesInput>{input});
        System.assertEquals('chatbotgetcontactdetailstest@reyestest.com', output[0].email);
    }
}