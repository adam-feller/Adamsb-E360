public without sharing class AccountDAO {

    public static List<Account> getAccountsByIds(Set<Id> accountId){
        return [SELECT Id, Name, Beer_Company__c, Warehouse__c, VIP_Account_Number__c, VIP_Instance__c, Visit_Completed__c, Chain_Independent__c, Call_Days__c,
                ExternalId__c, VIP_Composite_Key__c, OwnerId, Territories__c, Chain__c, Owner.Email, Warehouse_Lookup__c, Warehouse_Lookup__r.Name, Primary_ISR__c,
                Warehouse_Lookup__r.ISR_1__c, Batch_Call_Date_Created__c, Batch_Call_Date_Ended__c, Requested_Delivery_Days__c, Delivery_Frequency_Type__c, Require_PO__c,
                Warehouse_Lookup__r.LayerPalletThreshold__c, Sales_Manager_Route__c, Terms__c, IsActive__c, LicenseExpirationDate__c, Primary_POC__c, Primary_POC__r.Name,
                Status__c, Premise__c, Sell_Type__c, Presell_Cancelled_Dates__c, Presell_Inserted_Dates__c, Parent.Name, SalesOrg__c, Volume__c, Displayable_Status__c,
                Draft_Status__c, Account_Class__c, Package_Type__c, Status_Clean__c, Account_Manager_Route__c, Store_Type__c, Controllable__c, License_Type_cd__c,
                Customer_GP_Goal__c
                FROM Account 
                WHERE Id IN :accountId];
    }

    public static List<Account> getAccountByParentAccountIds(List<String> accountIds){
        return [SELECT Id 
                FROM Account
                WHERE ParentId IN :accountIds];
    }

    public static Map<String, Account> getRetailStoreByStoreNumber(Set<String> storeNumber) {
        List <Account> retailStoreList = [
            //BSSP-1829: Added tne new column indicator for Early cutoff
            SELECT Id, Name, VIP_Composite_Key__c, BillingAddress, ExternalId__c, Early_Cutoff__c, Do_Not_Call__c, Sell_Type__c
            FROM Account
            WHERE ExternalId__c IN : storeNumber
        ];

        Map<String, Account> result = new Map<String, Account>();
        for(Account retailstore : retailStoreList){
            result.put(retailstore.ExternalId__c, retailstore);
        }

        return result;
    }

    public static String getStoreNumberById(Id accountId) {
        String storeNbr = [SELECT VIP_Composite_Key__c, Chain__c FROM Account WHERE Id = :accountId LIMIT 1].VIP_Composite_Key__c;
        return storeNbr;
    }

    public static List<Account> getAccountsByExternalIds(Set<String> externalIds){
        return [SELECT Id, ExternalId__c, Territories__c
                FROM Account 
                WHERE ExternalId__c IN :externalIds];
    }

    public static List<Account> updateAccounts(List<Account> accountsToUpdate) {
        update accountsToUpdate;
        return accountsToUpdate;
    }
}