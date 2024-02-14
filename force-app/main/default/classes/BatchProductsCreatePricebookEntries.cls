/**
Developer: Murthy
Date: 12/07/2021
 Purpose: Set Pricebook Entries for all the new Products created in that day.
 */

public with sharing class BatchProductsCreatePricebookEntries implements Database.Batchable<sObject>  {


    public Date today = System.today();
    public String query;

    public Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT id from Product2 where createddate = TODAY';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Product2> prodList){

        try{
            
        // process each batches of Products
        for(Product2 prod : prodList) {        
            // call the method set Pricebook Entry
            Set<Id> productIds = new Set<Id>();
            productIds.add(prod.Id);
            StandardPricebookHandler.checkOrFillStandardPricebookoEntry(productIds);
            }

            } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchProductsCreatePricebookEntries', 'execute()');
        } 

    }

    public void finish(Database.BatchableContext BC){
    }


}