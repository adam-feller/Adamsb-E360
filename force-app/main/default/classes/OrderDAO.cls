public without sharing class OrderDAO {

    public static List<Order> getOrderDetailsbyId(Id orderId) {
        return [SELECT Id, OrderNumber, Order_Errors__c, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, Account.Name, Off_Day__c, Off_Frequency__c,  Account.Primary_Language_Preference__c,
                Contact__c, Contact__r.Name, Order_Placed_By__c, CreatedBy.Name, Case_Count__c, Case_Equivalent__c, Delivery_Charge__c, Gross_Sales__c, Keg_Count__c, Sales_Tax__c, Service_Charge__c, 
                Subtotal__c, Total_Credits__c, Total_CRV__c, Total_Deposit__c, Total_Discount__c, Total_Net_Price__c, Sales_Route_Number__c, VIPActionCode__c, VIP_Order_Number__c, Order_Details__c, Order_Origin__c, 	
                Third_Party_Order_Type__c, FSR_Consultant_Order__c, Unscheduled_Reason_Code__c, Missed_Delivery_Reason_Code__c
                FROM Order 
                WHERE Id = :orderId];
    }

    public static List<Order> getOrderDetailsbyId(Set<String> orderIds) {
        return [SELECT Id, OrderNumber, Order_Errors__c, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, Account.Name, Account.Primary_Language_Preference__c, OwnerId, Owner.Name,
                OrderSourceCode__c
                FROM Order 
                WHERE Id IN :orderIds];
    }

    public static List<Order> getOrderDetailsbyIds(Set<Id> orderIds) {
        return [SELECT Id, OrderNumber, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, Account.Primary_Language_Preference__c, OwnerId, Owner.Name, OrderSourceCode__c,
                Account.VIP_Account_Number__c, Account.Sales_Manager_Route__c, Sales_Route_Number__c, Account.VIP_Instance__c, Order_Placed_By__c, VIPActionCode__c, VIP_Order_Number__c
                FROM Order 
                WHERE Id IN :orderIds];
    }

    public static List<Order> getInvoiceOrderDetailsbyAccountDateRange(Set<Id> accountIds, Integer numOfOrders, Date startDateRange, Id invoiceOrderRecordTypeId) {
        return [SELECT Id, Invoice_Number__c, Total_Net_Price__c, Invoice_Date__c, Invoice_URL__c
                FROM Order
                WHERE AccountId IN :accountIds
                AND Invoice_Date__c >= :startDateRange
                AND RecordTypeId = :invoiceOrderRecordTypeId
                ORDER BY Invoice_Date__c DESC
                LIMIT :numOfOrders];
    }

    public static List<Order> getInvoiceOrderDetailsbyAccount(Set<Id> accountIds, Integer numOfOrders, Id invoiceOrderRecordTypeId) {
        return [SELECT Id
                FROM Order
                WHERE AccountId IN :accountIds
                AND RecordTypeId = :invoiceOrderRecordTypeId
                ORDER BY Invoice_Date__c DESC
                LIMIT :numOfOrders];
    }
    
    public static List<Order> getPriorOrdersUnscheduledReasonCodesbyId(Id accountId) {
        Date compareDate = Date.today().addDays(-90);
        return [SELECT Id, Status, Delivery_Date__c, Unscheduled_Reason_Code__c, Missed_Delivery_Reason_Code__c
                FROM Order 
                WHERE AccountId = :accountId
                AND Delivery_Date__c > :compareDate
                AND Status = 'Posted to VIP'
                AND (Off_Day__c = true OR Off_Frequency__c = true)
                ORDER BY Delivery_Date__c DESC];
    }

    public static List<Order> insertOrders(List<Order> ordersToInsert) {
        insert ordersToInsert;
        return ordersToInsert;
    }

    public static List<Order> updateOrders(List<Order> ordersToUpdate) {
        update ordersToUpdate;
        return ordersToUpdate;
    }

    public static List<Order> deleteOrders(List<Order> ordersToDelete) {
        delete ordersToDelete;
        return ordersToDelete;
    }
}