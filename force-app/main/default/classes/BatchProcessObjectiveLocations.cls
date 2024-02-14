public class BatchProcessObjectiveLocations implements Database.Batchable<sObject>, Database.stateful {
    public String query;
    public Boolean pictureRequired;
    public String objectiveId;
    public String objectiveType;
    public String objectivePointers;
    public Map<String, String> objectiveLocationMap;
    public List<String> buSelected;
    public List<String> warehouseSelected;
    public List<String> salesorgSelected;
    public Set<Id> selectedAccountIds = new Set<Id>();
    public Boolean hasError = false;

    public BatchProcessObjectiveLocations(){
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        Id thisJobId = BC.getJobId();
        List<AsyncApexJob> lstJobs = [SELECT Id FROM AsyncApexJob WHERE (status = 'Holding' OR status = 'Queued' OR status = 'Preparing' OR status = 'Processing') AND (ApexClass.Name = 'BatchProcessObjectiveLocations' OR ApexClass.Name = 'BatchDeleteObjectiveAccounts') AND id != :thisJobId];
        if (!lstJobs.IsEmpty() && !UserInfo.getName().contains('Data Migration')) {    //If is being run by Data Migration we allow multiple jobs to get queued
            //Fake query that will return no records
            return Database.getQueryLocator('SELECT Id FROM Account WHERE Id=\'xxxxxxxxxxxxxxxxxx\'');
        } else {
            return Database.getQueryLocator(query);
        }
    }

    public void execute(Database.BatchableContext BC, List<Account> accountList){
        try{
            List<Objective_Product__c> objectiveProductListTerr = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{objectiveId});
            Set<String> productIdSet = new Set<String>();
            for(Objective_Product__c objProd : objectiveProductListTerr){
                productIdSet.add(objProd.Product__c);
            }
            List<Product2> selectedProducts = ProductDAO.getProductByIds(productIdSet);
            Set<String> skuProductIds = new Set<String>();
            Set<String> subBrandProductIds = new Set<String>();
            Set<String> brandProductIds = new Set<String>();
            Id skuProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
            Id subBrandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
            Id brandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
            for(Product2 prodObj : selectedProducts){
                if(prodObj.RecordTypeId == skuProductRecordTypeId){
                    skuProductIds.add(prodObj.Id);
                }
                if(prodObj.RecordTypeId == subBrandProductRecordTypeId){
                    subBrandProductIds.add(prodObj.Id);
                }
                if(prodObj.RecordTypeId == brandProductRecordTypeId){
                    brandProductIds.add(prodObj.Id);
                }
            }

            List<Product2> skuSubBrandBrandProductList = ProductDAO.getProductByIdSubBrandBrand(skuProductIds, subBrandProductIds, brandProductIds, skuProductRecordTypeId);
            Set<String> productTerritories = new Set<String>();
            for(Product2 prodObj: skuSubBrandBrandProductList){
                if(prodObj.Territories__c != null){
                    List<String> objProdTerrSplit = prodObj.Territories__c.split(',');
                    for(String terr: objProdTerrSplit){
                        productTerritories.add(terr);
                    }
                }
            }

            Set<Id> totalAccountIds = new Set<Id>();
            Set<Id> CBSAccountIds = new Set<Id>();
            for(Account accountObj : accountList){
                totalAccountIds.add(accountObj.Id);
                if(accountObj.VIP_Instance__c == 'CBS'){
                    CBSAccountIds.add(accountObj.Id);
                }
            }

            Set<Id> existingAccountIds = new Set<Id>();
            List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByAccountAndObjective(totalAccountIds, objectiveId);
            Map<Id, Objective_Account__c> existingObjectiveAccountMap = new Map<Id, Objective_Account__c>();
            for(Objective_Account__c objAcc : objectiveAccountList){
                existingAccountIds.add(objAcc.Account__c);
                existingObjectiveAccountMap.put(objAcc.Account__r.Id, objAcc);
            }

            //Check to see if there are any CBS accounts to grab AccountTeamMembers for
            Map<Id,List<AccountTeamMember>> accountTeamMap = new Map<Id,List<AccountTeamMember>>();
            if(!CBSAccountIds.isEmpty()){
                //Get all related AccountTeamMembers for CBS Accounts
                List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.getAccountTeamMembersByAccountIds(CBSAccountIds);
                for(AccountTeamMember teamMember : accountTeamMembers){
                    if(!accountTeamMap.containsKey(teamMember.AccountId)){
                        List<AccountTeamMember> accountTeam = new List<AccountTeamMember>();
                        accountTeam.add(teamMember);
                        accountTeamMap.put(teamMember.AccountId, accountTeam);
                    }else{
                        List<AccountTeamMember> accountTeam = accountTeamMap.get(teamMember.AccountId);
                        accountTeam.add(teamMember);
                    }
                }
            }

            Territory_Matching__c terrMatchingCustomSetting = Territory_Matching__c.getInstance();
            List<Objective_Account__c> objectiveAccountsToInsert = new List<Objective_Account__c>();
            List<Objective_Account__c> objectiveAccountsToUpdate = new List<Objective_Account__c>();
            for(Account accountObj : accountList) {
                //Territory Matching is turned On/Off in the Custom Settings, although we don't expect it to ever be turned off
                if(terrMatchingCustomSetting.Territory_Matching__c) {
                    if(!existingAccountIds.contains(accountObj.Id)) {
						//Objective Account Needs to be Created                        
                        if(accountObj.Territories__c != null){
                            Boolean terrMisMatch = true;
                            List<String> accountTerr = accountObj.Territories__c.split(',');
                            for(String productTerr : productTerritories){
                                if(accountTerr.contains(productTerr)){
                                    terrMisMatch = false;
                                }
                            }
                            if(!terrMisMatch){
                                Objective_Account__c objAcc = new Objective_Account__c();
                                objAcc.RecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get(objectiveType).getRecordTypeId();
                                objAcc.Account__c = accountObj.Id;
                                objAcc.Objective__c = objectiveId;
                                if(objectiveLocationMap.containsKey(accountObj.VIP_Instance__c)){
                                    objAcc.Objective_Location__c = objectiveLocationMap.get(accountObj.VIP_Instance__c);
                                }
                                if(pictureRequired){
                                    objAcc.Pictured_Required__c = true;
                                }
                                //if CBS account match Sales Pointer to AcccountTeamMember and set as ObjAcc owner
                                if(accountObj.VIP_Instance__c == 'CBS' && objectivePointers != null && accountTeamMap.containsKey(accountObj.Id)){
                                    List<AccountTeamMember> accountTeam = accountTeamMap.get(accountObj.Id);
                                    for(AccountTeamMember teamMember : accountTeam){
                                        Set<String> objPointers = new Set<String>(objectivePointers.split(';'));
                                        Set<String> userPointers = new Set<String>(teamMember.Sales_Pointer__c.split(';'));
                                        if(userPointers.containsAll(objPointers) && !teamMember.TeamMemberRole.contains('Manager')){
                                            objAcc.OwnerId = teamMember.UserId;
                                        }
                                    }
                                }
                                if(objAcc.OwnerId == null){
                                    objAcc.OwnerId = accountObj.OwnerId;
                                }
                                objectiveAccountsToInsert.add(objAcc);
                                selectedAccountIds.add(accountObj.Id);
                            }
                        }
                    } else {
                        //The Objective Account already exists, check that the Owner is correct
                        Objective_Account__c objAcc = existingObjectiveAccountMap.get(accountObj.Id);
                        if(accountObj.Territories__c != null) {
                            Boolean terrMisMatch = true;
                            List<String> accountTerr = accountObj.Territories__c.split(',');
                            for(String productTerr : productTerritories){
                                if(accountTerr.contains(productTerr)){
                                    terrMisMatch = false;
                                }
                            }
                            if(!terrMisMatch){
                                Id tmpOwnerId;
                                //if CBS account match Sales Pointer to AcccountTeamMember and set as ObjAcc owner
                                if(accountObj.VIP_Instance__c == 'CBS' && objectivePointers != null && accountTeamMap.containsKey(accountObj.Id)){
                                    List<AccountTeamMember> accountTeam = accountTeamMap.get(accountObj.Id);
                                    for(AccountTeamMember teamMember : accountTeam){
                                        Set<String> objPointers = new Set<String>(objectivePointers.split(';'));
                                        Set<String> userPointers = new Set<String>(teamMember.Sales_Pointer__c.split(';'));
                                        if(userPointers.containsAll(objPointers) && !teamMember.TeamMemberRole.contains('Manager')) {
                                            tmpOwnerId = teamMember.UserId;
                                        }
                                    }
                                }
                                if(tmpOwnerId == null){
                                  	tmpOwnerId = accountObj.OwnerId;
                                }
                                if (objAcc.OwnerId <> tmpOwnerId) {
                                    objAcc.OwnerId = tmpOwnerId;
                                    objectiveAccountsToUpdate.add(objAcc);
                                }
                            }
                        }                                                    
                        selectedAccountIds.add(accountObj.Id);
                    }
                } else {
                    if(!existingAccountIds.contains(accountObj.Id)){
                        Objective_Account__c objAcc = new Objective_Account__c();
                        objAcc.RecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get(objectiveType).getRecordTypeId();
                        objAcc.Account__c = accountObj.Id;
                        objAcc.Objective__c = objectiveId;
                        if(objectiveLocationMap.containsKey(accountObj.VIP_Instance__c)){
                            objAcc.Objective_Location__c = objectiveLocationMap.get(accountObj.VIP_Instance__c);
                        }
                        if(pictureRequired){
                            objAcc.Pictured_Required__c = true;
                        }
                        //if CBS account match Sales Pointer to AcccountTeamMember and set as ObjAcc owner
                        if(accountObj.VIP_Instance__c == 'CBS' && objectivePointers != null && accountTeamMap.containsKey(accountObj.Id)){
                            List<AccountTeamMember> accountTeam = accountTeamMap.get(accountObj.Id);
                            for(AccountTeamMember teamMember : accountTeam){
                                Set<String> objPointers = new Set<String>(objectivePointers.split(';'));
                                Set<String> userPointers = new Set<String>(teamMember.Sales_Pointer__c.split(';'));
                                if(userPointers.containsAll(objPointers) && !teamMember.TeamMemberRole.contains('Manager')){
                                    objAcc.OwnerId = teamMember.UserId;
                                }
                            }
                        }
                        if (objAcc.OwnerId == null) {
                            objAcc.OwnerId = accountObj.OwnerId;
                        }
                        objectiveAccountsToInsert.add(objAcc);
                        selectedAccountIds.add(accountObj.Id);
                    } else {
                        selectedAccountIds.add(accountObj.Id);
                    }
                }
            }

            if (!objectiveAccountsToInsert.isEmpty()) {
                ObjectiveAccountDAO.insertObjectiveAccounts(objectiveAccountsToInsert);
            }
            if (!objectiveAccountsToUpdate.isEmpty()) {
     	       ObjectiveAccountDAO.updateObjectiveAccounts(objectiveAccountsToUpdate);
            }
        } catch(Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchProcessObjectiveLocations', 'BatchProcessObjectiveLocations.execute()');
            hasError = true;
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (hasError == false && selectedAccountIds.size() > 0) {   //We check this because if the above code had an error and the selectedAccountIds did not get set, this process would delete ALL Objective Accounts
            BatchDeleteObjectiveAccounts batchDeleteObjAccRecords = new BatchDeleteObjectiveAccounts();
        	batchDeleteObjAccRecords.query = 'SELECT Id, Objective__c, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Manual_Account_Upload__c,' +
                							' Completed_Count__c, Objective_Type__c' + 
            	                            ' FROM Objective_Account__c' +
	                                        ' WHERE Objective__c = :objectiveId';
	        batchDeleteObjAccRecords.objectiveId = objectiveId;
	        batchDeleteObjAccRecords.selectedAccountIds = selectedAccountIds;
	        Id batchProcessId = Database.executeBatch(batchDeleteObjAccRecords);
        }
    }
}