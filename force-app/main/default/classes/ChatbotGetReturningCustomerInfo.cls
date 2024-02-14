public with sharing class ChatbotGetReturningCustomerInfo {
    @InvocableMethod(label='Get Returning Customer Info')
    public static List<ResponseOutput> getReturningCustomerInfo(List<ResponseInput> riList) {
        ResponseInput ri = new ResponseInput();
        ResponseOutput ro = new ResponseOutput();
        List<ResponseOutput> roList = new List<ResponseOutput>();
        
        if(riList == null || riList.size() <= 0) { return null; }

        ri = riList[0];

        string messagingUserId = ri.messagingUserId;

        List<MessagingSession> msList = [
            SELECT Id, Selected_Account__c, Selected_Account__r.Name
            FROM MessagingSession 
            WHERE MessagingEndUserId=:messagingUserId AND CreatedDate >= LAST_N_DAYS:1
        ];

        if(msList != null && msList.size() > 0) {
            ro.isReturning = true;
            String accountName = '';
            String accountId = ''; 
            for(MessagingSession ms : msList) {
                if(!String.isBlank(ms.Selected_Account__r.Name)) {
                    accountName = ms.Selected_Account__r.Name;
                    accountId = ms.Selected_Account__c;
                    break;
                }
            }
            if(String.isBlank(accountId)) {
                ro.isReturning = false;
            } else {
                ChatbotAuthotizationCheck.AccountOption ao = new ChatbotAuthotizationCheck.AccountOption();
                ao.Name = accountName;
                ao.Id = accountId;
                ro.lastSelectedAccountOption = ao;
            }
        } else {
            ro.isReturning = false;
        }

        roList.add(ro);
        return roList;
    }
    
    public class ResponseInput {
        @InvocableVariable
        public string messagingUserId;
    }

    public class ResponseOutput {
        @InvocableVariable
        public Boolean isReturning;
        @InvocableVariable
        public ChatbotAuthotizationCheck.AccountOption lastSelectedAccountOption;
    }
}