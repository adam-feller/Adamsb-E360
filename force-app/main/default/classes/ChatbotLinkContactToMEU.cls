public class ChatbotLinkContactToMEU {
    @InvocableMethod(label='Link Contact/User to MEU')
    public static List<ResponseOutput> linkContacttoMEU(List<ResponseInput> riList) {
        List<ResponseOutput> roList = new List<ResponseOutput>();
        ResponseOutput ro = new ResponseOutput();

        //Nothing passed in, exit
        if(riList == null || riList.size() <= 0) { return null; }

        ResponseInput ri = riList[0];
		
        if(String.isBlank(ri.messagingEndUserName)) {
        	ro.isSuccess = false;
        } else {
            String phoneInput = String.isBlank(ri.messagingEndUserName) ? '' : ri.messagingEndUserName;
            //Remove country code - we only are factoring in US and Canada right now
            String onlyPhone = (!String.isBlank(phoneInput) && phoneInput.length() > 2) ? phoneInput.substring(2) : '';
    
            //Get matching contact(s)
            List<Contact> potentialMatchingContacts = [
                SELECT Id
                FROM Contact 
                WHERE Phone = :onlyPhone
                ORDER BY LastModifiedDate DESC
            ];
    
            //Format phone as the User uses a different format than Contact
            String parenDashFormattedPhone = (onlyPhone.length() == 10) ? '(' + onlyPhone.substring(0, 3) + ') ' + onlyPhone.substring(3, 6) + '-' + onlyPhone.substring(6) : onlyPhone;
            String dashOnlyFormattedPhone = (onlyPhone.length() == 10) ? onlyPhone.substring(0, 3) + '-' + onlyPhone.substring(3, 6) + '-' + onlyPhone.substring(6) : onlyPhone;
            //Get matching user(s)
            List<User> potentialMatchingUsers = [
                SELECT Id
                FROM User 
                WHERE Phone = :onlyPhone OR Phone = :parenDashFormattedPhone OR Phone = :dashOnlyFormattedPhone
                ORDER BY LastModifiedDate DESC
            ];
    
            //Update the MEU with the Contact, if found
            if(potentialMatchingContacts.size() > 0) {
                Contact matchingContact = potentialMatchingContacts[0];
                
                MessagingEndUser meu = new MessagingEndUser();
                meu.Id = ri.messagingEndUserId;
                meu.ContactId = matchingContact.Id;
                update meu;
    
                ro.isSuccess = true;
            } else if(potentialMatchingUsers.size() > 0) {
                User matchingUser = potentialMatchingUsers[0];
                
                MessagingEndUser meu = new MessagingEndUser();
                meu.Id = ri.messagingEndUserId;
                meu.Is_Rep__c = true;
                meu.Rep__c = matchingUser.Id;
                update meu;
    
                ro.isSuccess = true;
            } else {
                ro.isSuccess = false;
            }
        }

        roList.add(ro);
        return roList;
    }

    public class ResponseInput {
        @InvocableVariable(required=true)
        public string messagingEndUserName;
        @InvocableVariable(required=true)
        public string messagingEndUserId;
    }

    public class ResponseOutput {
        @InvocableVariable
        public Boolean isSuccess;
    }
}