/**
 * Created by alexander.velitsky on 04/26/21.
 */
public without sharing class InactiveAccountHandler {
	/* * * * *
    *   Description: Probably temporary logic
    *   As of April 26 2021 we use Mule integration to bring all the 
    *   updates to the account, including Account.IsActive__c that 
    *   indicates account was deleted in VIP. In order to prevent data 
    *   duplication match with Beerline data we need to blank certain fields on the account 
    * * * * */
    public static void processInactiveAccounts(List<Account> changedAccounts, Map<Id, Account> oldAccounts) {
        Id UnassignedUserId = RouteAssignmentHandler.getUnassignedUserId();
        for (Account acc: changedAccounts){
            if (acc.IsActive__c == false){
                acc.Account_Manager_Route__c = null;
                acc.Account_Manager_Route_2__c = null;
                acc.Account_Manager_Route_3__c = null;
                acc.Account_Manager_Route_4__c = null;
                acc.Account_Manager_Route_5__c = null;
                acc.Account_Manager_Route_6__c = null;
                acc.Sales_Manager_Route__c = null;
                acc.Sales_Manager_Route_2__c = null;
                acc.Sales_Manager_Route_3__c = null;
                acc.Sales_Manager_Route_4__c = null;
                acc.Sales_Manager_Route_5__c = null;
                acc.Sales_Manager_Route_6__c = null;
                if(UnassignedUserId != null) acc.OwnerId = UnassignedUserId;
                acc.Delivery_Frequency_Type__c = null;
                acc.Requested_Delivery_Days__c  = null;
                acc.License_1__c = null;
                acc.License_2__c = null;
                acc.License3__c  = null;
            }
        }
    }
    
}