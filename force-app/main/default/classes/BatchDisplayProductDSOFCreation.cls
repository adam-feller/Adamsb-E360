public class BatchDisplayProductDSOFCreation implements Database.Batchable<sObject>{

    public String query;
    public List<Display_Product__c> uploadedDisplayProducts;
    public Map<String, List<Display_Product__c>> displayProductMapBU;
    public Map<String, List<Display_Product__c>> displayProductMapSalesOrg;
    public Set<String> accountChains;
    public Set<String> accountBus;
    public Set<String> accountSalesOrg;
    public Map<String, Id> productMap;
    public Map<String, Set<String>> productTerritoriesMap;
    public String displayableStatus;
    public List <String> accountStatusList;
    public Map<String, Id> brandMap;
    public Map<String, Id> subbrandMap;
    public Map<String, Id> brewerMap;

    public BatchDisplayProductDSOFCreation(){
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> accountList){
        try{
            Territory_Matching__c terrMatchingCustomSetting = Territory_Matching__c.getInstance();
            List<Display_Product__c> displayProductsToInsert = new List<Display_Product__c>();
            for(Account accObj : accountList){
                if(displayProductMapSalesOrg.containsKey(accObj.SalesOrg__c + accObj.Chain__c)){
                    for(Display_Product__c disProd : displayProductMapSalesOrg.get(accObj.SalesOrg__c + accObj.Chain__c)){
                        displayProductsToInsert.addALL(getDisplayProductsToInsert(accObj, disProd, terrMatchingCustomSetting));
                    }
                }

                if(displayProductMapBU.containsKey(accObj.VIP_Instance__c + accObj.Chain__c)){
                    for(Display_Product__c disProd : displayProductMapBU.get(accObj.VIP_Instance__c + accObj.Chain__c)){
                        displayProductsToInsert.addALL(getDisplayProductsToInsert(accObj, disProd, terrMatchingCustomSetting));
                    }
                }
            }

            if(!displayProductsToInsert.isEmpty()){
                DisplayProductDAO.insertDisplayProducts(displayProductsToInsert);
            }

            for(Display_Product__c dispProd : uploadedDisplayProducts){
                dispProd.Processed__c = true;
                dispProd.Batch_Processed_DateTime__c = System.now();
            }

            if(!uploadedDisplayProducts.isEmpty()){
                DisplayProductDAO.updateDisplayProducts(uploadedDisplayProducts);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchDisplayProductDSOFCreation', 'BatchDisplayProductDSOFCreation.execute()');
        }
    }

    public void finish(Database.BatchableContext BC){
    }

    public List<Display_Product__c> getDisplayProductsToInsert(Account accObj, Display_Product__c disProd, Territory_Matching__c terrMatchingCustomSetting){
        List<Display_Product__c> displayProductsToInsert = new List<Display_Product__c>();
        Display_Product__c newDisplayProduct = disProd.clone(false, false, false, false);
        if(productMap.containsKey(disProd.Product_Brand_Id__c)){
            newDisplayProduct.Product__c = productMap.get(disProd.Product_Brand_Id__c);
        }
        if(subbrandMap.containsKey(disProd.Product_Brand_Id__c)){
            newDisplayProduct.Subbrand__c = subbrandMap.get(disProd.Product_Brand_Id__c);
        }
        if(brandMap.containsKey(disProd.Product_Brand_Id__c)){
            newDisplayProduct.Brand__c = brandMap.get(disProd.Product_Brand_Id__c);
        }
        if(brewerMap.containsKey(disProd.Product_Brand_Id__c)){
            newDisplayProduct.Supplier_Brewer__c = brewerMap.get(disProd.Product_Brand_Id__c);
        }
        newDisplayProduct.RecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Processed').getRecordTypeId();
        newDisplayProduct.Account__c = accObj.Id;
        newDisplayProduct.Processed__c = true;
        newDisplayProduct.Parent_Display_Product__c = disProd.Id;
        if(terrMatchingCustomSetting.Territory_Matching__c){
            Boolean terrMisMatch = true;
            if(productTerritoriesMap.containsKey(disProd.Product_Brand_Id__c)){
                if(accObj.Territories__c != null){
                    List<String> accountTerr = accObj.Territories__c.split(',');
                    for(String productTerr : productTerritoriesMap.get(disProd.Product_Brand_Id__c)){
                        if(accountTerr.contains(productTerr)){
                            terrMisMatch = false;
                        }
                    }
                    if(!terrMisMatch){
                        displayProductsToInsert.add(newDisplayProduct);
                    }
                }
            }
        } else {
            displayProductsToInsert.add(newDisplayProduct);
        }

        return displayProductsToInsert;
    }
}