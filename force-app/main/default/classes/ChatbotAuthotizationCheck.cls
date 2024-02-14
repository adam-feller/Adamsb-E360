public class ChatbotAuthotizationCheck {
    @InvocableMethod(label='Get Authorized Accounts')
    public static List<ResponseOutput> checkAuthorizationRecords(List<ResponseInput> riList) {
        ResponseInput ri = new ResponseInput();
        ResponseOutput ro = new ResponseOutput();
        List<ResponseOutput> roList = new List<ResponseOutput>();
        Boolean isAuthSingle = false;
        Boolean isAuthMultiple = false;
        Boolean isRep = false;

        if(riList == null || riList.size() <= 0) { return null; }

        ri = riList[0];

        string messagingUserId = ri.messagingUserId;
        MessagingEndUser mu = [SELECT ContactId, AccountId, Account.Name, Rep__c, Is_Rep__c FROM MessagingEndUser WHERE Id=:messagingUserId LIMIT 1];
        
        if(mu != null && !String.isBlank(mu.ContactId)) {
            List<TTO_Authorization__c> ttoAuthList = [SELECT Account__c FROM TTO_Authorization__c WHERE Contact__c =:mu.ContactId];
            if(ttoAuthList != null && ttoAuthList.size() > 0) {
                isAuthSingle = ttoAuthList.size() == 1;
                isAuthMultiple = ttoAuthList.size() > 1;
            }

            if(isAuthMultiple) {
                Set<string> accountIds = new Set<string>();
                for (TTO_Authorization__c ttoAuth : ttoAuthList) {
                    accountIds.add(ttoAuth.Account__c);
                }
                
                List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
                List<AccountOption> aoList = new List<AccountOption>();
                for (Account account : accounts) {
                    AccountOption ao = new AccountOption();
                    ao.Name = account?.Name;
                    ao.Id = account?.Id;
                    aoList.add(ao);
                }
                
                AccountOption aoNotFound = new AccountOption();
                aoNotFound.Name = 'I don\'t see it.';
                aoList.add(aoNotFound);

                ro.authAccounts = aoList;
            } else if(isAuthSingle) {
                List<Account> accountList = [SELECT Id, Name FROM Account WHERE Id = :ttoAuthList[0].Account__c];
                if(accountList.size() > 0) {
                    AccountOption ao = new AccountOption();
                    ao.Name = accountList[0].Name;
                    ao.Id = accountList[0].Id;
                    ro.authAccount = ao;
                }
            }
        } else if (mu != null && mu.Is_Rep__c == true) {
            isRep = true;
        }

        ro.IsAuthSingle = isAuthSingle;
        ro.IsAuthMultiple = isAuthMultiple;
        ro.IsRep = isRep;

        roList.add(ro);
        return roList;
    }

    public class ResponseInput {
        @InvocableVariable
        public string messagingUserId;
    }

    public class ResponseOutput {
        @InvocableVariable
        public Boolean IsAuthSingle;
        @InvocableVariable
        public Boolean IsAuthMultiple;
        @InvocableVariable
        public List<AccountOption> authAccounts;
        @InvocableVariable
        public AccountOption authAccount;
        @InvocableVariable
        public Boolean IsRep;
    }

    public class AccountOption {
        public string Name { get; set; }
        public string Id { get; set; }
    }
}