@isTest
private class ChatbotCreateCaseTest {
    @testSetup
    private static void setup() {
        Account acc = new Account(
            Name = 'ChatbotCreateCaseTestAccount'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'ChatbotCreateCase',
            LastName = 'TestAccountContact',
            AccountId = acc.Id
        );
        insert con;

        LiveChatVisitor chasitor = new LiveChatVisitor();
        insert chasitor;

        LiveChatTranscript transcript = new LiveChatTranscript(
            LiveChatVisitorId = chasitor.Id,
            ContactId = con.Id
        );
        insert transcript;
    }

    private static Account getTestAccount() {
        return [
            SELECT Id
            FROM Account
            LIMIT 1
        ];
    }

    private static Contact getTestContact() {
        return [
            SELECT Id, FirstName, LastName
            FROM Contact
            LIMIT 1
        ];
    }

    private static LiveChatTranscript getTestTranscript() {
        return [
            SELECT Id
            FROM LiveChatTranscript
            LIMIT 1
        ];
    }

    @isTest
    private static void testCreateBeerlineSupportCase() {
        ChatbotCreateBeerlineSupportCase.ResponsesInput input = new ChatbotCreateBeerlineSupportCase.ResponsesInput();
        input.accountId = getTestAccount().Id;
        input.contactId = getTestContact().Id;
        input.transcriptId = getTestTranscript().Id;
        input.firstName = getTestContact().FirstName;
        input.lastName = getTestContact().LastName;
        input.beerlineSupportType = 'Account Deactivated';

        List<ChatbotCreateBeerlineSupportCase.ResponsesOutput> output = ChatbotCreateBeerlineSupportCase.createCase(new List<ChatbotCreateBeerlineSupportCase.ResponsesInput>{input});
        List<Case> newCase = [
            SELECT Id, Issue_Sub_Type__c
            FROM Case
            WHERE RecordType.Name = 'SipMarket User Support'
        ];
        System.assertEquals('Account Deactivated', newCase[0].Issue_Sub_Type__c);
    }

    @isTest
    private static void testCreateDraftServiceCase() {
        ChatbotCreateDraftServiceCase.ResponsesInput input = new ChatbotCreateDraftServiceCase.ResponsesInput();
        input.accountId = getTestAccount().Id;
        input.contactId = getTestContact().Id;
        input.transcriptId = getTestTranscript().Id;
        input.firstName = getTestContact().FirstName;
        input.lastName = getTestContact().LastName;
        input.serviceType = 'Tap Handle';
        input.serviceSubtype = 'New Tap Handle';
        input.beverageBrand = 'Coors';

        List<ChatbotCreateDraftServiceCase.ResponsesOutput> output = ChatbotCreateDraftServiceCase.createCase(new List<ChatbotCreateDraftServiceCase.ResponsesInput>{input});
        List<Case> newCase = [
            SELECT Id, Issue_Sub_Type__c
            FROM Case
            WHERE RecordType.Name = 'Draft Service Request'
        ];
        System.assertEquals('New Tap Handle', newCase[0].Issue_Sub_Type__c);
    }

    @isTest
    private static void testCreateEcomSupportCase() {
        ChatbotCreateEcomSupportCase.ResponsesInput input = new ChatbotCreateEcomSupportCase.ResponsesInput();
        input.accountId = getTestAccount().Id;
        input.contactId = getTestContact().Id;
        input.transcriptId = getTestTranscript().Id;
        input.firstName = getTestContact().FirstName;
        input.lastName = getTestContact().LastName;
        input.ecomSupportType = 'Charity Request';
        input.additionalComments = 'n/a';

        List<ChatbotCreateEcomSupportCase.ResponsesOutput> output = ChatbotCreateEcomSupportCase.createCase(new List<ChatbotCreateEcomSupportCase.ResponsesInput>{input});
        List<Case> newCase = [
            SELECT Id, Issue_Sub_Type__c
            FROM Case
            WHERE RecordType.Name = 'Ecom Support'
        ];
        System.assertEquals('Charity Request', newCase[0].Issue_Sub_Type__c);
    }

    @isTest
    private static void testCreatePOSCase() {
        ChatbotCreatePOSCase.ResponsesInput input = new ChatbotCreatePOSCase.ResponsesInput();
        input.accountId = getTestAccount().Id;
        input.contactId = getTestContact().Id;
        input.transcriptId = getTestTranscript().Id;
        input.firstName = getTestContact().FirstName;
        input.lastName = getTestContact().LastName;
        input.posRequestType = 'Coasters';
        input.beverageBrand = 'Coors';
        input.morePOS = 'Pint Glasses';

        List<ChatbotCreatePOSCase.ResponsesOutput> output = ChatbotCreatePOSCase.createCase(new List<ChatbotCreatePOSCase.ResponsesInput>{input});
        List<Case> newCase = [
            SELECT Id, POS_Request_Type__c
            FROM Case
            WHERE RecordType.Name = 'POS Request'
        ];
        System.assertEquals('Coasters', newCase[0].POS_Request_Type__c);
    }

