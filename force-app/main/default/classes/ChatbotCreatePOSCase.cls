public class ChatbotCreatePOSCase {
    @InvocableMethod(label='Create POS Case')
    public static List<ResponsesOutput> createCase(List<ResponsesInput> responsesInput) {
        ResponsesOutput output = new ResponsesOutput();
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();

        // Define initial values
        String caseType = 'POS Request';
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
            POS_Request_Type__c = responsesInput[0].posRequestType,
            Description = 'Brand customer is looking for: ' + responsesInput[0].beverageBrand + '. Other brands or POS customer is looking for: ' + responsesInput[0].morePOS + '.'
        );
        if (String.isNotBlank(responsesInput[0].accountId)) {
            c.AccountId = responsesInput[0].accountId;
        }
        if (String.isNotBlank(responsesInput[0].contactId)) {
            c.ContactId = responsesInput[0].contactId;
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
        public String posRequestType;

        @InvocableVariable(required=true)
        public String beverageBrand;

        @InvocableVariable(required=true)
        public String morePOS;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=true)
        public String caseNumber;
    }
}