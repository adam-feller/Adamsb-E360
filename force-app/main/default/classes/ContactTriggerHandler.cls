public with sharing class ContactTriggerHandler {

    public static void updateAccountContactRelationForChangedEmail(List<Contact> contactList, Map<Id, Contact> contactOldMap) {
        try{
            Set<Id> contactIds = new Set<Id>();
            for(Contact conObj : contactList){
                if(conObj.Email != null){
                    if(conObj.Email != contactOldMap.get(conObj.Id).Email){
                        contactIds.add(conObj.Id);
                    }
                }
            }

            if(!contactIds.isEmpty()){
                List<AccountContactRelation> accountContactRelationList = AccountContactRelationDAO.getAccountContactRelation(contactIds);
                List<AccountContactRelation> accountContactRelationListToUpdate = new List<AccountContactRelation>();
                for(AccountContactRelation acrObj : accountContactRelationList){
                    if (acrObj.AccountId != null && acrObj.ContactId != null){
                        acrObj.ExternalId__c = acrObj.Account.ExternalId__c + '*' + acrObj.Contact.Email;
                        accountContactRelationListToUpdate.add(acrObj);
                    }
                }

                if(!accountContactRelationListToUpdate.isEmpty()){
                    AccountContactRelationDAO.updateAccountContactRelation(accountContactRelationListToUpdate);
                }
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ContactTriggerHandler', 'updateAccountContactRelationForChangedEmail');
        }
    }

    public static void processAccountRollup(List<Contact> contactList, Map<Id, Contact> contactOldMap) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(Contact c : contactList){
            //field change
            if(contactOldMap.size()>0){
                Contact oldContact = contactOldMap.get(c.Id);
                //delivery notification field changes
                if(c.Receive_Delivery_Notifications__c != oldContact.Receive_Delivery_Notifications__c){
                    contactIds.add(c.Id);
                }
                //web contact field changes
                if(c.WebContact__c != oldContact.WebContact__c){
                    contactIds.add(c.Id);
                }
            }
            //record insert/delete
            else{
                contactIds.add(c.Id);
            }
        }
        //get all related Accounts, including deleted ones
        List<AccountContactRelation> acrList = [
            SELECT Id, AccountId
            FROM AccountContactRelation
            WHERE ContactId IN :contactIds
            ALL ROWS
        ];

        for(AccountContactRelation acr : acrList){
            accountIds.add(acr.AccountId);
        }
        if(accountIds.size()>0){
            calculateRollups(accountIds);
        }
    }

    public static void calculateRollups(Set<Id> accountIds) {
        try {
            List<Account> actToUpdateList = new List<Account>();

            List<AccountContactRelation> acrList = [
                SELECT Id, IsActive, AccountId, Account.Opted_in_for_Delivery_Notifications__c, Account.Web_Contact__c,
                ContactId, Contact.Receive_Delivery_Notifications__c, Contact.WebContact__c
                FROM AccountContactRelation
                WHERE AccountId IN: accountIds
                AND IsActive = true
            ];
            
            Set<Id> processedAcctsTrueDeliveryNotif = new Set<Id>();
            Set<Id> processedAcctsTrueWebContact = new Set<Id>();
            for(AccountContactRelation  acr : acrList){
                //act has at least one contact with true for delivery notification
                if(acr.Contact.Receive_Delivery_Notifications__c == true){
                    processedAcctsTrueDeliveryNotif.add(acr.AccountId);
                }
                //act has at least one contact with true for web notification
                if(acr.Contact.WebContact__c == true){
                    processedAcctsTrueWebContact.add(acr.AccountId);
                }
            }
            for(Id actId : accountIds){
                Account actToUpdate = new Account(Id=actId);
                //delivery notification
                if(processedAcctsTrueDeliveryNotif.contains(actId)){
                    actToUpdate.Opted_in_for_Delivery_Notifications__c = true;
                }
                else{
                    actToUpdate.Opted_in_for_Delivery_Notifications__c = false;
                }
                //web contact
                if(processedAcctsTrueWebContact.contains(actId)){
                    actToUpdate.Web_Contact__c = true;
                }
                else{
                    actToUpdate.Web_Contact__c = false;
                }
                actToUpdateList.add(actToUpdate);
            }
            if(actToUpdateList.size()>0){
                AccountDAO.updateAccounts(actToUpdateList);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ContactTriggerHandler', 'calculateRollups');
        }
    }
}