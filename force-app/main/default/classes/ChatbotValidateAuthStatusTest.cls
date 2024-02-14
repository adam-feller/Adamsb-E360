@isTest
private class ChatbotValidateAuthStatusTest {
    @isTest
    private static void testValidateAuthStatus() {
        Account acc = new Account(
            Name = 'ChatbotValidateAuthStatusTestAccount',
            ExternalId__c = 'FDI*11159'
        );
        insert acc;

        ChatbotValidateAuthStatus.ResponsesInput authInput = new ChatbotValidateAuthStatus.ResponsesInput();
        authInput.lastCustomerInput = '{"[SIGNIN-STATUS]":{"Success":true,"FirstName":"MixMatch","LastName":"Test","Email":"MixItUp@testreyes.com","BusinessUnitId":"FDI","AccountNumber":"11159"}}';
        
        ChatbotValidateAuthStatus.ResponsesInput guestInput = new ChatbotValidateAuthStatus.ResponsesInput();
        guestInput.lastCustomerInput = '{"[SIGNIN-STATUS]":{"Success":false,"FirstName":"","LastName":"","Email":"","BusinessUnitId":"","AccountNumber":""}}';
        
        ChatbotValidateAuthStatus.ResponsesInput otherInput = new ChatbotValidateAuthStatus.ResponsesInput();
        otherInput.lastCustomerInput = 'Hello';
        otherInput.isAuthenticated = true;
        otherInput.firstName = 'ChatbotValidateAuthStatus';
        otherInput.lastName = 'Test';
        otherInput.email = 'chatbotvalidateauthstatus@reyestest.com';
        otherInput.businessUnitId = 'ABC';
        otherInput.accountNumber = '12345';
        otherInput.accountId = acc.Id;

        List<ChatbotValidateAuthStatus.ResponsesOutput> authOutput = ChatbotValidateAuthStatus.validateAuthStatus(new List<ChatbotValidateAuthStatus.ResponsesInput>{authInput});
        List<ChatbotValidateAuthStatus.ResponsesOutput> guestOutput = ChatbotValidateAuthStatus.validateAuthStatus(new List<ChatbotValidateAuthStatus.ResponsesInput>{guestInput});
        List<ChatbotValidateAuthStatus.ResponsesOutput> otherOutput = ChatbotValidateAuthStatus.validateAuthStatus(new List<ChatbotValidateAuthStatus.ResponsesInput>{otherInput});
        
        System.assertEquals('FDI', authOutput[0].businessUnitId);
        System.assertEquals(false, guestOutput[0].isAuthenticated);
        System.assertEquals('12345', otherOutput[0].accountNumber);
    }
}