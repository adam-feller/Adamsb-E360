public class ScheduleBatchDisplayProductDSOFCreation implements Schedulable {

    public void execute(SchedulableContext sc) {
        DSOF_Filters__c dsofFilters = DSOF_Filters__c.getValues('DSOF Filters');
        String accountStatus = dsofFilters.Account_Status__c;
        String displayableStatus = dsofFilters.Displayable_Status__c;
        List<String> accountStatusList = accountStatus.split(',');
        Set<String> productExternalIds = new Set<String>();
        Set<String> accountChains = new Set<String>();
        Set<String> accountBus = new Set<String>();
        Set<String> accountSalesOrg = new Set<String>();
        Map<String, List<Display_Product__c>> displayProductMapBU = new Map<String, List<Display_Product__c>>();
        Map<String, List<Display_Product__c>> displayProductMapSalesOrg = new Map<String, List<Display_Product__c>>();
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        List<Display_Product__c> uploadedDisplayProducts = DisplayProductDAO.getBatchDisplayProducts(batchDisplayProductRecordTypeId);
        for(Display_Product__c dispProd : uploadedDisplayProducts){
            if(dispProd.Product_Brand_Id__c != null && dispProd.Chain__c != null && (dispProd.BU__c != null || dispProd.Sales_Org__c != null)){
                if(!dispProd.Processed__c){
                    productExternalIds.add(dispProd.Product_Brand_Id__c);
                    accountChains.add(dispProd.Chain__c);
                    if(dispProd.BU__c != null){
                        accountBus.add(dispProd.BU__c);
                    }
                    if(dispProd.Sales_Org__c  != null){
                        accountSalesOrg.add(dispProd.Sales_Org__c);
                    }
                    List<Display_Product__c> displayProductList = new List<Display_Product__c>();
                    if(dispProd.BU__c != null){
                        if(displayProductMapBU.containsKey(dispProd.BU__c + dispProd.Chain__c)){
                            displayProductList = displayProductMapBU.get(dispProd.BU__c + dispProd.Chain__c);
                        }
                        displayProductList.add(dispProd);
                        displayProductMapBU.put(dispProd.BU__c + dispProd.Chain__c, displayProductList);
                    }
                    if(dispProd.Sales_Org__c != null){
                        if(displayProductMapSalesOrg.containsKey(dispProd.Sales_Org__c + dispProd.Chain__c)){
                            displayProductList = displayProductMapSalesOrg.get(dispProd.Sales_Org__c + dispProd.Chain__c);
                        }
                        displayProductList.add(dispProd);
                        displayProductMapSalesOrg.put(dispProd.Sales_Org__c + dispProd.Chain__c, displayProductList);
                    }
                }
            }
        }

        if(!productExternalIds.isEmpty()){
            List<Product2> productList = ProductDAO.getProductBySubBrandExternalIds(productExternalIds);
            Map<String, Id> productMap = new Map<String, Id>();
            Map<String, Id> brandMap = new Map<String, Id>();
            Map<String, Id> subbrandMap = new Map<String, Id>();
            Map<String, Id> brewerMap = new Map<String, Id>();
            Map<String, Set<String>> productTerritoriesMap = new Map<String, Set<String>>();
            for(Product2 prod : productList){
                if(prod.Subbrand_External_Id__c != null){
                    productMap.put(prod.Subbrand_External_Id__c, prod.Id);
                    if(prod.BrandId__c != null){
                        brandMap.put(prod.Subbrand_External_Id__c, prod.BrandID__c);
                    }
                    if(prod.Subbrandid__c != null){
                        subbrandMap.put(prod.Subbrand_External_Id__c, prod.Subbrandid__c);
                    }
                    if(prod.BrewerId__c != null){
                        brewerMap.put(prod.Subbrand_External_Id__c, prod.BrewerId__c);
                    }
                }
                Set<String> prodTerrSet = new Set<String>();
                if(prod.Territories__c != null){
                    if(productTerritoriesMap.containsKey(prod.Subbrandid__r.Subbrand_External_Id__c)){
                        prodTerrSet = productTerritoriesMap.get(prod.Subbrandid__r.Subbrand_External_Id__c);
                    }

                    List<String> objProdTerrSplit = prod.Territories__c.split(',');
                    for(String terr: objProdTerrSplit){
                        prodTerrSet.add(terr);
                    }
                    productTerritoriesMap.put(prod.Subbrandid__r.Subbrand_External_Id__c, prodTerrSet);
                }
            }

            BatchDisplayProductDSOFCreation batchDisplayproducts = new BatchDisplayProductDSOFCreation();
            batchDisplayproducts.query = 'SELECT Id, Name, Beer_Company__c, Warehouse__c, VIP_Account_Number__c, VIP_Instance__c, Visit_Completed__c, Chain_Independent__c,' +
                                        ' ExternalId__c, VIP_Composite_Key__c, OwnerId, Territories__c, Chain__c, SalesOrg__c' +
                                        ' FROM Account' + 
                                        ' WHERE (VIP_Instance__c IN :accountBus' +
                                        ' OR SalesOrg__c IN :accountSalesOrg)' +
                                        ' AND Chain__c IN :accountChains' +
                                        ' AND Displayable_Status__c != :displayableStatus' +
                                        ' AND Status__c NOT IN :accountStatusList';

            batchDisplayproducts.uploadedDisplayProducts = uploadedDisplayProducts;
            batchDisplayproducts.displayProductMapBU = displayProductMapBU;
            batchDisplayproducts.displayProductMapSalesOrg = displayProductMapSalesOrg;
            batchDisplayproducts.accountChains = accountChains;
            batchDisplayproducts.accountBus = accountBus;
            batchDisplayproducts.accountSalesOrg = accountSalesOrg;
            batchDisplayproducts.productMap = productMap;
            batchDisplayproducts.productTerritoriesMap = productTerritoriesMap;
            batchDisplayproducts.accountStatusList = accountStatusList;
            batchDisplayproducts.displayableStatus = displayableStatus;
            batchDisplayproducts.brandMap = brandMap;
            batchDisplayproducts.subbrandMap = subbrandMap;
            batchDisplayproducts.brewerMap = brewerMap;
            Database.executebatch(batchDisplayproducts);
        }
    }
}