public class ChatbotGetEmailTemplate {
    @InvocableMethod(label='Get Email Templates')
    public static List<ResponsesOutput> getEmailTemplate() {
        ResponsesOutput output = new ResponsesOutput();
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();

        List<Bot_Email_Template__mdt> emailTemplateList = [
            SELECT Id,
                   New_Customer__c,
                   Monarch_Orders_by_email__c,
                   Spanish_Monarch_Orders_by_email__c,
                   Spanish_New_Customer__c
            FROM Bot_Email_Template__mdt
            LIMIT 1
        ];

        if (emailTemplateList.size() > 0) {
            output.newCustomerTemplate = emailTemplateList[0].New_Customer__c;
            output.monarchOrderTemplate = emailTemplateList[0].Monarch_Orders_by_email__c;
            output.spanishNewCustomerTemplate = emailTemplateList[0].Spanish_New_Customer__c;
            output.spanishMonarchOrderTemplate = emailTemplateList[0].Spanish_Monarch_Orders_by_email__c;
        }

        outputList.add(output);
        return outputList;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=false)
        public String newCustomerTemplate;

        @InvocableVariable(required=false)
        public String monarchOrderTemplate;

        @InvocableVariable(required=false)
        public String spanishNewCustomerTemplate;

        @InvocableVariable(required=false)
        public String spanishMonarchOrderTemplate;
    }
}