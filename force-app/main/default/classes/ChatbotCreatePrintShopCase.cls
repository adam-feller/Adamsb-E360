public class ChatbotCreatePrintShopCase {
    @InvocableMethod(label='Create Print Shop Request Case')
    public static List<ResponsesOutput> createCase(List<ResponsesInput> responsesInput) {
        ResponsesOutput output = new ResponsesOutput();
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();

        // Define initial values
        String caseType = 'Print Shop Request';
        String caseId = '';
        output.caseNumber = '';

        // New case with default values
        Case c = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseType).getRecordTypeId(),
            Type = caseType,
            Subject = responsesInput[0].firstName + ' ' + responsesInput[0].lastName + ' ' + caseType,
            Status = 'Open',
            Priority = 'Medium',
            Origin = 'Chat',
            Brand__c = responsesInput[0].brand,
            PSR_Sign_Type__c = responsesInput[0].psrType,
            PSR_Product_Pricing__c = responsesInput[0].productPricing,
            PSR_Special_Event__c = responsesInput[0].isSpecialEvent == 'Yes' ? true : false,
            PSR_Event_Details__c = responsesInput[0].eventDetails,
            Description = responsesInput[0].additionalComments
        );
        if (String.isNotBlank(responsesInput[0].accountId)) {
            c.AccountId = responsesInput[0].accountId;
        }
        if (String.isNotBlank(responsesInput[0].contactId)) {
            c.ContactId = responsesInput[0].contactId;
        }
        if (responsesInput[0].isSpecialEvent == 'Yes') {
            c.PSR_Special_Event_Date_and_Time__c = responsesInput[0].specialEventDateTime;
        }
        if (responsesInput[0].psrType == 'Banner') {
            c.PSR_Indoor_Outdoor__c = responsesInput[0].bannerType;
            c.PSR_Banner_Size__c = responsesInput[0].printShopItemSize;
            c.PSR_Banner_Quantity__c = responsesInput[0].printShopItemQty;
        }
        else if (responsesInput[0].psrType == 'Poster') {
            c.PSR_Poster_Size__c = responsesInput[0].printShopItemSize;
            c.PSR_Poster_Quantity__c = responsesInput[0].printShopItemQty;
        }
        else if (responsesInput[0].psrType == 'Table Tent') {
            c.PSR_Table_Tent__c = responsesInput[0].printShopItemSize;
            c.PSR_Table_Tent_Quantity__c = responsesInput[0].printShopItemQty;
        }

        try {
            insert c;
            caseId = c.Id;

            Case newCase = [
                SELECT Id, CaseNumber
                FROM Case
                WHERE Id = :c.Id
                LIMIT 1
            ];
            output.caseNumber = newCase.CaseNumber;
        } catch (DmlException e) {
            System.debug('Error inserting case: ' + e.getMessage());
        }

        if (String.isNotBlank(caseId)) {
            LiveChatTranscript transcript = [
                SELECT Id, CaseId
                FROM LiveChatTranscript
                WHERE Id = :responsesInput[0].transcriptId
                LIMIT 1
            ];
            transcript.CaseId = caseId;

            try {
                update transcript;
            } catch (DmlException e) {
                System.debug('Error updating transcript: ' + e.getMessage());
            }
        }

        outputList.add(output);
        return outputList;
    }

    public class ResponsesInput {
        @InvocableVariable(required=false)
        public String accountId;

        @InvocableVariable(required=false)
        public String contactId;

        @InvocableVariable(required=true)
        public String transcriptId;

        @InvocableVariable(required=true)
        public String firstName;

        @InvocableVariable(required=true)
        public String lastName;

        @InvocableVariable(required=true)
        public String psrType;

        @InvocableVariable(required=false)
        public String bannerType;

        @InvocableVariable(required=true)
        public String printShopItemSize;

        @InvocableVariable(required=true)
        public String printShopItemQty;

        @InvocableVariable(required=true)
        public String brand;

        @InvocableVariable(required=true)
        public String productPricing;

        @InvocableVariable(required=true)
        public String isSpecialEvent;

        @InvocableVariable(required=false)
        public String specialEventDateTime;

        @InvocableVariable(required=true)
        public String eventDetails;

        @InvocableVariable(required=true)
        public String additionalComments;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=true)
        public String caseNumber;
    }
}