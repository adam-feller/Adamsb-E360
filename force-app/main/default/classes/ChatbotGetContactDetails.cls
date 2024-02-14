public class ChatbotGetContactDetails {
    @InvocableMethod(label='Get Contact Details')
    public static List<ResponsesOutput> getContactDetails(List<ResponsesInput> inputList) {
        ResponsesOutput output = new ResponsesOutput();
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();

        List<Contact> lstCons = [
            SELECT Id, Email
            FROM Contact
            WHERE Id = :inputList[0].contactId
        ];
        if (lstCons.size() > 0) {
            output.email = lstCons[0].email;
        }

        outputList.add(output);
        return outputList;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=false)
        public String email;
    }

    public class ResponsesInput {
        @InvocableVariable(required=true)
        public String contactId;
    }
}