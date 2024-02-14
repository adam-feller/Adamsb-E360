/**
 * Created by nicholas.vree on 12/10.
 */

global class BatchExpiringLicenseAlert implements Database.Batchable<sObject> {

    public Date todayPlus35;
    public String query;
    

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator( query );
 
    }
   
    global void execute( Database.BatchableContext BC, List<Account> accountList ) { 
        try{
            List<Alert__c> alertsToInsert = new List<Alert__c>();
            
            for(Account acc : accountList){
                Alert__c newAlert = new Alert__c();
                newAlert.Account__c = acc.Id;
                newAlert.Alert_Message__c = 'This customer’s license is expiring on ' + acc.LicenseExpirationDate__c.format() + ' and requires an update! Take action now to ensure they can continue placing orders.';
                newAlert.Start_Date__c = System.today();
                newAlert.Requires_Action__c = true;


                newAlert.Account_Alert__c = true;
                newAlert.Order_Alert__c = true;



                alertsToInsert.add(newAlert);
            }

            insert alertsToInsert;

        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchExpiringLicenseAlert', 'execute()');
        }
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
 
}