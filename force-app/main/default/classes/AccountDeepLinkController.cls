/**
 * @description       : This controller works with the MaxerienceDeepLink and DesignStudioDeepLink Aura Components 
 *                      launched from Account Action Buttons
 * @author            : cbraaten@reyesholdings.com
 * @last modified on  : 10-21-2022
 * @last modified by  : cbraaten@reyesholdings.com
**/
public with sharing class AccountDeepLinkController {

    @AuraEnabled
    public static String getMaxerienceDeepLink(Id accountId) {
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accountId});
        //Replace parameters in the URL
        if (!accountList.isEmpty()) {
            return System.Label.Link_Maxerience.replace('[username]',UserInfo.getUserName()).replace('[locationcode]',accountList[0].ExternalId__c).replace('[statickey]',System.Label.Maxerience_Static_Key);
        }
        return null;
    }

    @AuraEnabled
    public static String getDesignStudioDeepLink(Id accountId) {
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accountId});
        //Replace parameters in the URL
        if (!accountList.isEmpty()) {
            if (accountList[0].VIP_Instance__c != null && accountList[0].Account_Manager_Route__c != null && accountList[0].VIP_Account_Number__c != null) {
                return System.Label.Link_Design_Studio.replace('[salesrep]',accountList[0].VIP_Instance__c).replace('[route]',accountList[0].Account_Manager_Route__c).replace('[endcustomer]',accountList[0].VIP_Account_Number__c); 
            } else {
                return null;
            }
        }
        return null;
    }

}