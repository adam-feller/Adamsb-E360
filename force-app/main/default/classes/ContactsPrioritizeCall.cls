public without sharing class ContactsPrioritizeCall {

    @InvocableMethod(label='Contacts Prioritize Call')
    public static void callPrioritizeContacts(List<FlowInput> input){        
        if(input[0].recordIdAccountContactRel != null) {
            //Get all Account Contact Relationships Records for the same Account
            AccountContactRelation accConRel = [SELECT Id, ContactId, AccountId, Priority__c FROM AccountContactRelation WHERE Id = :input[0].recordIdAccountContactRel];
            if (accConRel.Priority__c != null) {
				//Now get all the Account Contact Relationship records associated to this same Account
				List<AccountContactRelation> accConRelList = [SELECT Id, ContactId, AccountId, Priority__c FROM AccountContactRelation 
	                                                          WHERE AccountId = :accConRel.AccountId AND Id != :accConRel.Id ORDER BY Priority__c ASC, LastModifiedDate DESC];
	            Integer cnt = 1;
                for (AccountContactRelation acr : accConRelList) {	                
	                if (cnt == Integer.valueOf(accConRel.Priority__c)) {
	 	               cnt += 1;
	                }
	                acr.Priority__c = String.valueOf(cnt);
                    cnt += 1;
	            }
	            update accConRelList;
	        }
        }
    }

    public class FlowInput{
        @InvocableVariable(required=true)
        public Id recordIdAccountContactRel;
    }

}