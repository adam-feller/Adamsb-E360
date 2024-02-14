global without sharing class PriceBookEntry_To_OrderItem_Queueable implements Queueable{
    private enum Stage {QUERY, PROCESSING}
    private Stage currentStage;
    private id lastProcessedId;
    private Integer QUERY_LIMIT;
    private boolean IS_LIMIT_REACHED;
    private date sDate;
    private date eDate;


    global PriceBookEntry_To_OrderItem_Queueable() {
        currentStage = Stage.QUERY;
        eDate = system.today();
        sDate = eDate.addDays(-90);
        PriceBookEntry[] pbe = [SELECT Id FROM PriceBookEntry ORDER BY ID DESC LIMIT 1];
        if (pbe.size()>0) {
            lastProcessedId = pbe[0].id;
        }
        this.QUERY_LIMIT = 200;
    
    }

    global PriceBookEntry_To_OrderItem_Queueable(Date startDate, Date endDate) {
        currentStage = Stage.QUERY;
        eDate = endDate;
        sDate = startDate;
        QUERY_LIMIT = 200;
    }

    public PriceBookEntry_To_OrderItem_Queueable setLimit(Integer querylimit){
        this.QUERY_LIMIT = querylimit;
        return this;
    }

    global void execute(queueableContext QC){
        system.debug('lastProcessedId: '+lastProcessedId);

        PriceBookEntry[] pbeList = queryPricebookEntries(lastProcessedId, this.sDate, this.eDate, QUERY_LIMIT);
        IS_LIMIT_REACHED = (QUERY_LIMIT == pbeList.size());
        if (pbeList.size() > 0) {
            lastProcessedId = pbeList[pbeList.size()-1].Id;
        }
        OrderItem[] oiList = copyPricebookEntries(pbeList);
        database.upsert (oiList,orderitem.External_Id__c.getDescribe().getSObjectField(), false);
        if (IS_LIMIT_REACHED){
            system.enqueueJob(this);
        }
    }
    
    public static OrderItem[] copyPricebookEntries(PriceBookEntry[] pbeList){
        List<OrderItem> orderItemList = new List<OrderItem>();
        for (PriceBookEntry pbe: pbeList){
            orderItemList.add(
                copyPriceBookEntryValues(pbe)
            );
        }
        return orderItemList;
    }

    public static OrderItem copyPriceBookEntryValues(PriceBookEntry pbe){
        return new OrderItem(
            CE_QTY__c = pbe.CE_QTY__c,
            Unit_Discount__c = pbe.Discount_Amount__c,
            Ext_Price__c = pbe.Extended_price_amt__c,
            External_Id__c = pbe.External_Id__c,
            LineNumber__c = pbe.Invoice_Line_Number__c,
            Order =  New Order(External_Id__c = pbe.Invoice__r.External_Id__c),
            Order_Date__c = pbe.Order_Date__c,
            Order_Method__c = pbe.Order_Method__c,
            Out_of_Stock_unit_Qty__c = pbe.Out_of_Stock_unit_Qty__c,
            Product2id = pbe.Product2id,
            Quantity_Order__c = pbe.Quantity_sold__c,
            Quantity = 1,
            Unit_Cost_Amount__c = pbe.Unit_Cost_Amount__c,
            UnitPrice = pbe.Unit_Price_Amount__c
        );
    }
    
    public static PriceBookEntry[] queryPricebookEntries(Id lastProcessedId, Date startDate, Date endDate, Integer QUERY_LIMIT){
        PriceBookEntry[] pbeList = [SELECT 
            id,
            Pricebook2id,
            CE_QTY__c,
            Discount_Amount__c,
            Extended_price_amt__c,
            External_Id__c,
            Invoice_Line_Number__c,
            Invoice__r.External_Id__c,
            IsActive,
            Order_Date__c,
            Order_Method__c,
            Out_of_Stock_unit_Qty__c,
            Product2id,
            //Product2.sku_external_id__c,
            Quantity_sold__c,
            SALES_ORG_DIM_ID__c,
            Unit_Cost_Amount__c,
            Unit_Price_Amount__c,
            VIP_Instance__c,
            WAREHOUSE_DIM_ID__c 
            FROM PriceBookEntry 
            WHERE ID <= :lastProcessedId 
                AND Invoice__r.Invoice_Date__c >= :startDate 
                AND Invoice__r.Invoice_Date__c <= :endDate 
                AND TYPE__C = 'Invoice Item'
            ORDER BY ID DESC
            LIMIT :QUERY_LIMIT
        ];
        return pbeList;
    }

    public static void executeNow(){
        system.enqueueJob(new PriceBookEntry_To_OrderItem_Queueable().setLimit(2000));
    }

}