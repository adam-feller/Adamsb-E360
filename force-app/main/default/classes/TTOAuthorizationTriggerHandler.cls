public without sharing class TTOAuthorizationTriggerHandler {
    public static void createAccountContactRelation(List<TTO_Authorization__c> newTTOAuthList) {
        Set<Id> contactIdsForQuery = new Set<Id>();
        Map<Id, List<Id>> contactAccountsMap = new Map<Id, List<Id>>();
        //Put all contacts and their corresponding accounts into a map. This map is the AccountContactRelations that need to not exist.
        for (TTO_Authorization__c ttoAuth : newTTOAuthList) {
            if(ttoAuth.Contact__c != null && ttoAuth.Account__c != null) {
                contactIdsForQuery.add(ttoAuth.Contact__c);
                if(contactAccountsMap.containsKey(ttoAuth.Contact__c)) {
                    List<Id> accList = contactAccountsMap.get(ttoAuth.Contact__c);
                    accList.add(ttoAuth.Account__c);
                    contactAccountsMap.put(ttoAuth.Contact__c, accList);
                } else {
                    contactAccountsMap.put(ttoAuth.Contact__c, new List<Id> { ttoAuth.Account__c });
                }                
            }
        }

        //Get all AccountContactRelations for the Contact in the TTOAuth records.
        List<AccountContactRelation> acrList = [
            SELECT Id, AccountId, ContactId 
            FROM AccountContactRelation 
            WHERE ContactId IN :contactIdsForQuery
        ];
        
        //Create a composite key mapping for all returned Contact plus Accounts
        Map<String, Boolean> conAccAlreadyExistsMap = new Map<String, Boolean>();
        for(AccountContactRelation acr: acrList) {
            String compKey = acr.ContactId + '-' + acr.AccountId;
            conAccAlreadyExistsMap.put(compKey, true);
        }

        List<AccountContactRelation> acrListToInsert = new List<AccountContactRelation>();
        //Build List of ACRs to insert. If the Contact-Account combo in the TTO Auth doesn't already exist, create one.
        for(Id contactId : contactAccountsMap.keySet()) {
            for(Id accId : contactAccountsMap.get(contactId)) {
                //No mapping exists, create a record
                if(acrList.size() == 0) { 
                    AccountContactRelation acrToInsert = new AccountContactRelation();
                    acrToInsert.ContactId = contactId;
                    acrToInsert.AccountId = accId;
                    acrListToInsert.add(acrToInsert);
                } else {
                    String compKey = contactId + '-' + accId;
                    Boolean doesExist = false;
                    if(conAccAlreadyExistsMap.containsKey(compKey)) {
                        doesExist = conAccAlreadyExistsMap.get(compKey);
                    }                        
                        
                    if(doesExist) {
                        //Do nothing, record already exists
                    } else { //No mapping exists, create a record
                        String aId = '';
                        String cId = '';
                        if(compKey.length() > 1) {
                            cId = compKey.split('-')[0];
                            aId = compKey.split('-')[1];
                        } else {
                            cId = contactId;
                            aId = accId;
                        }
                        AccountContactRelation acrToInsert = new AccountContactRelation();
                        acrToInsert.ContactId = cId;
                        acrToInsert.AccountId = aId;
                        acrListToInsert.add(acrToInsert);
                    }
                }
            }
        }

        insert acrListToInsert;
    }
}