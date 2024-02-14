public class ScheduleBatchDisplayProductUpdate implements Schedulable {

    public void execute(SchedulableContext sc) {
        Set<Id> existingParentDisplayProductIds = new Set<Id>();
        Set<String> productExternalIds = new Set<String>();
        Map<String, Display_Product__c> updateDisplayProductMap = new Map<String, Display_Product__c>();
        Map<String, Display_Product__c> deleteDisplayProductMap = new Map<String, Display_Product__c>();
        Map<String, Id> productMap = new Map<String, Id>();
        Map<String, Set<String>> productTerritoriesMap = new Map<String, Set<String>>();
        Id batchDisplayProductRecordTypeId = Schema.SObjectType.Display_Product__c.getRecordTypeInfosByName().get('Batch').getRecordTypeId();
        List<Display_Product__c> uploadedDisplayProducts = DisplayProductDAO.getBatchDisplayProductsUpdate(batchDisplayProductRecordTypeId);
        for(Display_Product__c dispProd : uploadedDisplayProducts){
            if(dispProd.Product_Brand_Id__c != null && dispProd.Chain__c != null && (dispProd.BU__c != null || dispProd.Sales_Org__c != null)){
                if(dispProd.Processed__c && dispProd.Batch_Processed_DateTime__c != dispProd.LastModifiedDate){
                    productExternalIds.add(dispProd.Product_Brand_Id__c);
                    existingParentDisplayProductIds.add(dispProd.Id);
                    updateDisplayProductMap.put(dispProd.Id, dispProd);
                }
            }
            if(dispProd.Inactive__c == true){
                deleteDisplayProductMap.put(dispProd.Id, dispProd);
            }
        }

        if(!productExternalIds.isEmpty()){
            List<Product2> productList = ProductDAO.getProductBySubBrandExternalIds(productExternalIds);
            
            for(Product2 prod : productList){
                if(prod.Subbrand_External_Id__c != null){
                    productMap.put(prod.Subbrand_External_Id__c, prod.Id);
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
        }

        if(!existingParentDisplayProductIds.isEmpty()){
            BatchDisplayProductUpdate batchDisplayProductUpdate = new BatchDisplayProductUpdate();
            batchDisplayProductUpdate.query = 'SELECT Id, Ad_Price__c, End_Date__c, Start_Date__c, Parent_Display_Product__c, Family_Brand_Pack__c,' +
                                        ' Percentage__c, Primary_Secondary__c, Account__r.Territories__c, Parent_Display_Product__r.Inactive__c' +
                                        ' FROM Display_Product__c' + 
                                        ' WHERE Parent_Display_Product__c IN :existingParentDisplayProductIds';
            batchDisplayProductUpdate.updateDisplayProductMap = updateDisplayProductMap;
            batchDisplayProductUpdate.deleteDisplayProductMap = deleteDisplayProductMap;
            batchDisplayProductUpdate.existingParentDisplayProductIds = existingParentDisplayProductIds;
            batchDisplayProductUpdate.productMap = productMap;
            batchDisplayProductUpdate.productTerritoriesMap = productTerritoriesMap;
            Database.executebatch(batchDisplayProductUpdate);
        }
    }
}