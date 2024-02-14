public without sharing class ChatbotStoreInfoOnMEU {
    @InvocableMethod(label='Set Selected Account')
    public static List<ResponseOutput> setAccountInfo(List<ResponseInput> riList) {
        ResponseInput ri = new ResponseInput();
        ResponseOutput ro = new ResponseOutput();
        List<ResponseOutput> roList = new List<ResponseOutput>();
        Boolean success = false;

        if(riList == null || riList.size() <= 0) { return null;}

        ri = riList[0];
        
        if(ri.selectedAccount != null && !string.isEmpty(ri.selectedAccount.Id)) {
            MessagingSession ms = new MessagingSession();
            ms.Id = ri.routableId;
            ms.Selected_Account__c = ri.selectedAccount.Id;
            update ms;

            success = true;
        }

        ro.didSucceed = success;
        roList.add(ro);

        return roList;
    }

    public class ResponseInput {
        @InvocableVariable
        public string routableId;
        @InvocableVariable
        public ChatbotAuthotizationCheck.AccountOption selectedAccount;
    }

    public class ResponseOutput {
        @InvocableVariable
        public Boolean didSucceed;
    }
}