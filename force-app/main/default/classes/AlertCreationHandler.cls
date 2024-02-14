public inherited sharing class AlertCreationHandler {

    public static void createOrCloseTermRelatedAlerts(List<Account> accountList, Map<Id, Account> oldAccountMap){

        try{
            String PREVENT_ORDER_MESSAGE = 'This customer has a term hold and is not able to place an order. Please resolve ASAP before you place their next order.';
            String AR_MESSAGE = 'This customer has an unresolved AR issue: ';

            List<Alert__c> alertsToInsert = new List<Alert__c>();
            List<Alert__c> alertsToClose = new List<Alert__c>();
            
            Set<Id> accountIds = new Set<Id>();
            for(Account accObj : accountList){
                accountIds.add(accObj.Id);
            }

            //Get the Account Term Types
            List<Account_Term_Type__mdt> accountTermTypes = [SELECT BU__c, Term_Type__c, Prevent_Order__c, Customer_Warning__c, AR_Max_Age__c, AR_Warning_Message__c
                                                            FROM Account_Term_Type__mdt 
                                                            WHERE VIP_Code__c = null];

            Map<String, Account_Term_Type__mdt> buTermToAccountTermTypes = new Map<String, Account_Term_Type__mdt>();

            //Get the existing AR Alerts
            List<Alert__c> preventOrderAlerts = [SELECT Id, Account__c, Start_Date__c, End_Date__c 
                                                FROM Alert__c 
                                                WHERE Active__c = true AND Terms_Related_Alert__c = true
                                                AND Account__c IN :accountIds];

            Map<String, Set<Alert__c>> accountToTermRelatedAlerts= new Map<String, Set<Alert__c>>();

            //Put Existing AR Alerts into Map By Account
            for(Alert__c alert : preventOrderAlerts){
                if(accountToTermRelatedAlerts.containsKey(alert.Account__c)){
                    accountToTermRelatedAlerts.get(alert.Account__c).add(alert);
                }else{
                    Set<Alert__c> newAlertsList = new Set<Alert__c>();
                    newAlertsList.add(alert);
                    accountToTermRelatedAlerts.put(alert.Account__c, newAlertsList);
                }
            }

            //Put the Preventing Term in a map by BU
            for(Account_Term_Type__mdt att : accountTermTypes){
                buTermToAccountTermTypes.put(att.BU__c+'*'+att.Term_Type__c, att);
            }
            

            for(Account acc : accountList){
                String oldTermType = oldAccountMap.get(acc.Id).Terms__c;
                Integer oldOldestItemAge = oldAccountMap.get(acc.Id).AgeOldestOpenItem__c != null ? (Integer)oldAccountMap.get(acc.Id).AgeOldestOpenItem__c : 0;
                
                String currentTermType = acc.Terms__c;
                Integer currentOldestItemAge = acc.AgeOldestOpenItem__c != null ? (Integer)acc.AgeOldestOpenItem__c : 0;

                String oldBUTermKey = acc.VIP_Instance__c+'*'+oldTermType;
                String currentBUTermKey = acc.VIP_Instance__c+'*'+currentTermType;

                Boolean previousPreventOrder = buTermToAccountTermTypes.get(oldBUTermKey)!= null ? buTermToAccountTermTypes.get(oldBUTermKey).prevent_Order__c : false;
                Boolean currentPreventOrder = buTermToAccountTermTypes.get(currentBUTermKey) != null ? buTermToAccountTermTypes.get(currentBUTermKey).prevent_Order__c : false;

                Boolean previousCustomerWarning = buTermToAccountTermTypes.get(oldBUTermKey) != null ? buTermToAccountTermTypes.get(oldBUTermKey).Customer_Warning__c : false;
                Boolean currentCustomerWarning = buTermToAccountTermTypes.get(currentBUTermKey) != null ? buTermToAccountTermTypes.get(currentBUTermKey).Customer_Warning__c : false;

                Integer previousARMax = buTermToAccountTermTypes.get(oldBUTermKey) != null ? (Integer)buTermToAccountTermTypes.get(oldBUTermKey).AR_Max_Age__c : 99999;
                Integer currentARMax = buTermToAccountTermTypes.get(currentBUTermKey) != null ? (Integer)buTermToAccountTermTypes.get(currentBUTermKey).AR_Max_Age__c : 99999;

                String currentARWarningMessage = buTermToAccountTermTypes.get(currentBUTermKey) != null ? buTermToAccountTermTypes.get(currentBUTermKey).AR_Warning_Message__c : null;

                if(previousPreventOrder == false && currentPreventOrder==true){ //Did the account previously NOT have a Prevent Order, but now does


                    Alert__c newAlert = createNewAlert(PREVENT_ORDER_MESSAGE, acc.Id, true, true, System.today(), null, true, true);


                    alertsToInsert.add(newAlert);
                    if(accountToTermRelatedAlerts.get(acc.Id) != null){
                        alertsToClose.addAll(accountToTermRelatedAlerts.get(acc.Id));
                    }
                }else if((oldOldestItemAge<previousARMax && currentOldestItemAge >= currentARMax && currentPreventOrder==false)) { //Did the account previously NOT have a Customer Warning, but now does


                    Alert__c newAlert = createNewAlert(AR_MESSAGE + currentARWarningMessage, acc.Id, true, true, System.today(), null, false, true);


                    alertsToInsert.add(newAlert);
                    if(accountToTermRelatedAlerts.get(acc.Id) != null){
                        alertsToClose.addAll(accountToTermRelatedAlerts.get(acc.Id));
                    }            
                } else if((previousCustomerWarning == false && currentCustomerWarning==true && currentPreventOrder==false && (currentOldestItemAge < currentARMax || currentOldestItemAge == 0))){ //Did the account NOT exceed the AR Max, but now does


                    Alert__c newAlert = createNewAlert(AR_MESSAGE + currentARWarningMessage, acc.Id, true, true, System.today(), null, false, true);


                    alertsToInsert.add(newAlert);
                    if(accountToTermRelatedAlerts.get(acc.Id) != null){
                        alertsToClose.addAll(accountToTermRelatedAlerts.get(acc.Id));
                    }
                } else if ( currentPreventOrder==false
                           && currentCustomerWarning==false
                           && (currentOldestItemAge < currentARMax || currentOldestItemAge == 0)
                           && accountToTermRelatedAlerts.get(acc.Id) != null){ //If the status is currently good and there are active term-related alerts
                               alertsToClose.addAll(accountToTermRelatedAlerts.get(acc.Id));
                } else if (
                			(currentCustomerWarning == true && currentOldestItemAge == 0 && accountToTermRelatedAlerts.get(acc.Id) != null)
                    		// add any other conditions here to close out the Alerts
                			) {//BSSP-2154-Close out Alerts that are open
                               
                               alertsToClose.addAll(accountToTermRelatedAlerts.get(acc.Id));
                           }
                
            }
        

            for(Alert__c alert : alertsToClose){
                alert.End_Date__c = System.today()-1;
            }

            List<Alert__c> alertsToUpsert = new List<Alert__c>();
            alertsToUpsert.addAll(alertsToInsert);
            alertsToUpsert.addAll(alertsToClose);

            upsert alertsToUpsert;

        } catch (Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'AlertCreationHandler', 'createOrCloseTermRelatedAlerts');
        }

    }



    public static Alert__c createNewAlert(String message, String accountId, Boolean isAccount, Boolean isOrder, Date startDate, Date endDate, Boolean requiresAction, Boolean termsRelatedAlert){


        Alert__c newAlert = new Alert__c();
        newAlert.Alert_Message__c = message;
        newAlert.Account__c = accountId;
        newAlert.Requires_Action__c = requiresAction;


        newAlert.Account_Alert__c = isAccount;
        newAlert.Order_Alert__c = isOrder;


        newAlert.Start_Date__c = startDate;
        newAlert.End_Date__c = endDate;
        newAlert.Terms_Related_Alert__c = termsRelatedAlert;

        return newAlert;
    }
}