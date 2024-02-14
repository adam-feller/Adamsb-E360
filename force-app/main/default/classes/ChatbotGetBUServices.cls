public class ChatbotGetBUServices {
    @InvocableMethod(label='Get BU Services')
    public static List<ResponsesOutput> getBUServices(List<ResponsesInput> responsesInput) {
        ResponsesOutput output = new ResponsesOutput();
        List<ResponsesOutput> outputList = new List<ResponsesOutput>();

        String accExtId = responsesInput[0].businessUnitId + '*' + responsesInput[0].accountNumber;
        List<Account> accList = [
            SELECT Id,
                   WarehouseCutoffTime__c,
                   Warehouse_Lookup__r.ThirdPartyforDraftService__c,
                   Warehouse_Lookup__r.ThirdPartyforPOS__c,
                   Warehouse_Lookup__r.PayforPOS__c,
                   Warehouse_Lookup__r.RequirePickupValidation__c,
                   Warehouse_Lookup__r.NeonsOnly__c,
                   Warehouse_Lookup__r.NoGlassware__c,
                   Warehouse_Lookup__r.PrintShopRequestsAvailable__c,
                   (SELECT Id, Delivery_Date__c
                    FROM Delivery_Dates__r
                    ORDER BY Delivery_Date__c ASC)
            FROM Account
            WHERE ExternalId__c = :accExtId
            LIMIT 1
        ];

        if (accList.size() > 0) {
            output.cutoffTime = Datetime.newInstance(System.today(), accList[0].WarehouseCutoffTime__c).format('hh:mm a').removeStart('0');
            output.isThirdPartyForService = accList[0].Warehouse_Lookup__r.ThirdPartyforDraftService__c;
            output.isThirdPartyForPOS = accList[0].Warehouse_Lookup__r.ThirdPartyforPOS__c;
            output.isPayForPOS = accList[0].Warehouse_Lookup__r.PayforPOS__c;
            output.isRequirePickupValidation = accList[0].Warehouse_Lookup__r.RequirePickupValidation__c;
            output.isNeonsOnly = accList[0].Warehouse_Lookup__r.NeonsOnly__c;
            output.isNoGlassware = accList[0].Warehouse_Lookup__r.NoGlassware__c;
            output.isPrintShopRequestsAvailable = accList[0].Warehouse_Lookup__r.PrintShopRequestsAvailable__c;
            if (accList[0].Delivery_Dates__r.size() > 0) {
                for (Delivery_Date__c dd : accList[0].Delivery_Dates__r) {
                    if (System.today() < dd.Delivery_Date__c) {
                        output.nextDeliveryDate = dd.Delivery_Date__c.format();
                        output.dayBeforeDelivery = dd.Delivery_Date__c.addDays(-1).format();
                        break;
                    }
                }
            }
        }

        outputList.add(output);
        return outputList;
    }

    public class ResponsesInput {
        @InvocableVariable(required=true)
        public String businessUnitId;

        @InvocableVariable(required=true)
        public String accountNumber;
    }

    public class ResponsesOutput {
        @InvocableVariable(required=false)
        public String cutoffTime;

        @InvocableVariable(required=false)
        public String nextDeliveryDate;

        @InvocableVariable(required=false)
        public String dayBeforeDelivery;

        @InvocableVariable(required=false)
        public Boolean isThirdPartyForService;

        @InvocableVariable(required=false)
        public Boolean isThirdPartyForPOS;

        @InvocableVariable(required=false)
        public Boolean isPayForPOS;

        @InvocableVariable(required=false)
        public Boolean isRequirePickupValidation;

        @InvocableVariable(required=false)
        public Boolean isNeonsOnly;

        @InvocableVariable(required=false)
        public Boolean isNoGlassware;

        @InvocableVariable(required=false)
        public Boolean isPrintShopRequestsAvailable;
    }
}