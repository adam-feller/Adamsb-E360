public without sharing class InvoiceStagingHandler {
    private static Reyes_Org_Setting__c reyesSettings = null; 
    private static Id INVOICE_ORDER_RECORDTYPE = null; 
    
    public static Reyes_Org_Setting__c getReyesOrgSetting(){
        if (reyesSettings == null) reyesSettings = Reyes_Org_Setting__c.getInstance();
        return reyesSettings;
    }

    public static boolean isDeletingCustomInvoiceRecordsAfterProcessingEnabled(){
        return (getReyesOrgSetting()?.DeleteCustomInvoiceRecords__c == true);
    }

    public static boolean isSavingInvoicesAsOrdersEnabled(){
        return (getReyesOrgSetting()?.InvoicesAsOrders__c == true);
    }

    public static boolean isSavingInvoicesAsPricebookEntriesEnabled(){
        return (getReyesOrgSetting()?.InvoiceItemsAsPricebookEntries__c == true);
    }

    public static Id getInvoiceOrderRecordTypeId(){
        if (INVOICE_ORDER_RECORDTYPE == null) INVOICE_ORDER_RECORDTYPE = [SELECT Id FROM RecordType WHERE DeveloperName ='Invoice' AND SObjectType ='Order'].Id; //01203000000H1j1AAC
        return INVOICE_ORDER_RECORDTYPE;
    }

    public static void afterInvoiceUpsert(List<Invoice__c> newInvoices){
        system.debug(isSavingInvoicesAsOrdersEnabled());
        if (isSavingInvoicesAsOrdersEnabled()){
            List<Order> ordersToCreate = New List<Order>();
            for (Invoice__c inv: newInvoices){
                ordersToCreate.add(createOrder(inv));
            }
            //upsert ordersToCreate External_Id__c;
            database.upsert(ordersToCreate, Order.External_Id__c.getDescribe().getSObjectField(),false);
        }
        system.debug(isDeletingCustomInvoiceRecordsAfterProcessingEnabled());
        if (isDeletingCustomInvoiceRecordsAfterProcessingEnabled()){
            try {
                delete newInvoices;
            } catch (exception ex){
                //do nothing
            }
        }
    }

    public static Order createOrder(Invoice__c invoice){
        return new Order(
            RecordTypeId = InvoiceStagingHandler.getInvoiceOrderRecordTypeId(),
            AccountId = invoice.AccountId__c,
            InvoicedAccount__c = invoice.AccountId__c,
            Status = 'Invoice',
            EffectiveDate = invoice.Invoice_Date__c,
            Invoice_Date__c = invoice.Invoice_Date__c,
            Total_Discount__c = invoice.Discount_Amount__c,
            External_Id__c = invoice.External_Id__c,
            Keg_Count__c = invoice.Keg_Count__c,
            Invoice_Number__c = invoice.Name,
            Name = invoice.Name,
            Case_Count__c = invoice.Net_Case_Qty__c,
            CE_QTY__c = invoice.Net_CE_Qty__c,
            Net_Cost_Amount__c = invoice.Net_Cost_Amount__c,
            Net_Line_Count__c = invoice.Net_line_count__c,
            Total_Net_Price__c = invoice.Net_Price_Amount__c,
            Order_Date__c = invoice.Order_Date__c,
            Order_Method__c = invoice.Order_Method__c,
            //Order_Methods__c = invoice.Order_Method__c.replace(':',';'),
            SALES_ORG_DIM_ID__c =  invoice.Sales_Org_DIM_ID__c,
            WAREHOUSE_DIM_ID__c =  invoice.Warehouse_DIM_ID__c
        );
    }

    public static OrderItem createOrderItem(PricebookEntry_Stage__c peStage){
        return new  OrderItem(
            CE_QTY__c = peStage.CE_QTY__c,
            Unit_Discount__c = peStage.Discount_Amount__c,
            Ext_Price__c = peStage.Extended_price_amt__c,
            External_Id__c = peStage.External_Id__c,
            LineNumber__c = peStage.Invoice_Line_Number__c,
            Order =  New Order(External_Id__c = peStage.Invoice_External_Id__c),
            Order_Date__c = peStage.Order_Date__c,
            Order_Method__c = peStage.Order_Method__c,
            Out_of_Stock_unit_Qty__c = peStage.Out_of_Stock_unit_Qty__c,
            Product2 = new Product2(sku_external_id__c = peStage.Product_External_Id__c),
            Quantity_Order__c = peStage.Quantity_sold__c,
            Quantity = 1,
            Unit_Cost_Amount__c = peStage.Unit_Cost_Amount__c,
            UnitPrice = peStage.Unit_Price_Amount__c
        );
    }

    public static PricebookEntry createPricebookEntry(PricebookEntry_Stage__c peStage, Map<String,ID> pbeMap){
        return new  PricebookEntry(
            Pricebook2id = pbeMap.get(peStage.External_Id__c),
            CE_QTY__c = peStage.CE_QTY__c,
            Discount_Amount__c = peStage.Discount_Amount__c,
            Extended_price_amt__c = peStage.Extended_price_amt__c,
            External_Id__c = peStage.External_Id__c,
            Invoice_Line_Number__c = peStage.Invoice_Line_Number__c,
            Invoice__r =  New Invoice__c(External_Id__c = peStage.Invoice_External_Id__c),
            IsActive = true,
            UnitPrice = 0,
            UseStandardPrice = false,
            Type__c = 'Invoice Item',
            Order_Date__c = peStage.Order_Date__c,
            Order_Method__c = peStage.Order_Method__c,
            Out_of_Stock_unit_Qty__c = peStage.Out_of_Stock_unit_Qty__c,
            Product2 = new Product2(sku_external_id__c = peStage.Product_External_Id__c),
            Quantity_sold__c = peStage.Quantity_sold__c,
            SALES_ORG_DIM_ID__c = peStage.SALES_ORG_DIM_ID__c,
            Unit_Cost_Amount__c = peStage.Unit_Cost_Amount__c,
            Unit_Price_Amount__c = peStage.Unit_Price_Amount__c,
            VIP_Instance__c = peStage.VIP_Instance__c,
            WAREHOUSE_DIM_ID__c = peStage.WAREHOUSE_DIM_ID__c
        );
    }
}