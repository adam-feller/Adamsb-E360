/**
 * Created by nicholas.vree on 12/8.
 */

public class AlertCreatorController {

    @AuraEnabled
    public static List<Object> getRelatedAccountId(String orderId){
        return OrderDAO.getOrderDetailsbyId(orderId);
    }

    /* * * * *
    *   Description: This method retrieves the active alerts.  You pass in the recordId for the specific account
    *   & the objectApiName corresponding to the alert type.
    * * * * */

    @AuraEnabled
    public static List<Alert__c> findActiveAlerts (String recordId, String objectApiName){

        return AlertDAO.getAlerts(recordId, objectApiName, true);
    }
}