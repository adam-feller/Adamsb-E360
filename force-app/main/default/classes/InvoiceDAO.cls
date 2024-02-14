public without sharing class InvoiceDAO {
    public static List<Invoice__c> getInvoiceByAccountMostRecentOrders(Id accountId, Integer numOfOrders){
        return [SELECT Id 
                FROM Invoice__c 
                WHERE AccountId__c = :accountId 
                ORDER BY Invoice_Date__c DESC
                LIMIT :numOfOrders];
    }

    public static List<Invoice__c> getInvoiceByAccountMostRecentDateRange(String accountId, Integer numOfOrders, Date startDateRange){
        return [SELECT Id 
                FROM Invoice__c 
                WHERE AccountId__c = :accountId 
                AND Invoice_Date__c >= :startDateRange
                ORDER BY Invoice_Date__c DESC
                LIMIT :numOfOrders];
    }
}