global class orderEmailTemplateController {

    global Id orderId {get;set;}

    global List<OrderItem> getorderItems(){
        return [SELECT Id, Product2.Name, UnitPrice, Quantity, Product2.Pkg_Name__c, Product2.SKU_Package__c, Product2.Cases_per_layer__c,
                Product2.Cases_per_pallet__c, Product2.VIP_External_Id__c, Inventory__c, Product2.Layer__c, Product2.Pallet__c, 
                Product2.Price__c, Unit_Discount__c, Ext_Price__c
                FROM OrderItem
                WHERE OrderId = :orderId];
    }
}