public without sharing class ObjectiveOpportunityController {
    //This method is called from the ObjectiveOpportunitiesTable.cmp
    //The JSON is retrieved from the Objective_Opportunity__c field (updated via integration) and 
    //displays a table of Objective Opportunities on the Objective Account
    @AuraEnabled
    public static ObjOppData getObjOppData(String recordId) { 
        ObjOppData tableData = new ObjOppData();
        tableData.productData = new List<ProductData>();
        
        //Get Data from Objective Account
        Objective_Account__c objAcc = new Objective_Account__c();
        objAcc = [SELECT Id, Objective_Opportunity__c, recordTypeId FROM Objective_Account__c WHERE Id = :recordId LIMIT 1];
        
        if (objAcc.Objective_Opportunity__c != null) {
            //Convert JSON fron Objective_Opportunity__c
            if (objAcc.Objective_Opportunity__c.startsWith('"')) {
                objAcc.Objective_Opportunity__c = objAcc.Objective_Opportunity__c.mid(1, objAcc.Objective_Opportunity__c.length()-2);
            }
            if (!objAcc.Objective_Opportunity__c.startsWith('[')) {
                objAcc.Objective_Opportunity__c = '[' + objAcc.Objective_Opportunity__c + ']';
            }
            //Store the JSON in custom PayloadData
            String objOpp = objAcc.Objective_Opportunity__c.unescapeJava().replace('\n','');
            List<PayloadData> oppPayload = (List<PayloadData>)JSON.deserialize(objOpp, List<PayloadData>.class);

            //Create Lists for Brand/Subbrand/SKU Queries and add payload info to Map
            Map<String,PayloadData> payloadMap = new Map<String,PayloadData>();
            Set<String> brandExternalIds = new Set<String>();
            Set<String> subbrandExternalIds = new Set<String>();
            Set<String> skuExternalIds = new Set<String>();
            for (PayloadData oppProduct : oppPayload) {
                if (oppProduct.container_type == null) {
                    oppProduct.container_type = oppProduct.container_type_desc;
                }
                if (oppProduct.product_type == 'Brand') {
                    brandExternalIds.add(oppProduct.product_cd);
                    brandExternalIds.add(oppProduct.product_cd + '*%');   	//Adding wildcard for SOQL
                    payloadMap.put(oppProduct.product_cd, oppProduct);
                } else if (oppProduct.product_type == 'Sub-Brand') {
                    subbrandExternalIds.add(oppProduct.product_cd);
                    subbrandExternalIds.add(oppProduct.product_cd + '*%');  //Adding wildcard for SOQL
                    payloadMap.put(oppProduct.product_cd, oppProduct);
                } else if(oppProduct.product_type == 'SKU') {
                    skuExternalIds.add(oppProduct.product_cd);
                    payloadMap.put(oppProduct.product_cd, oppProduct);
                }
            }
            
            //Excecute each query as neccessary and add Product info to ProductData List
            if (brandExternalIds != null && !brandExternalIds.isEmpty()) {
                List<Product2> products = [SELECT Id, Name, Brand_External_Id__c FROM Product2 WHERE Brand_External_Id__c LIKE :brandExternalIds];
                if (products != null && !products.isEmpty()) {
                    for (Product2 product : products) {
                        ProductData pd = new ProductData();
                        pd.productLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + product.Id;
                        pd.productName= product.Name;
                        pd.productExternalId = product.Brand_External_Id__c;
                        tableData.productData.add(pd);
                    }
                } else {
                    System.debug('No matching Brands found');
                }
            }
            if (subbrandExternalIds != null && !subbrandExternalIds.isEmpty()) {
                List<Product2> products = [SELECT Id, Name, Subbrand_External_Id__c FROM Product2 WHERE Subbrand_External_Id__c LIKE :subbrandExternalIds];
                if (products != null && !products.isEmpty()) {
                    for (Product2 product : products) {
                        ProductData pd = new ProductData();
                        pd.productLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + product.Id;
                        pd.productName= product.Name;
                        pd.productExternalId = product.Subbrand_External_Id__c;
                        tableData.productData.add(pd);
                    }
                } else {
                    System.debug('No matching Subbrands found');
                }
            }
            if (skuExternalIds != null && !skuExternalIds.isEmpty()) {
                List<Product2> products = [SELECT Id, Name, SKU_External_Id__c FROM Product2 WHERE SKU_External_Id__c IN :skuExternalIds];
                if (products != null && !products.isEmpty()) {
                    for (Product2 product : products) {
                        ProductData pd = new ProductData();
                        pd.productLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + product.Id;
                        pd.productName= product.Name;
                        pd.productExternalId = product.SKU_External_Id__c;
                        tableData.productData.add(pd);
                    }
                } else {
                    System.debug('No matching SKUs found');
                }
            }

            //Match ProductData List to Payload Map and copy info
            for (ProductData pd : tableData.productData) {
                if (payloadMap.containsKey(pd.productExternalId)) {
                   	pd.containerType = payloadMap.get(pd.productExternalId).container_type;
                   	pd.ceQty = payloadMap.get(pd.productExternalId).ce_qty.substringBefore('.');
                } else {
                    String key = pd.productExternalId.substringBefore('*');   //Use what is before the Asterisk for the key
                    if (payloadMap.containsKey(key)) {
                    	pd.containerType = payloadMap.get(key).container_type;
                  		pd.ceQty = payloadMap.get(key).ce_qty.substringBefore('.');
                    }
                }
            }
        }

        //Get Record Type name from the Id
        tableData.recordTypeName = Schema.getGlobalDescribe().get('Objective_Account__c').getDescribe().getRecordTypeInfosById().get(objAcc.recordTypeId).getName();
        return tableData;
    }

    public class ObjOppData {
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public List<ProductData> productData;
    }

    public class ProductData {
        @AuraEnabled public String productLink;
        @AuraEnabled public String productName;
        @AuraEnabled public String containerType;
        @AuraEnabled public String ceQty;
        @AuraEnabled public String productExternalId;
    }
    
    public class PayloadData {
        public String product_type;
        public String product_cd;
        public String container_type_desc;
        public String container_type;
        public String ce_qty;
    }

}