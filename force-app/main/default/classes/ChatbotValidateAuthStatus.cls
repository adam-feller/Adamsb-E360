public class ChatbotValidateAuthStatus {
    static final String AUTH_MESSAGE_SUB = '[SIGNIN-STATUS]';
    
    @InvocableMethod(label='Check Authentication Status')
    public static List<ResponsesOutput> validateAuthStatus(List<ResponsesInput> responsesInput) {
        ResponsesOutput output = new ResponsesOutput();
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();
        
        //Get last customer input
        String lastInput = responsesInput[0].lastCustomerInput;
        lastInput = lastInput.replace('\'', '');

        //Check to see if message came from auto authentication event
        if (lastInput.contains(AUTH_MESSAGE_SUB)) {
            //Deserialize message from site
            Object result = JSON.deserializeUntyped(lastInput);

            if (result instanceof Map<String, Object>) {
                Map<String, Object> resultMap = (Map<String, Object>)result;
                Map<String, Object> data = (Map<String, Object>)resultMap.get(AUTH_MESSAGE_SUB);
                output.isAuthenticated = (Boolean)data.get('Success');
                output.isConfused = false;
                
                if (output.isAuthenticated == true) {
                    output.businessUnitId = (String)data.get('BusinessUnitId');
                    output.accountNumber = (String)data.get('AccountNumber');
                    output.firstName = (String)data.get('FirstName');
                    output.lastName = (String)data.get('LastName');
                    output.email = (String)data.get('Email');

                    // Find account
                    String accExtId = (String)data.get('BusinessUnitId') + '*' + (String)data.get('AccountNumber');
                    List<Account> accList = [
                        SELECT Id
                        FROM Account
                        WHERE ExternalId__c = :accExtId
                        LIMIT 1
                    ];
                    if (accList.size() > 0) {
                        output.accountId = accList[0].Id;
                    }
                } else {
                    output.firstName = responsesInput[0].firstName;
                    output.lastName = responsesInput[0].lastName;
                    output.email = responsesInput[0].email;
                    output.businessUnitId = '';
                    output.accountNumber = '';
                    output.accountId = '';
                }
            }
        } else {
            output.isAuthenticated = responsesInput[0].isAuthenticated;
            output.isConfused = true;
            output.firstName = responsesInput[0].firstName;
            output.lastName = responsesInput[0].lastName;
            output.email = responsesInput[0].email;
            output.businessUnitId = responsesInput[0].businessUnitId;
            output.accountNumber = responsesInput[0].accountNumber;
            output.accountId = responsesInput[0].accountId;
        }

        outputList.add(output);

        return outputList;
    }
    
    
    public class ResponsesInput {
        @InvocableVariable(required=true)
        public String lastCustomerInput;
        @InvocableVariable(required=false)
        public Boolean isAuthenticated;
        @InvocableVariable(required=false)
        public String firstName;
        @InvocableVariable(required=false)
        public String lastName;
        @InvocableVariable(required=false)
        public String businessUnitId;
        @InvocableVariable(required=false)
        public String accountNumber;
        @InvocableVariable(required=false)
        public String email;
        @InvocableVariable(required=false)
        public String accountId;
        @InvocableVariable(required=false)
        public Boolean isConfused;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=false)
        public Boolean isAuthenticated;
        @InvocableVariable(required=false)
        public String firstName;
        @InvocableVariable(required=false)
        public String lastName;
        @InvocableVariable(required=false)
        public String businessUnitId;
        @InvocableVariable(required=false)
        public String accountNumber;
        @InvocableVariable(required=false)
        public String email;
        @InvocableVariable(required=false)
        public String accountId;
        @InvocableVariable(required=false)
        public Boolean isConfused;
    }
}