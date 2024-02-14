/**
 * Created by nicholas.vree on 11/30.
 */

public with sharing class WarehouseSyncHandler {
    /* * * * *
    *   Description: This method keeps in sync the two warehouse fields on Account (Warehouse__c is a String  populated via the integrations, Warehouse_Lookup__c is 
    *   looks up to the Warehouse__c object), making available key warehouse information from the Account (such as ISR).
    *   The integration text value is the source-of-truth, controlling field for the lookup.
    * * * * */
    
    public static void syncTextWarehouseWithLookupWarehouseOnAccount(List<Account> newAccountList, Map<Id, Account> oldAccountMap){
        //Obtaining Account Ids needed for Warehouse Name lookups
        Set<Id> AccountIds = new Set<Id>();

        List<Error_Log__c> errorsToInsert = new List<Error_Log__c>();


        for(Account acct: newAccountList){
            AccountIds.add(acct.Id);
        }
        
        //Building necessary maps
        Map<Id, Account> accountMap = new Map<ID, Account> (AccountDAO.getAccountsByIds(AccountIds));
        List<Warehouse__c> allWarehouses = WarehouseDAO.getAllWarehouses();
        Map<String, Warehouse__c> warehouseMap = new Map<String, Warehouse__c>();

        for(Warehouse__c wrhs : allWarehouses){
            warehouseMap.put(wrhs.Name.toLowerCase(), wrhs);
        }
        


        Id retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();
        
        for(Account acct : newAccountList){
            try{
                if(acct.RecordTypeId == retailRecordTypeId){


               if(!String.isEmpty(acct.Warehouse__c)) {
                    acct.Warehouse_Lookup__c = warehouseMap.get(acct.Warehouse__c.toLowerCase()).Id;
                }else if(String.isEmpty(acct.Warehouse__c)) {
                    acct.Warehouse_Lookup__c = null;
                }


                }
            } catch (Exception ex) {
                /*There is the possibility that a new or mismatched warehouse provided by the integration does not exist in the Warehouse object,
                in which case we want an error logged; */
                String errorMessage = 'Account Id :' + acct.Id + ' ; ' + ex.getMessage(); 

                errorMessage = errorMessage.left(255);

                errorsToInsert.add(ErrorLog.returnErrorLog(errorMessage, String.valueOf(ex.getLineNumber()), 'WarehouseSyncHandler', 'syncTextWarehouseWithLookupWarehouseOnAccount'));
            }
        }

        if(errorsToInsert.size() > 0){
            insert errorsToInsert;
        }



    }
}