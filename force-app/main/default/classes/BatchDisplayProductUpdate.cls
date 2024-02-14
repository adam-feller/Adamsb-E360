public class BatchDisplayProductUpdate implements Database.Batchable<sObject>{

    public String query;
    public Map<String, Display_Product__c> updateDisplayProductMap;
    public Map<String, Display_Product__c> deleteDisplayProductMap;
    public Set<Id> existingParentDisplayProductIds;
    public Map<String, Id> productMap;
    public Map<String, Set<String>> productTerritoriesMap;

    public BatchDisplayProductUpdate(){
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Display_Product__c> displayProductList){
        try{
            Territory_Matching__c terrMatchingCustomSetting = Territory_Matching__c.getInstance();

            List<Display_Product__c> displayProductsToUpdate = new List<Display_Product__c>();
            List<Display_Product__c> displayProductsToDelete = new List<Display_Product__c>();
            for(Display_Product__c dispProd : displayProductList){
                if(updateDisplayProductMap.containsKey(dispProd.Parent_Display_Product__c)){
                    Display_Product__c tempDispProd = updateDisplayProductMap.get(dispProd.Parent_Display_Product__c);
                    dispProd.Ad_Price__c = tempDispProd.Ad_Price__c;
                    dispProd.End_Date__c = tempDispProd.End_Date__c;
                    dispProd.Start_Date__c = tempDispProd.Start_Date__c;
                    dispProd.Family_Brand_Pack__c = tempDispProd.Family_Brand_Pack__c;
                    dispProd.Percentage__c = tempDispProd.Percentage__c;
                    dispProd.Primary_Secondary__c = tempDispProd.Primary_Secondary__c;
                    if(productMap.containsKey(tempDispProd.Product_Brand_Id__c)){
                        dispProd.Product__c = productMap.get(tempDispProd.Product_Brand_Id__c);
                    }
                    if(terrMatchingCustomSetting.Territory_Matching__c){
                        Boolean terrMisMatch = true;
                        if(productTerritoriesMap.containsKey(tempDispProd.Product_Brand_Id__c)){
                            if(dispProd.Account__r.Territories__c != null){
                                List<String> accountTerr = dispProd.Account__r.Territories__c.split(',');
                                for(String productTerr : productTerritoriesMap.get(tempDispProd.Product_Brand_Id__c)){
                                    if(accountTerr.contains(productTerr)){
                                        terrMisMatch = false;
                                    }
                                }
                                if(!terrMisMatch){
                                    displayProductsToUpdate.add(dispProd);
                                }
                            }
                        }
                    } else {
                        displayProductsToUpdate.add(dispProd);
                    }
                   
                }
                if(deleteDisplayProductMap.containsKey(dispProd.Parent_Display_Product__c)){
                if(dispProd.Parent_Display_Product__r.Inactive__c == true){
                    displayProductsToDelete.add(dispProd);
                }
            }

                
            }

            if(!updateDisplayProductMap.values().isEmpty()){
                for(Display_Product__c dispProd : updateDisplayProductMap.values()){
                    dispProd.Batch_Processed_DateTime__c = System.now();
                }
                DisplayProductDAO.updateDisplayProducts(updateDisplayProductMap.values());
            }

            if(!displayProductsToUpdate.isEmpty()){
                DisplayProductDAO.updateDisplayProducts(displayProductsToUpdate);
            }

            if(!displayProductsToDelete.isEmpty()){
                DisplayProductDAO.deleteDisplayProducts(displayProductsToDelete);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchDisplayProductUpdate', 'BatchDisplayProductUpdate.execute()');
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}