public without sharing class OrderItemDAO {

    public static List<OrderItem> getOrderItemByOrderId(Id orderId) {
        return [SELECT Id, OrderId, Product2Id, Product2.Name, Product2.SKU_External_Id__c, Product2.SKU_Package_Type__c, Product2.Price__c, Quantity_Order__c, 
                Product2.Cases_per_layer__c, Product2.Cases_per_pallet__c, Product2.Pkg_Name__c, Inventory__c, Suggested__c, Suggested_Icon__c, Mandate__c, Invoice__c, Type__c,
                IsUnitQuantity__c, LineNumber__c, UOM__c, Order_UOM__c, Product2.Case_equivalent__c, Pinned_Notes__c, Expiration_Date__c, CreatedBy.Name, Pinned__c, Product2.Sub_Style__c,
                Product2.Seasonal__c, Suggested_Sell_Story_Text__c, Product2.Draft_Or_Package__c, Product2.QuantityUnitOfMeasure, Feedback__c
                FROM OrderItem 
                WHERE OrderId = :orderId];
    }

    public static List<OrderItem> getOrderItemByOrderIds(Set<Id> orderIds) {
        return [SELECT Id, OrderId, Product2Id, Product2.Name, Product2.SKU_External_Id__c, Product2.SKU_Package_Type__c, Product2.Price__c, Quantity_Order__c, 
                Product2.Cases_per_layer__c, Product2.Cases_per_pallet__c, Product2.Pkg_Name__c, Inventory__c, Suggested__c, Suggested_Icon__c, Mandate__c, Invoice__c, Type__c,
                IsUnitQuantity__c, LineNumber__c, UOM__c, Order_UOM__c, Product2.Case_equivalent__c, Pinned_Notes__c, Expiration_Date__c, CreatedBy.Name, Pinned__c, Product2.Sub_Style__c,
                Product2.Seasonal__c, Suggested_Sell_Story_Text__c, Product2.Draft_Or_Package__c, Product2.QuantityUnitOfMeasure, Feedback__c, Order.AccountId, Order.Status
                FROM OrderItem 
                WHERE OrderId IN :orderIds];
    }

    public static List<OrderItem> getOrderItemByIds(Set<String> orderItemIds) {
        return [SELECT Id, OrderId, Product2Id, Product2.Name, Product2.SKU_External_Id__c, Product2.SKU_Package_Type__c, Product2.Price__c, Quantity_Order__c, 
                Product2.Cases_per_layer__c, Product2.Cases_per_pallet__c, Product2.Pkg_Name__c, Inventory__c, Suggested__c, Suggested_Icon__c, Mandate__c, Invoice__c, Type__c,
                IsUnitQuantity__c, LineNumber__c, UOM__c, Order_UOM__c, Product2.Case_equivalent__c, Pinned_Notes__c, Expiration_Date__c, CreatedBy.Name, Pinned__c, Product2.Sub_Style__c,
                Product2.Seasonal__c, Suggested_Sell_Story_Text__c, Product2.Draft_Or_Package__c, Product2.QuantityUnitOfMeasure, Feedback__c, Order.AccountId, Order.Status
                FROM OrderItem 
                WHERE Id IN :orderItemIds];
    }

    public static List<OrderItem> getOrderItemsByInvoice(Set<Id> orderInvoiceIds, Boolean hidden) {
        return [SELECT Id, Order.Name, OrderId, Product2Id, Product2.SKU_External_Id__c, Order.Invoice_Date__c,
                Quantity_Order__c, IsHidden__c
                FROM OrderItem 
                WHERE OrderId IN :orderInvoiceIds
                AND isHidden__c = :hidden
                ORDER BY Order.Invoice_Date__c DESC];
    }

    public static List<OrderItem> insertOrderItems(List<OrderItem> orderItemsToInsert) {
        insert orderItemsToInsert;
        return orderItemsToInsert;
    }

    public static List<OrderItem> updateOrderItems(List<OrderItem> orderItemsToUpdate) {
        update orderItemsToUpdate;
        return orderItemsToUpdate;
    }

    public static List<OrderItem> upsertOrderItems(List<OrderItem> orderItemsToUpsert) {
        upsert orderItemsToUpsert;
        return orderItemsToUpsert;
    }

    public static List<OrderItem> deleteOrderItems(List<OrderItem> orderItemsToDelete) {
        delete orderItemsToDelete;
        return orderItemsToDelete;
    }
}