    @isTest
    private static void testCreatePrintShopCase() {
        ChatbotCreatePrintShopCase.ResponsesInput bannerInput = new ChatbotCreatePrintShopCase.ResponsesInput();
        bannerInput.accountId = getTestAccount().Id;
        bannerInput.contactId = getTestContact().Id;
        bannerInput.transcriptId = getTestTranscript().Id;
        bannerInput.firstName = getTestContact().FirstName;
        bannerInput.lastName = getTestContact().LastName;
        bannerInput.psrType = 'Banner';
        bannerInput.bannerType = 'Indoor';
        bannerInput.printShopItemQty = '1';
        bannerInput.printShopItemSize = '3\'';
        bannerInput.brand = 'Coors';
        bannerInput.productPricing = '$25';
        bannerInput.isSpecialEvent = 'Yes';
        bannerInput.specialEventDateTime = 'Next week at 3pm EST';
        bannerInput.eventDetails = 'n/a';
        bannerInput.additionalComments = 'n/a';

        ChatbotCreatePrintShopCase.ResponsesInput posterInput = new ChatbotCreatePrintShopCase.ResponsesInput();
        posterInput.accountId = getTestAccount().Id;
        posterInput.contactId = getTestContact().Id;
        posterInput.transcriptId = getTestTranscript().Id;
        posterInput.firstName = getTestContact().FirstName;
        posterInput.lastName = getTestContact().LastName;
        posterInput.psrType = 'Poster';
        posterInput.printShopItemQty = '1';
        posterInput.printShopItemSize = '24x36';
        posterInput.brand = 'Coors';
        posterInput.productPricing = '$15';
        posterInput.isSpecialEvent = 'No';
        posterInput.eventDetails = 'n/a';
        posterInput.additionalComments = 'n/a';

        ChatbotCreatePrintShopCase.ResponsesInput tableTentInput = new ChatbotCreatePrintShopCase.ResponsesInput();
        tableTentInput.accountId = getTestAccount().Id;
        tableTentInput.contactId = getTestContact().Id;
        tableTentInput.transcriptId = getTestTranscript().Id;
        tableTentInput.firstName = getTestContact().FirstName;
        tableTentInput.lastName = getTestContact().LastName;
        tableTentInput.psrType = 'Table Tent';
        tableTentInput.printShopItemQty = '1';
        tableTentInput.printShopItemSize = '4\'x5\'';
        tableTentInput.brand = 'Coors';
        tableTentInput.productPricing = '$5';
        tableTentInput.isSpecialEvent = 'Yes';
        tableTentInput.specialEventDateTime = 'Next Saturday at 2pm EST';
        tableTentInput.eventDetails = 'n/a';
        tableTentInput.additionalComments = 'n/a';

        List<ChatbotCreatePrintShopCase.ResponsesOutput> bannerOutput = ChatbotCreatePrintShopCase.createCase(new List<ChatbotCreatePrintShopCase.ResponsesInput>{bannerInput});
        List<ChatbotCreatePrintShopCase.ResponsesOutput> posterOutput = ChatbotCreatePrintShopCase.createCase(new List<ChatbotCreatePrintShopCase.ResponsesInput>{posterInput});
        List<ChatbotCreatePrintShopCase.ResponsesOutput> tableTentOutput = ChatbotCreatePrintShopCase.createCase(new List<ChatbotCreatePrintShopCase.ResponsesInput>{tableTentInput});

        List<Case> bannerCase = [
            SELECT Id, PSR_Indoor_Outdoor__c
            FROM Case
            WHERE RecordType.Name = 'Print Shop Request'
            AND PSR_Sign_Type__c = 'Banner'
        ];
        List<Case> posterCase = [
            SELECT Id, PSR_Poster_Size__c
            FROM Case
            WHERE RecordType.Name = 'Print Shop Request'
            AND PSR_Sign_Type__c = 'Poster'
        ];
        List<Case> tableTentCase = [
            SELECT Id, PSR_Product_Pricing__c
            FROM Case
            WHERE RecordType.Name = 'Print Shop Request'
            AND PSR_Sign_Type__c = 'Table Tent'
        ];
        System.assertEquals('Indoor', bannerCase[0].PSR_Indoor_Outdoor__c);
        System.assertEquals('24x36', posterCase[0].PSR_Poster_Size__c);
        System.assertEquals('$5', tableTentCase[0].PSR_Product_Pricing__c);
    }

    @isTest
    private static void testCreateVisitRequestCase() {
        ChatbotCreateVisitRequestCase.ResponsesInput input = new ChatbotCreateVisitRequestCase.ResponsesInput();
        input.accountId = getTestAccount().Id;
        input.contactId = getTestContact().Id;
        input.transcriptId = getTestTranscript().Id;
        input.firstName = getTestContact().FirstName;
        input.lastName = getTestContact().LastName;
        input.purposeOfVisit = 'Request a Business Review';
        input.additionalComments = 'n/a';

        List<ChatbotCreateVisitRequestCase.ResponsesOutput> output = ChatbotCreateVisitRequestCase.createCase(new List<ChatbotCreateVisitRequestCase.ResponsesInput>{input});
        List<Case> newCase = [
            SELECT Id, Purpose_of_Visit__c
            FROM Case
            WHERE RecordType.Name = 'Visit Request'
        ];
        System.assertEquals('Request a Business Review', newCase[0].Purpose_of_Visit__c);
    }
}