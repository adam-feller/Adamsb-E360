/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CriticalMinuteController{
    // BSSP-1367 ... Give ISRs Ability to view objectives
    @AuraEnabled 
    public static User fetchUser(){
       User u = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
       return u;
    }

    @AuraEnabled
    public static CriticalMinuteWrapper getCriticalMinuteWrapperObject(String recordId, String productSelectValue){
        CriticalMinuteWrapper criticalMinuteWrapperObject = new CriticalMinuteWrapper();
        criticalMinuteWrapperObject.taskList = CriticalMinuteController.getTask(recordId);

        WCDCBSWrapper wcdCBSWrapperObject = getWCDCBSData(recordId, productSelectValue);
        List<String> salesPointerList = new List<String>();
        for (Integer myInt : wcdCBSWrapperObject.salesPointersList) { 
            salesPointerList.add(String.valueOf(myInt)); 
        }
        List<Objective_Account__c> relatedObjectives = new List<Objective_Account__c>();
        if (wcdCBSWrapperObject.salesPointersList.size() > 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ){
            relatedObjectives = ObjectiveAccountDAO.getObjectiveAccountsByAccountIdCBS(new Set<Id>{recordId}, salesPointerList);
            //BSSP-1108 - We want to move all Completed Objectives to the end of the list, still sorted by End Date
            List<Objective_Account__c> openOAs = new List<Objective_Account__c>();
            List<Objective_Account__c> completedOAs = new List<Objective_Account__c>();
            List<Objective_Account__c> mboOAs = new List<Objective_Account__c>();
            for (Objective_Account__c oa: relatedObjectives) {
                if (oa.Status__c == 'Complete' || oa.of_Opportunities__c == 0) {
                    completedOAs.add(oa);
                } else if (oa.Objective__r.Sub_Type__c == 'MBO') {
                    mboOAs.add(oa);                    
                } else {
                    openOAs.add(oa);
                }                
            }
            relatedObjectives.clear();
            relatedObjectives.addAll(mboOAs);
            relatedObjectives.addAll(openOAs);            
            relatedObjectives.addAll(completedOAs);

        } else if (wcdCBSWrapperObject.salesPointersList.size()== 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ) {
            relatedObjectives = new List<Objective_Account__c>();
        } else {
            relatedObjectives = ObjectiveAccountDAO.getObjectiveAccountsByAccountId(new Set<Id>{recordId});
            //BSSP-1108 - We want to move all Completed Objectives to the end of the list, still sorted by End Date
            List<Objective_Account__c> openOAs = new List<Objective_Account__c>();
            List<Objective_Account__c> completedOAs = new List<Objective_Account__c>();
			List<Objective_Account__c> mboOAs = new List<Objective_Account__c>();            
            for (Objective_Account__c oa: relatedObjectives) {
                if (oa.Status__c == 'Complete' || oa.of_Opportunities__c == 0) {
                    completedOAs.add(oa);
				} else if (oa.Objective__r.Sub_Type__c == 'MBO') {	
                    mboOAs.add(oa);                    
                } else {
                    openOAs.add(oa);
                }                
            }
            relatedObjectives.clear();
            relatedObjectives.addAll(mboOAs);
            relatedObjectives.addAll(openOAs);
            relatedObjectives.addAll(completedOAs);
        }

        Set<Id> objAccIds = new Set<Id>();
        if (objAccIds != null){
            for (Objective_Account__c objAcc : relatedObjectives){
                objAccIds.add(objAcc.Id);
            }
        }
        List<FlowRecordRelation> relatedPausedFlows = FlowRecordRelationDAO.getObjectiveCompletionInterviews(objAccIds);

        Map<Id, String> FlowRecordRelationMap = new Map<Id, String>();
        if (relatedPausedFlows != null){
            for (FlowRecordRelation fr : relatedPausedFlows){
                FlowRecordRelationMap.put(fr.RelatedRecordId, fr.ParentId);
            }
        }

        criticalMinuteWrapperObject.objectiveList = new List<ObjectiveAccountWrapper>();

        if (relatedObjectives != null){
            for (Objective_Account__c obj : relatedObjectives){
                ObjectiveAccountWrapper objAccWrap = new ObjectiveAccountWrapper();
                objAccWrap.Id = obj.Id;
                objAccWrap.Objective = obj.Objective__c;
                objAccWrap.ObjectiveName = obj.Objective_Name__c;
                objAccWrap.Name = obj.Name;
                objAccWrap.Status = obj.Status__c;
                objAccWrap.StartDate = obj.Start_Date__c;
                objAccWrap.EndDate = obj.End_Date__c;
                objAccWrap.RecordTypeId = obj.RecordTypeId;
                objAccWrap.StatusAbbrev = obj.Status_Abbreviated__c;
                objAccWrap.Account = obj.Account__c;
                objAccWrap.NumOfOpportunites = obj.of_Opportunities__c;
				if (obj.of_Opportunities__c == 0) {	
                    objAccWrap.completeIconClass = 'completeImage';	
                }                
                objAccWrap.NumSubAndApp = obj.Completed_Count__c ;
				if (obj.Objective__r.Sub_Type__c == 'MBO') {	
                	objAccWrap.mboIconClass = 'mboImage';	
                }                
                if (FlowRecordRelationMap != null && FlowRecordRelationMap.containsKey(obj.Id)){
                    objAccWrap.flowRelation = FlowRecordRelationMap.get(obj.id);
                }
                criticalMinuteWrapperObject.objectiveList.add(objAccWrap);
            }
        }

        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        criticalMinuteWrapperObject.chainIndependent = accountList[0].Chain_Independent__c;
        criticalMinuteWrapperObject.controllable = accountList[0].Controllable__c;

        //Pinned Products Information
        criticalMinuteWrapperObject.pinnedProductDetails = new PinnedProductWrapper();
        //BSSP-1837 - decided that want to use Pinned Products on Non-Controllable
        //if (accountList[0].Controllable__c == 'Controllable') {
            List<Product_Feedback__c> pinnedProductLineItems = ProductFeedbackDAO.getPinnedProductsByAccountandExpirationDate(accountList[0].Id, System.Today());
            criticalMinuteWrapperObject.pinnedProductDetails.showPinnedProducts = true;
            criticalMinuteWrapperObject.pinnedProductDetails.numPinnedProducts = pinnedProductLineItems.size();
        
        return criticalMinuteWrapperObject;
    }

    @AuraEnabled
    public static SuggestedSellDataWrapper getCriticalMinuteSuggestedData(String recordId){
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        SuggestedSellDataWrapper suggestedSellData = new SuggestedSellDataWrapper();
        suggestedSellData.chainIndependent = accountList[0].Chain_Independent__c;
        if (accountList[0].Chain_Independent__c != 'Chain') {
            if (accountList[0].ExternalId__c != null) {
                HttpResponse suggestedSellResponse = MulesoftUtility.mulesoftCallout('Suggested Sell', accountList[0].ExternalId__c, null, null);
                if (suggestedSellResponse.getStatusCode() == 200){
                    suggestedSellData.suggestedSellList = handleSuggestedSellData(suggestedSellResponse);
                } else if (suggestedSellResponse.getStatusCode() == 400){
                    suggestedSellData.suggestedSellList = null;
                    suggestedSellData.suggestedError = '400';
                } else if (suggestedSellResponse.getStatusCode() == 401){
                    suggestedSellData.suggestedSellList = null;
                    suggestedSellData.suggestedError = '401';
                } else if (suggestedSellResponse.getStatusCode() == 404){
                    suggestedSellData.suggestedSellList = null;
                    suggestedSellData.suggestedError = '404';
                } else{
                    suggestedSellData.suggestedSellList = null;
                    suggestedSellData.suggestedError = 'Unexpected error occurred, please contact your System Administrator for support';
                    ErrorLog.insertErrorLog(suggestedSellResponse.getBody(), String.valueOf(suggestedSellResponse.getStatusCode()), 'CriticalMinuteController', 'getCriticalMinuteSuggestedData');
                }
            } else{
                suggestedSellData.suggestedSellList = null;
                suggestedSellData.suggestedError = 'External Data is missing for this Account, please contact your System Administrator for support';
            }
        } else {
            suggestedSellData.suggestedSellList = null;
            suggestedSellData.suggestedError = 'No Suggested Sell Data for this Account.';
        }
        return suggestedSellData;
    }

    /* Funnel Project begin  getting priority information from API*/
    @AuraEnabled
    public static PriorityListDataWrapper getpriorityListData(String recordId, String productSelectValue){
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        PriorityListDataWrapper priorityListData = new PriorityListDataWrapper();
        priorityListData.controllable = accountList[0].Controllable__c;
        priorityListData.onprem = accountList[0].Premise__c;
        MandateHelp mandateHelp = new MandateHelp();
        Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('Warehouse_Availability_Help');
        mandateHelp.warehouseAvail = ms.Value__c;
        ms = Mandate_Setting__mdt.getInstance('On_Hand_Inventory_Help');
        mandateHelp.OnHandInv = ms.Value__c;
        ms = Mandate_Setting__mdt.getInstance('New_Mandate_Help');
        mandateHelp.NewMandate = ms.Value__c;
        
        if (accountList[0].VIP_Instance__c != null && accountList[0].VIP_Account_Number__c != null){
            //make a call with new priorityList API            
            String param1= accountList[0].ExternalId__c +'/priority-product';
            HttpResponse priorityListResponse = MulesoftUtility.mulesoftCallout('priorityList', param1, accountList[0].VIP_Account_Number__c.leftPad(5, '0'), null, null);
            
            String body = priorityListResponse.getBody();
            if (priorityListResponse.getStatusCode() == 200){
                
                priorityListData.priorityList = handlePriorityListData(priorityListResponse, accountList[0], productSelectValue, recordId);
            } else if (priorityListResponse.getStatusCode() == 400){
                priorityListData.priorityList = null;
                priorityListData.priorityListError = '400';
            } else if (priorityListResponse.getStatusCode() == 401){
                priorityListData.priorityList = null;
                priorityListData.priorityListError = '401';
            } else if (priorityListResponse.getStatusCode() == 404){
                priorityListData.priorityList = null;
                priorityListData.priorityListError = '404';
            } else{
                priorityListData.priorityList = null;
                priorityListData.priorityListError = 'Unexpected error occurred, please contact your System Administrator for support';
                ErrorLog.insertErrorLog(priorityListResponse.getBody(), String.valueOf(priorityListResponse.getStatusCode()), 'CriticalMinuteController', 'getCriticalMinuteMandateData');
            }
        } else{
            priorityListData.priorityList = null;
            priorityListData.priorityListError = 'External Data is missing for this Account, please contact your System Administrator for support';
        }
        
        return priorityListData;
    }
    //Funnel Project end
    
    @AuraEnabled
    public static MandateDataWrapper getCriticalMinuteMandateData(String recordId, String productSelectValue){
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        MandateDataWrapper mandateData = new MandateDataWrapper();
        mandateData.controllable = accountList[0].Controllable__c;
        mandateData.onprem = accountList[0].Premise__c;

        //Get the Help Text from the Custom Metadata
        MandateHelp mandateHelp = new MandateHelp();
        Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('Warehouse_Availability_Help');
        mandateHelp.warehouseAvail = ms.Value__c;
        ms = Mandate_Setting__mdt.getInstance('On_Hand_Inventory_Help');
        mandateHelp.OnHandInv = ms.Value__c;
        ms = Mandate_Setting__mdt.getInstance('New_Mandate_Help');
        mandateHelp.NewMandate = ms.Value__c;
        mandateData.helpText = mandateHelp;
        
        
        if (accountList[0].VIP_Instance__c != null && accountList[0].VIP_Account_Number__c != null){
            HttpResponse mandateResponse = MulesoftUtility.mulesoftCallout('Mandates', accountList[0].VIP_Instance__c, accountList[0].VIP_Account_Number__c.leftPad(5, '0'), null, null);
            if (mandateResponse.getStatusCode() == 200){
                mandateData.mandateList = handleMandateData(mandateResponse, accountList[0], productSelectValue, recordId);
            } else if (mandateResponse.getStatusCode() == 400){
                mandateData.mandateList = null;
                mandateData.mandateError = '400';
            } else if (mandateResponse.getStatusCode() == 401){
                mandateData.mandateList = null;
                mandateData.mandateError = '401';
            } else if (mandateResponse.getStatusCode() == 404){
                mandateData.mandateList = null;
                mandateData.mandateError = '404';
            } else{
                mandateData.mandateList = null;
                mandateData.mandateError = 'Unexpected error occurred, please contact your System Administrator for support';
                ErrorLog.insertErrorLog(mandateResponse.getBody(), String.valueOf(mandateResponse.getStatusCode()), 'CriticalMinuteController', 'getCriticalMinuteMandateData');
            }
        } else{
            mandateData.mandateList = null;
            mandateData.mandateError = 'External Data is missing for this Account, please contact your System Administrator for support';
        }

        return mandateData;
    }

    @AuraEnabled
    public static void completeTask(Task taskObj){
        taskObj.Status = 'Completed';
        TaskDAO.updateTasks(new List<Task>{taskObj});
    }

    @AuraEnabled
    public static List<SelectDetails> getRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordTypes = Task.SObjectType.getDescribe().getRecordTypeInfos();
        List<SelectDetails> recordTypeList = new List<SelectDetails>();
        for (RecordTypeInfo recordType : recordTypes){
            if (recordType.getName() != 'Master'){
                if (recordType.isAvailable()){
                    SelectDetails selectOptionObj = new SelectDetails();
                    selectOptionObj.label = recordType.getName();
                    selectOptionObj.value = recordType.getName();
                    recordTypeList.add(selectOptionObj);
                }
            }
        }
        return recordTypeList;
    }

    @AuraEnabled
    public static TaskDetails getRecTypeId(String recordTypeName){
        TaskDetails taskDetailsObj = new TaskDetails();
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        taskDetailsObj.recordTypeId = recordTypeId;

        List<SelectDetails> priorityList = new List<SelectDetails>();
        Schema.DescribeFieldResult priorityFieldResult = Task.Priority.getDescribe();
        List<Schema.PicklistEntry> priorityFieldList = priorityFieldResult.getPicklistValues();
        for (Schema.PicklistEntry prioVal : priorityFieldList){
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = prioVal.getLabel();
            selectOptionObj.value = prioVal.getValue();
            priorityList.add(selectOptionObj);
        }
        taskDetailsObj.priorityOptions = priorityList;

        List<SelectDetails> statusList = new List<SelectDetails>();
        Schema.DescribeFieldResult statusFieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> statusFieldList = statusFieldResult.getPicklistValues();
        for (Schema.PicklistEntry statusVal : statusFieldList){
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = statusVal.getLabel();
            selectOptionObj.value = statusVal.getValue();
            statusList.add(selectOptionObj);
        }
        taskDetailsObj.statusOptions = statusList;

        List<SelectDetails> salesPointerList = new List<SelectDetails>();
        Schema.DescribeFieldResult salesPointerFieldResult = Task.Sales_Pointer__c.getDescribe();
        List<Schema.PicklistEntry> salesPointerFieldList = salesPointerFieldResult.getPicklistValues();
        for (Schema.PicklistEntry salesPointerVal : salesPointerFieldList){
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = salesPointerVal.getLabel();
            selectOptionObj.value = salesPointerVal.getValue();
            salesPointerList.add(selectOptionObj);
        }
        taskDetailsObj.salesPointerOptions = salesPointerList;

        return taskDetailsObj;
    }

     @AuraEnabled
     public static void deleteImageOnTask(List<ContentDocument> contentDocumentIds) {
         try{
            
             Set<Id> cdIds = new Set<Id>();
             for(ContentDocument cdVar : contentDocumentIds){
                 cdIds.add(cdVar.Id);
             }
            
             List<ContentDocument> contentdocumentList = new List<ContentDocument>();
             contentdocumentList = [SELECT Id FROM ContentDocument WHERE Id =: cdIds];
             if(contentdocumentList.size() > 0){
                 delete contentdocumentList;
             }
         }catch(Exception e){
             system.debug('exception line>>'+e.getLineNumber() + 'msg>>'+e.getMessage());
         }       
     }
    
    @AuraEnabled
    public static void saveTaskObj(Task taskObj, String recordTypeId, String recordId, boolean isImageRequired, List<AccountTeamMember> lstId, string cvId){
        
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        List<Task> tasksToInsert = new List<Task>();
        Id cvIdVar;
        if(cvId != null){
            cvIdVar = [Select Id from ContentVersion where ContentDocumentId =: cvId].Id;
        }
        List<Id> UserId = new List<Id>();
        for (AccountTeamMember atm : lstId){
            UserId.add(atm.UserId);
        }

        for (Id userids : UserId) {
            Task tempTask = taskObj.clone(false, false, false, false);
            tempTask.OwnerId = userids;
            tempTask.RecordTypeId = recordTypeId;
            tempTask.Image_Id__c = cvIdVar;
            tempTask.WhatId = recordId;
            tempTask.Required_Image__c = isImageRequired;
            tasksToInsert.add(tempTask);
           
        }
        if (taskObj.OwnerId != null) {
            Task tempTask = taskObj.clone(false, false, false, false);
            tempTask.RecordTypeId = recordTypeId;
            tempTask.Image_Id__c = cvIdVar;
            tempTask.WhatId = recordId;
            tempTask.Required_Image__c = isImageRequired;
            tasksToInsert.add(tempTask);
            
        }
        
        List<Task> insertedTasks = TaskDAO.insertTasks(tasksToInsert);
        if(!insertedTasks.isEmpty() && cvId != null){
            List<ContentDocumentLink> cdlinks = [Select Id From ContentDocumentLink where ContentDocumentId =: cvId AND LinkedEntityId = :recordId];
            delete cdlinks;
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = insertedTasks[0].id;
            contentlink.ShareType = 'V';
            contentlink.ContentDocumentId = cvId;
            insert contentlink;
        }

    }

    @AuraEnabled
    public static List<AccountTeamMember> getAccountTeamMember(String accId){
        List<AccountTeamMember> accountTeamMember = AccountTeamMemberDAO.getAccountTeamMembersByAccountIds(new Set<Id>{accId});
        return accountTeamMember;
    }

    private static List<SuggestedSellDetails> handleSuggestedSellData(HTTPResponse suggestedSellResponse){
        List<SuggestedSellDetails> suggestedSellDetailsList = (List<SuggestedSellDetails>)JSON.deserialize(suggestedSellResponse.getBody(), List<SuggestedSellDetails>.class);
        String type;
        Set<String> productExternalIds = new Set<String>();
        Set<String> customerExternalIds = new Set<String>();
        List<SuggestedSellDetails> filteredSuggestedSellDetailsList = new List<SuggestedSellDetails>();
        for (SuggestedSellDetails suggestedObj : suggestedSellDetailsList){
            customerExternalIds.add(suggestedObj.customerExternalId);
            if (suggestedObj.snapshotDatetime != null){
                Date suggestedDate = Date.valueOf(suggestedObj.snapshotDatetime);
                productExternalIds.add(suggestedObj.productExternalId);
                customerExternalIds.add(suggestedObj.customerExternalId);
                filteredSuggestedSellDetailsList.add(suggestedObj);
            }
        }

        List<Account> suggestedAccountExternalList = AccountDAO.getAccountsByExternalIds(customerExternalIds);

        PriceBook2 accountPriceBook = [SELECT Id
                                       FROM PriceBook2
                                       WHERE AccountId__c = :suggestedAccountExternalList[0].Id
                                       AND Type__c != 'Pinned'][0];

        List<PricebookEntry> priceBookEntry = [SELECT ID, UnitPrice, Product2.SKU_External_Id__c, snapshotDatetime__c, Feedback__c, Feedback_Reason__c, Feedback_Comments__c
                                               FROM PricebookEntry
                                               WHERE Pricebook2Id = :accountPriceBook.Id];

        List<Product2> suggestedProductExternalList = ProductDAO.getProductByExternalIds(productExternalIds);
        //Added by Funnel Project ignore any suggested feed back information stored
        List<Product_Feedback__c> lis = [Select id,Product__c,Suggested_Feedback_Type__c from Product_Feedback__c 
                                         where account__c =: suggestedAccountExternalList[0].Id
                                         and Type__c = 'Suggested'
                                         and (Suggested_Feedback_Type__c = 'Rejected' OR
                                              Suggested_Feedback_Type__c = 'No Pitch')and
                                         Snapshot_Date__c > Today and
                                         Expiration_Date__c < Today];
        set<Id> productIdList = new Set<Id>();
        for(Product_Feedback__c pf: lis){
            productIdList.add(pf.Product__c);
        }
        
        Map<String, Product2> productDetailsMap = new Map<String, Product2>();
        Map<String, PricebookEntry> existingPriceBookEntryMap = new Map<String, PricebookEntry>();
        for (Product2 prodObj : suggestedProductExternalList){
            if(!productIdList.contains(prodObj.Id)){
            productDetailsMap.put(prodObj.SKU_External_Id__c, prodObj);
        }
            
        }
        for (PricebookEntry priceBook : priceBookEntry){
            existingPriceBookEntryMap.put(priceBook.Product2.SKU_External_Id__c, priceBook);
        }

        for (SuggestedSellDetails suggestedObj : filteredSuggestedSellDetailsList){
            if (productDetailsMap.containskey(suggestedObj.productExternalId)){
                Date productSuggestedDate = Date.valueOf(suggestedObj.snapshotDatetime);
                String source = suggestedObj.Source;
                if (source == '1'){
                    Type = 'Suggested Sell';
                } else{
                    Type = 'Hot In The Area';
                }
                
                String storystring = '';
                if (!String.isBlank(suggestedObj.story)) {

                    storystring = suggestedObj.story;
                } 

                
                suggestedObj.productId = productDetailsMap.get(suggestedObj.productExternalId).Id;
                suggestedObj.productName = productDetailsMap.get(suggestedObj.productExternalId).Name;

                if (existingPriceBookEntryMap.containskey(suggestedObj.productExternalId)){
                    PricebookEntry pbe = existingPriceBookEntryMap.get(suggestedObj.productExternalId);
                    if (pbe.snapshotDatetime__c < productSuggestedDate){
                        pbe.snapshotDatetime__c = productSuggestedDate;
                        pbe.Feedback__c = NULL;
                        pbe.Feedback_Reason__c = NULL;
                        pbe.Feedback_Comments__c = NULL;
                        pbe.Type__c = Type;
                        pbe.Story__c = storystring;
                    }
                    suggestedObj.feedBack = pbe.Feedback__c;
                    suggestedObj.feedBackReason = pbe.Feedback_Reason__c;
                    suggestedObj.feedBackComments = pbe.Feedback_Comments__c;
                    // BSSP-1046 added storystring
                    suggestedObj.story = storystring;

                } else{
                    priceBookEntry.add(new PricebookEntry(UnitPrice = 0, Pricebook2Id = accountPriceBook.Id, product2Id = productDetailsMap.get(suggestedObj.productExternalId).Id, isActive = true, snapshotDatetime__c = productSuggestedDate, Type__c = type, Story__c = storystring));
                }
            }
        }
        try {
            // Funnel Project as per funnel project not storing feedback data into pricebookEntry, going fwd it's stored in Product_Feedback__c
            
            //  upsert priceBookEntry;

        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        return filteredSuggestedSellDetailsList;
    }

    
    //Funnel Project begin Handle priority list api response   
    
    public static List<PriorityListDisplayDetails> handlePriorityListData(HTTPResponse priorityListResponse, Account accountMandate, String productSelectValue, String recordId) {
        
        String priorityListResponseBody = priorityListResponse.getBody(); 
        PriorityProductsWrapper priorityProdWrapperObj = (PriorityProductsWrapper)JSON.deserialize(priorityListResponseBody, PriorityProductsWrapper.class);
        List<PriorityProductsWrapper.priorityProducts> priorityListDetailsList = priorityProdWrapperObj.priorityProducts;
     
        Date todaysDate = Date.today();
        //Get the Mandate Number of Days to consider as new from the Custom Settings
        Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('New_Number_of_Days');
        
        List<Product_Feedback__c> listProdFeed = [SELECT Id, Product__r.Id FROM Product_Feedback__c 
                                                                            WHERE Type__c = 'Suggested Sell' AND Account__c = :accountMandate.Id
                                                                            and (Suggested_Feedback_Type__c = 'Rejected' OR
                                                                                 Suggested_Feedback_Type__c = 'No Pitch')];
        Set<Id> prodFeedIds = new Set<Id>();
        for (Product_Feedback__c pf : listProdFeed) {
            prodFeedIds.add(pf.Product__r.Id);
        }
        
        List<PriorityListDisplayDetails> priorityListDisplayDetailsList = new List<PriorityListDisplayDetails>();

        List<PriorityProductsWrapper.priorityProducts> filteredPriorityListDetailsList = new List<PriorityProductsWrapper.priorityProducts>();
        Set<String> priorityProductExternalIds = new Set<String>();
        Set<String> prioritySubBrandExternalIds = new Set<String>();
        Set<String> priorityBrandExternalIds = new Set<String>();
        Set<String> prioritySkuExternalIds = new Set<String>();
        for (PriorityProductsWrapper.priorityProducts priorityListObj : PriorityListDetailsList){
            // ignore/filter priorityType of “Chain Mandate” 
            if(priorityListObj.priorityType != 'Chain Mandate'){
                filteredPriorityListDetailsList.add(priorityListObj);
                if(priorityListObj.mandateLevel == 'Subbrand'){
                    prioritySubBrandExternalIds.add(priorityListObj.productSubbrandId);
                }else if(priorityListObj.mandateLevel == 'Brand'){
                    priorityBrandExternalIds.add(priorityListObj.productBrandId);
                }
                else if(priorityListObj.productExternalId != null && priorityListObj.productExternalId > 0){
                    priorityProductExternalIds.add(String.valueOf(priorityListObj.productExternalId));
                }else  if(priorityListObj.productSubbrandId != null ){
                    prioritySubBrandExternalIds.add(String.valueOf(priorityListObj.productSubbrandId));
                }else if(priorityListObj.productBrandId != null ){
                    priorityBrandExternalIds.add(String.valueOf(priorityListObj.productBrandId));
                }
            }
        }
        
        Id subBrandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
        Id brandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();

        
    
    Set<String> customerExternalIds = new Set<String>();
    customerExternalIds.add(priorityProdWrapperObj.customerExternalId);
    List<Account> suggestedAccountExternalList = AccountDAO.getAccountsByExternalIds(customerExternalIds); //check this before getting all the accounts
    List<Product2> suggestedProductExternalList = ProductDAO.getProductByExternalIds(priorityProductExternalIds);
    List<Product2> subdProductExternalList = ProductDAO.getSubBrandByBrandExternalIds(prioritySubBrandExternalIds,subBrandRecordTypeId);
    List<Product2> brandProductExternalList = ProductDAO.getBrandByBrandExternalIds(priorityBrandExternalIds,BrandRecordTypeId);

    Map<String, Product2> suggestedproductDetailsMap = new Map<String, Product2>();
    Map<String, Product2> subbrandproductDetailsMap = new Map<String, Product2>();
    Map<String, Product2> brandproductDetailsMap = new Map<String, Product2>();

    for (Product2 prodObj : suggestedProductExternalList){
        if(!prodFeedIds.contains(prodObj.Id)){
            suggestedproductDetailsMap.put(prodObj.SKU_External_Id__c, prodObj);
        }
    }

    for (Product2 prodObj : subdProductExternalList){
        if(!prodFeedIds.contains(prodObj.Id)){
            subbrandproductDetailsMap.put(prodObj.Subbrand_External_Id__c, prodObj);
        }
    }

    for (Product2 prodObj : brandProductExternalList){
        if(!prodFeedIds.contains(prodObj.Id)){
            brandproductDetailsMap.put(prodObj.Brand_External_Id__c, prodObj);
        }
    }

    //prepare priorty product list to display
            
    for (PriorityProductsWrapper.priorityProducts filteredPriorityListObj : filteredPriorityListDetailsList) {
        
        PriorityListDisplayDetails priorityListDisplayDetailsObj = new PriorityListDisplayDetails();
        if (suggestedproductDetailsMap.containskey(String.valueOf(filteredPriorityListObj.productExternalId))){
            ProductDetails productDetailsObj = new ProductDetails();						       
            productDetailsObj.itemNumber = String.valueOf(String.valueOf(filteredPriorityListObj.productExternalId));
            productDetailsObj.id = suggestedproductDetailsMap.get(String.valueOf(filteredPriorityListObj.productExternalId)).Id;                        
            productDetailsObj.name = suggestedproductDetailsMap.get(String.valueOf(filteredPriorityListObj.productExternalId)).Name;
            productDetailsObj.discontinued = false;
            priorityListDisplayDetailsObj.product1 = productDetailsObj;   
        }else if (subbrandproductDetailsMap.containskey(String.valueOf(filteredPriorityListObj.productSubbrandId))){
            ProductDetails productDetailsObj = new ProductDetails();						       
            productDetailsObj.itemNumber = String.valueOf(String.valueOf(filteredPriorityListObj.productExternalId));
            productDetailsObj.id = subbrandproductDetailsMap.get(String.valueOf(filteredPriorityListObj.productSubbrandId)).Id;                        
            productDetailsObj.name = subbrandproductDetailsMap.get(String.valueOf(filteredPriorityListObj.productSubbrandId)).Name;
            productDetailsObj.discontinued = false;
            priorityListDisplayDetailsObj.product1 = productDetailsObj;   
                            
        }else if (brandproductDetailsMap.containskey(String.valueOf(filteredPriorityListObj.productBrandId))){
            ProductDetails productDetailsObj = new ProductDetails();						       
            productDetailsObj.itemNumber = String.valueOf(String.valueOf(filteredPriorityListObj.productExternalId));
            productDetailsObj.id = brandproductDetailsMap.get(String.valueOf(filteredPriorityListObj.productBrandId)).Id;                        
            productDetailsObj.name = brandproductDetailsMap.get(String.valueOf(filteredPriorityListObj.productBrandId)).Name;
            productDetailsObj.discontinued = false;
            priorityListDisplayDetailsObj.product1 = productDetailsObj;   
                            
        }  else{
            priorityListDisplayDetailsObj.product1 = null;
        }

        if(filteredPriorityListObj.productContainerType != null){
            PriorityListDisplayDetailsObj.containerType = filteredPriorityListObj.productContainerType;
        }
        
        if(filteredPriorityListObj.suggestionScore != null){
            PriorityListDisplayDetailsObj.suggestionScore = filteredPriorityListObj.suggestionScore;
        }
        if(filteredPriorityListObj.productWarehouseAvailableQty != null){
            //Warehouse Availability
            PriorityListDisplayDetailsObj.warehouseAvailableQty = String.valueOf(filteredPriorityListObj.productWarehouseAvailableQty);
        }
        //On Hand Inventory
        if (filteredPriorityListObj.productOnHandQty == null) {
            PriorityListDisplayDetailsObj.onHandQty = 'N/A';
        } else if (Decimal.valueOf(filteredPriorityListObj.productOnHandQty) < 0) {
            PriorityListDisplayDetailsObj.onHandQty = '0';
        } else {
            PriorityListDisplayDetailsObj.onHandQty = String.valueof(filteredPriorityListObj.productOnHandQty);
        }
        
        Date suggestedDate  = null;
        String suggestedDatestr = null;
        
        if(filteredPriorityListObj.suggestionDatetime != null){
            String sd1 = filteredPriorityListObj.suggestionDatetime+'.000Z';
            list<String> d2 = sd1.split('-');
            String strdate = d2[1]+'/'+d2[2].left(2)+'/'+d2[0]; 
            suggestedDate = Date.parse(strdate);
            Datetime dt = (Datetime)suggestedDate; 
            suggestedDatestr = dt.format('MM/dd/yyyy');
        }
        
        Date invoiceDate  = null;
        String invoiceDateStr = null;
        if(filteredPriorityListObj.productInvoiceDate != null){
            String d1 = filteredPriorityListObj.productInvoiceDate+'.000Z';
            list<String> d2 = d1.split('-');
            String strdate = d2[1]+'/'+d2[2].left(2)+'/'+d2[0]; 
            invoiceDate = Date.parse(strdate);
            Datetime dt = (Datetime)invoiceDate; 
            invoiceDateStr = dt.format('MM/dd/yyyy');
        }

        if(invoiceDateStr != null){
            PriorityListDisplayDetailsObj.lastInvoicedDate = invoiceDateStr;
        }    
        PriorityListDisplayDetailsObj.productType = filteredPriorityListObj.priorityType;
        if(filteredPriorityListObj.priorityType != null){
            PriorityListDisplayDetailsObj.prodType = filteredPriorityListObj.priorityType == 'Controllable Core Product'?'ZControllable Core Product':filteredPriorityListObj.priorityType;
        }
        
        if(filteredPriorityListObj.suggestionStory != null){
            PriorityListDisplayDetailsObj.suggestionStory = filteredPriorityListObj.suggestionStory;
        }
            
        // add to list if all products aren't null
        if (PriorityListDisplayDetailsObj.product1 != null){
            //Set the row ID used in the row action and passed to the flow
            PriorityListDisplayDetailsObj.Id = PriorityListDisplayDetailsObj.product1.id + ':' + recordId;
            if (!prodfeedIds.contains(PriorityListDisplayDetailsObj.product1.id) ) {
                priorityListDisplayDetailsList.add(PriorityListDisplayDetailsObj);
            }
        }
                
    }
        priorityListDisplayDetailsList.sort();
        return priorityListDisplayDetailsList;
}   
    //Funnel Project end
    
    
    private static List<MandateDisplayDetails> handleMandateData(HTTPResponse mandateResponse, Account accountMandate, String productSelectValue, String recordId) {
        String mandateResponseBody = mandateResponse.getBody().replace('"desc":', '"desc_x":');
        List<MandateDetails> mandateDetailsList = (List<MandateDetails>)JSON.deserialize(mandateResponseBody, List<MandateDetails>.class);
        Date todaysDate = Date.today();
        //Get the Mandate Number of Days to consider as new from the Custom Settings
        Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('New_Number_of_Days');
        //Create a List of Out of Territory Mandate Products for this Account
        List<Product_Feedback__c> listProdFeed = [SELECT Id, Product__r.Id FROM Product_Feedback__c WHERE Type__c = 'Mandate' AND Account__c = :accountMandate.Id];
        Set<Id> prodFeedIds = new Set<Id>();
        for (Product_Feedback__c pf : listProdFeed) {
            prodFeedIds.add(pf.Product__r.Id);
        }
        List<MandateDetails> filteredMandateDetailsList = new List<MandateDetails>();
        Set<String> mandateProductExternalIds = new Set<String>();
        Set<String> mandateSubBrandExternalIds = new Set<String>();
        Set<String> mandateBrandExternalIds = new Set<String>();
        for (MandateDetails mandateObj : mandateDetailsList){
            if (mandateObj.openGapInd == 'TRUE') {
                if (todaysDate >= mandateObj.startDate && todaysDate <= mandateObj.endDate){
                    filteredMandateDetailsList.add(mandateObj);
                    if (mandateObj.product1 != null){
                        if (mandateObj.product1.id != '0'){
                            mandateProductExternalIds.add(mandateObj.product1.id);
                        } else if (mandateObj.product1.subBrand.id != '0'){
                            mandateSubBrandExternalIds.add(mandateObj.product1.subBrand.id + '*' + mandateObj.product1.productDomainCd1);
                        } else{
                            mandateBrandExternalIds.add(mandateObj.product1.brand.id + '*' + mandateObj.product1.productDomainCd1);
                        }
                    }
                    if (mandateObj.product2 != null){
                        if (mandateObj.product2.id != '0'){
                            mandateProductExternalIds.add(mandateObj.product2.id);
                        } else if (mandateObj.product2.subBrand.id != '0'){
                            mandateSubBrandExternalIds.add(mandateObj.product2.subBrand.id + '*' + mandateObj.product2.productDomainCd2);
                        } else{
                            mandateBrandExternalIds.add(mandateObj.product2.brand.id + '*' + mandateObj.product2.productDomainCd2);
                        }
                    }
                    if (mandateObj.product3 != null){
                        if (mandateObj.product3.id != '0'){
                            mandateProductExternalIds.add(mandateObj.product3.id);
                        } else if (mandateObj.product3.subBrand.id != '0'){
                            mandateSubBrandExternalIds.add(mandateObj.product3.subBrand.id + '*' + mandateObj.product3.productDomainCd3);
                        } else{
                            mandateBrandExternalIds.add(mandateObj.product3.brand.id + '*' + mandateObj.product3.productDomainCd3);
                        }
                    }
                    if (mandateObj.product4 != null){
                        if (mandateObj.product4.id != '0'){
                            mandateProductExternalIds.add(mandateObj.product4.id);
                        } else if (mandateObj.product4.subBrand.id != '0'){
                            mandateSubBrandExternalIds.add(mandateObj.product4.subBrand.id + '*' + mandateObj.product4.productDomainCd4);
                        } else{
                            mandateBrandExternalIds.add(mandateObj.product4.brand.id + '*' + mandateObj.product4.productDomainCd4);
                        }
                    }
                }
            }
        }

        WCDCBSWrapper wcdCBSWrapperObject = getWCDCBSData(recordId, productSelectValue);
        List<Product2> mandateProductExternalList = new List<Product2>();
        if (wcdCBSWrapperObject.salesPointersList.size() > 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ){
            mandateProductExternalList = ProductDAO.getProductByExternalIdsCBS(mandateProductExternalIds, wcdCBSWrapperObject.salesPointersList);
        } else if (wcdCBSWrapperObject.salesPointersList.size()== 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ) {
            mandateProductExternalList = new List<Product2>();
        } else {
            mandateProductExternalList = ProductDAO.getProductByExternalIds(mandateProductExternalIds);
        }
        Map<String, Product2> mandateProductDetailsMap = new Map<String, Product2>();
        List<String> accountTerritories = accountMandate.Territories__c.split(',');
        for (Product2 mandateProdObj : mandateProductExternalList){
            Boolean skuTerritoryMatch = false;
            if (mandateProdObj.Territories__c != null){
                List<String> productTerritories = mandateProdObj.Territories__c.split(',');
                for (String territory : productTerritories){
                    if (accountTerritories.contains(territory)){
                        skuTerritoryMatch = true;
                        break;
                    }
                }
                if (skuTerritoryMatch && mandateProdObj.isActive == true){
                    mandateProductDetailsMap.put(mandateProdObj.SKU_External_Id__c, mandateProdObj);
                }
            }
        }

        List<Product2> mandateBrandExternalList = new List<Product2>();
        if (wcdCBSWrapperObject.salesPointersList.size() > 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ){
            mandateBrandExternalList = ProductDAO.getProductByBrandExternalIdsCBS(mandateBrandExternalIds, wcdCBSWrapperObject.salesPointersList);
        } else if (wcdCBSWrapperObject.salesPointersList.size()== 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ) {
            mandateBrandExternalList = new List<Product2>();
        } else {
            mandateBrandExternalList = ProductDAO.getProductByBrandExternalIds(mandateBrandExternalIds);
        }

        Map<String, Product2> mandateBrandDetailsMap = new Map<String, Product2>();
        Map<String, Set<String>> productTerritoriesMap = new Map<String, Set<String>>();
        for (Product2 mandateProdObj : mandateBrandExternalList){
            Set<String> prodTerrSet = new Set<String>();
            if (mandateProdObj.Territories__c != null){
                if (productTerritoriesMap.containsKey(mandateProdObj.Brandid__r.Brand_External_Id__c)){
                    prodTerrSet = productTerritoriesMap.get(mandateProdObj.Brandid__r.Brand_External_Id__c);
                }

                List<String> objProdTerrSplit = mandateProdObj.Territories__c.split(',');
                for (String terr : objProdTerrSplit){
                    prodTerrSet.add(terr);
                }
                productTerritoriesMap.put(mandateProdObj.Brandid__r.Brand_External_Id__c, prodTerrSet);
            }
        }
        Id brandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
        for (Product2 mandateProdObj : mandateBrandExternalList){
            if (mandateProdObj.RecordTypeId == brandRecordTypeId){
                Boolean brandTerritoryMatch = false;
                if (productTerritoriesMap.containsKey(mandateProdObj.Brand_External_Id__c)){
                    List<String> productTerritories = new List<String>(productTerritoriesMap.get(mandateProdObj.Brand_External_Id__c));
                    for (String territory : productTerritories){
                        if (accountTerritories.contains(territory)){
                            brandTerritoryMatch = true;
                            break;
                        }
                    }
                }
                if (brandTerritoryMatch && mandateProdObj.isActive == true){
                    mandateBrandDetailsMap.put(mandateProdObj.Brand_External_Id__c, mandateProdObj);
                }
            }
        }

        List<Product2> mandateSubBrandExternalList = new List<Product2>();
        if (wcdCBSWrapperObject.salesPointersList.size() > 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ){
            mandateSubBrandExternalList = ProductDAO.getProductBySubBrandExternalIdsCBS(mandateSubBrandExternalIds, wcdCBSWrapperObject.salesPointersList);
        } else if (wcdCBSWrapperObject.salesPointersList.size()== 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ) {
            mandateSubBrandExternalList = new List<Product2>();
        } else {
            mandateSubBrandExternalList = ProductDAO.getProductBySubBrandExternalIds(mandateSubBrandExternalIds);
        }

        Map<String, Product2> mandateSubBrandDetailsMap = new Map<String, Product2>();
        Map<String, Set<String>> productSubBrandTerritoriesMap = new Map<String, Set<String>>();
        for (Product2 mandateProdObj : mandateSubBrandExternalList){
            Set<String> prodTerrSet = new Set<String>();
            if (mandateProdObj.Territories__c != null){
                if (productSubBrandTerritoriesMap.containsKey(mandateProdObj.Subbrandid__r.Subbrand_External_Id__c)){
                    prodTerrSet = productSubBrandTerritoriesMap.get(mandateProdObj.Subbrandid__r.Subbrand_External_Id__c);
                }
                List<String> objProdTerrSplit = mandateProdObj.Territories__c.split(',');
                for (String terr : objProdTerrSplit){
                    prodTerrSet.add(terr);
                }
                productSubBrandTerritoriesMap.put(mandateProdObj.Subbrandid__r.Subbrand_External_Id__c, prodTerrSet);
            }
        }
        Id subBrandRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
        for (Product2 mandateProdObj : mandateSubBrandExternalList){
            if (mandateProdObj.RecordTypeId == subBrandRecordTypeId){
                Boolean subBrandTerritoryMatch = false;
                if (productSubBrandTerritoriesMap.containsKey(mandateProdObj.Subbrand_External_Id__c)){
                    List<String> productSubBrandTerritories = new List<String>(productSubBrandTerritoriesMap.get(mandateProdObj.Subbrand_External_Id__c));
                    for (String territory : productSubBrandTerritories){
                        if(accountTerritories.contains(territory)){
                            subBrandTerritoryMatch = true;
                            break;
                        }
                    }
                }
                if (subBrandTerritoryMatch && mandateProdObj.isActive == true){
                    mandateSubBrandDetailsMap.put(mandateProdObj.Subbrand_External_Id__c, mandateProdObj);
                }
            }
        }

        List<MandateDisplayDetails> mandateDisplayDetailsList = new List<MandateDisplayDetails>();
        for (MandateDetails filteredMandateObj : filteredMandateDetailsList) {
            MandateDisplayDetails mandateDisplayDetailsObj = new MandateDisplayDetails();
            Set<String> containerTypes = new Set<String>();
            List<Date> invoiceDates = new List<Date>();
            if (filteredMandateObj.product1 != null){
                if (filteredMandateObj.product1.id != '0'){
                    if (mandateProductDetailsMap.containskey(filteredMandateObj.product1.id)){
                        ProductDetails productDetailsObj = new ProductDetails();                               
                        productDetailsObj.itemNumber = filteredMandateObj.product1.id;
                        productDetailsObj.id = mandateProductDetailsMap.get(filteredMandateObj.product1.id).Id;                        
                        productDetailsObj.name = mandateProductDetailsMap.get(filteredMandateObj.product1.id).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product1 = productDetailsObj;                        
                        containerTypes.add(filteredMandateObj.product1.container);
                        invoiceDates.add(filteredMandateObj.product1.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product1 = null;
                    }
                } else if (filteredMandateObj.product1.subBrand.id != '0'){
                    if (mandateSubBrandDetailsMap.containskey(filteredMandateObj.product1.subbrand.id + '*' + filteredMandateObj.product1.productDomainCd1)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product1.subBrand.id;
                        productDetailsObj.id = mandateSubBrandDetailsMap.get(filteredMandateObj.product1.subbrand.id + '*' + filteredMandateObj.product1.productDomainCd1).Id;
                        productDetailsObj.name = mandateSubBrandDetailsMap.get(filteredMandateObj.product1.subbrand.id + '*' + filteredMandateObj.product1.productDomainCd1).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product1 = productDetailsObj;                        
                        containerTypes.add(filteredMandateObj.product1.container);
                        invoiceDates.add(filteredMandateObj.product1.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product1 = null;
                    }
                } else{
                    if (mandateBrandDetailsMap.containskey(filteredMandateObj.product1.brand.id + '*' + filteredMandateObj.product1.productDomainCd1)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product1.brand.id;                     
                        productDetailsObj.id = mandateBrandDetailsMap.get(filteredMandateObj.product1.brand.id + '*' + filteredMandateObj.product1.productDomainCd1).Id;
                        productDetailsObj.name = mandateBrandDetailsMap.get(filteredMandateObj.product1.brand.id + '*' + filteredMandateObj.product1.productDomainCd1).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product1 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product1.container);
                        invoiceDates.add(filteredMandateObj.product1.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product1 = null;
                    }
                }
            }
            if (filteredMandateObj.product2 != null){
                if (filteredMandateObj.product2.id != '0'){
                    if (mandateProductDetailsMap.containskey(filteredMandateObj.product2.id)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product2.id;
                        productDetailsObj.id = mandateProductDetailsMap.get(filteredMandateObj.product2.id).Id;
                        productDetailsObj.name = mandateProductDetailsMap.get(filteredMandateObj.product2.id).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product2 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product2.container);
                        invoiceDates.add(filteredMandateObj.product2.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product2 = null;
                    }
                } else if (filteredMandateObj.product2.subBrand.id != '0'){
                    if (mandateSubBrandDetailsMap.containskey(filteredMandateObj.product2.subbrand.id + '*' + filteredMandateObj.product2.productDomainCd2)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product2.subbrand.id;
                        productDetailsObj.id = mandateSubBrandDetailsMap.get(filteredMandateObj.product2.subbrand.id + '*' + filteredMandateObj.product2.productDomainCd2).Id;
                        productDetailsObj.name = mandateSubBrandDetailsMap.get(filteredMandateObj.product2.subbrand.id + '*' + filteredMandateObj.product2.productDomainCd2).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product2 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product2.container);
                        invoiceDates.add(filteredMandateObj.product2.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product2 = null;
                    }
                } else{
                    if (mandateBrandDetailsMap.containskey(filteredMandateObj.product2.brand.id + '*' + filteredMandateObj.product2.productDomainCd2)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product2.brand.id;
                        productDetailsObj.id = mandateBrandDetailsMap.get(filteredMandateObj.product2.brand.id + '*' + filteredMandateObj.product2.productDomainCd2).Id;
                        productDetailsObj.name = mandateBrandDetailsMap.get(filteredMandateObj.product2.brand.id + '*' + filteredMandateObj.product2.productDomainCd2).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product2 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product2.container);
                        invoiceDates.add(filteredMandateObj.product2.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product2 = null;
                    }
                }
            }
            if (filteredMandateObj.product3 != null){
                if (filteredMandateObj.product3.id != '0'){
                    if (mandateProductDetailsMap.containskey(filteredMandateObj.product3.id)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product3.id;
                        productDetailsObj.id = mandateProductDetailsMap.get(filteredMandateObj.product3.id).Id;
                        productDetailsObj.name = mandateProductDetailsMap.get(filteredMandateObj.product3.id).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product3 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product3.container);
                        invoiceDates.add(filteredMandateObj.product3.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product3 = null;
                    }
                } else if (filteredMandateObj.product3.subBrand.id != '0'){
                    if (mandateSubBrandDetailsMap.containskey(filteredMandateObj.product3.subbrand.id + '*' + filteredMandateObj.product3.productDomainCd3)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product3.subbrand.id;
                        productDetailsObj.id = mandateSubBrandDetailsMap.get(filteredMandateObj.product3.subbrand.id + '*' + filteredMandateObj.product3.productDomainCd3).Id;
                        productDetailsObj.name = mandateSubBrandDetailsMap.get(filteredMandateObj.product3.subbrand.id + '*' + filteredMandateObj.product3.productDomainCd3).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product3 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product3.container);
                        invoiceDates.add(filteredMandateObj.product3.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product3 = null;
                    }
                } else{
                    if (mandateBrandDetailsMap.containskey(filteredMandateObj.product3.brand.id + '*' + filteredMandateObj.product3.productDomainCd3)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product3.brand.id;
                        productDetailsObj.id = mandateBrandDetailsMap.get(filteredMandateObj.product3.brand.id + '*' + filteredMandateObj.product3.productDomainCd3).Id;
                        productDetailsObj.name = mandateBrandDetailsMap.get(filteredMandateObj.product3.brand.id + '*' + filteredMandateObj.product3.productDomainCd3).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product3 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product3.container);
                        invoiceDates.add(filteredMandateObj.product3.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product3 = null;
                    }
                }
            }
            if (filteredMandateObj.product4 != null){
                if (filteredMandateObj.product4.id != '0'){
                    if (mandateProductDetailsMap.containskey(filteredMandateObj.product4.id)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product4.id;
                        productDetailsObj.id = mandateProductDetailsMap.get(filteredMandateObj.product4.id).Id;
                        productDetailsObj.name = mandateProductDetailsMap.get(filteredMandateObj.product4.id).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product4 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product4.container);
                        invoiceDates.add(filteredMandateObj.product4.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product4 = null;
                    }
                } else if (filteredMandateObj.product4.subBrand.id != '0'){
                    if (mandateSubBrandDetailsMap.containskey(filteredMandateObj.product4.subbrand.id + '*' + filteredMandateObj.product4.productDomainCd4)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product4.subbrand.id;
                        productDetailsObj.id = mandateSubBrandDetailsMap.get(filteredMandateObj.product4.subbrand.id + '*' + filteredMandateObj.product4.productDomainCd4).Id;
                        productDetailsObj.name = mandateSubBrandDetailsMap.get(filteredMandateObj.product4.subbrand.id + '*' + filteredMandateObj.product4.productDomainCd4).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product4 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product4.container);
                        invoiceDates.add(filteredMandateObj.product4.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product4 = null;
                    }
                }  else{
                    if (mandateBrandDetailsMap.containskey(filteredMandateObj.product4.brand.id + '*' + filteredMandateObj.product4.productDomainCd4)){
                        ProductDetails productDetailsObj = new ProductDetails();
                        productDetailsObj.itemNumber = filteredMandateObj.product4.brand.id;                        
                        productDetailsObj.id = mandateBrandDetailsMap.get(filteredMandateObj.product4.brand.id + '*' + filteredMandateObj.product4.productDomainCd4).Id;
                        productDetailsObj.name = mandateBrandDetailsMap.get(filteredMandateObj.product4.brand.id + '*' + filteredMandateObj.product4.productDomainCd4).Name;
                        productDetailsObj.discontinued = false;
                        mandateDisplayDetailsObj.product4 = productDetailsObj;
                        containerTypes.add(filteredMandateObj.product4.container);
                        invoiceDates.add(filteredMandateObj.product4.invoiceDate);
                    } else{
                        mandateDisplayDetailsObj.product4 = null;
                    }
                }
            }

            String containerType = '';
            for (String container : containerTypes){
                containerType += container + ',';
            }
            containerType = containerType.removeEnd(',');
            mandateDisplayDetailsObj.containerType = containerType;
            
            //Warehouse Availability
            mandateDisplayDetailsObj.warehouseAvailableQty = filteredMandateObj.warehouseAvailableQty;
            //On Hand Inventory
            if (filteredMandateObj.onHandQty == null) {
                mandateDisplayDetailsObj.onHandQty = 'N/A';
            } else if (Decimal.valueOf(filteredMandateObj.onHandQty) < 0) {
                mandateDisplayDetailsObj.onHandQty = '0';
            } else {
                mandateDisplayDetailsObj.onHandQty = filteredMandateObj.onHandQty;
            }
            //Check if this is a New Add and set the class to display the New icon          
            if (todaysDate-Integer.valueOf(ms.Value__c) <= filteredMandateObj.startDate) {          
                mandateDisplayDetailsObj.newIconClass = 'newImage';
            }            
            
            Boolean noSales = false;
            for (Date dates : invoiceDates){
                if (dates == null){
                    noSales = true;
                }
            }
            if (filteredMandateObj.product1 != null && !invoiceDates.isEmpty() && !noSales){
                invoiceDates.sort();
                mandateDisplayDetailsObj.lastInvoicedDate = DateTime.NewInstance(invoiceDates[0].year(), invoiceDates[0].month(), invoiceDates[0].day()).format('MM/dd/yy');
                mandateDisplayDetailsObj.daysSinceSale = String.valueOf(invoiceDates[0].daysBetween(System.today()));                
                //Set the sortData field so we can sort this wrapper class (Desc last)              
                if (mandateDisplayDetailsObj.onHandQty != 'N/A') {                    
                    if (mandateDisplayDetailsObj.onHandQty.contains('.')) {
                        List<String> ohq = mandateDisplayDetailsObj.onHandQty.split('\\.');
                        mandateDisplayDetailsObj.sortData = ohq[0].leftPad(6,'0') + '.' + ohq[1].rightPad(6,'0') + ':' + String.valueOf(invoiceDates[0].year()) + String.valueOf(invoiceDates[0].month()).leftPad(2,'0') + String.valueOf(invoiceDates[0].day()).leftPad(2,'0');
                    } else {
                        mandateDisplayDetailsObj.sortData = mandateDisplayDetailsObj.onHandQty.leftPad(6,'0') + '.000000:' + String.valueOf(invoiceDates[0].year()) + String.valueOf(invoiceDates[0].month()).leftPad(2,'0') + String.valueOf(invoiceDates[0].day()).leftPad(2,'0');                        
                    }
                } else {
                    mandateDisplayDetailsObj.sortData =  '000000.000000' + ':' + String.valueOf(invoiceDates[0].year()) + String.valueOf(invoiceDates[0].month()).leftPad(2,'0') + String.valueOf(invoiceDates[0].day()).leftPad(2,'0');                    
                }
            } else{
                invoiceDates.sort();
                mandateDisplayDetailsObj.lastInvoicedDate = 'No Sales last 12 Months';
                mandateDisplayDetailsObj.daysSinceSale = 'N/A';
                //Set the sortData field so we can sort this wrapper class (Desc last)
                if (mandateDisplayDetailsObj.onHandQty != 'N/A') {
                    if (mandateDisplayDetailsObj.onHandQty.contains('.')) {
                        List<String> ohq = mandateDisplayDetailsObj.onHandQty.split('\\.');
                        mandateDisplayDetailsObj.sortData = ohq[0].leftPad(6,'0') + '.' + ohq[1].rightPad(6,'0') + ':00000000';
                    } else {
                        mandateDisplayDetailsObj.sortData = filteredMandateObj.onHandQty.leftPad(6,'0') + '.000000:00000000';
                    }                 
                } else {
                    mandateDisplayDetailsObj.sortData = '000000.000000:00000000';
                }
            }
            
            // sort ProductDetails products1-4 to remove gaps
            if (mandateDisplayDetailsObj.product1 == null){
                if (mandateDisplayDetailsObj.product2 != null){
                    mandateDisplayDetailsObj.product1 = mandateDisplayDetailsObj.product2;
                    mandateDisplayDetailsObj.product2 = null;
                } else if (mandateDisplayDetailsObj.product3 != null){
                    mandateDisplayDetailsObj.product1 = mandateDisplayDetailsObj.product3;
                    mandateDisplayDetailsObj.product3 = null;
                } else if (mandateDisplayDetailsObj.product4 != null){
                    mandateDisplayDetailsObj.product1 = mandateDisplayDetailsObj.product4;
                    mandateDisplayDetailsObj.product4 = null;
                }
            }
            if (mandateDisplayDetailsObj.product2 == null){
                if (mandateDisplayDetailsObj.product3 != null){
                    mandateDisplayDetailsObj.product2 = mandateDisplayDetailsObj.product3;
                    mandateDisplayDetailsObj.product3 = null;
                } else if (mandateDisplayDetailsObj.product4 != null){
                    mandateDisplayDetailsObj.product2 = mandateDisplayDetailsObj.product4;
                    mandateDisplayDetailsObj.product4 = null;
                }
            }

            if (mandateDisplayDetailsObj.product3 == null){
                if (mandateDisplayDetailsObj.product4 != null){
                    mandateDisplayDetailsObj.product3 = mandateDisplayDetailsObj.product4;
                    mandateDisplayDetailsObj.product4 = null;
                }
            }

            // add to list if all products aren't null
            if (mandateDisplayDetailsObj.product1 != null){
                //Set the row ID used in the row action and passed to the flow
                mandateDisplayDetailsObj.Id = mandateDisplayDetailsObj.product1.id + ':' + recordId;
                //Has this product been set to Out of Territory?
                if (prodfeedIds.contains(mandateDisplayDetailsObj.product1.id)) {
                    mandateDisplayDetailsObj.outOfTerritoryIcon = 'utility:check';
                    mandateDisplayDetailsObj.outOfTerritoryText = 'Item Reported';
                    mandateDisplayDetailsObj.outOfTerritoryVariant = 'bare';
                    mandateDisplayDetailsObj.outOfTerritoryDisabled = true;
                } else {
                    mandateDisplayDetailsObj.outOfTerritoryIcon = 'utility:email';
                    mandateDisplayDetailsObj.outOfTerritoryText = 'Report Item';
                    mandateDisplayDetailsObj.outOfTerritoryVariant = 'brand';
                    mandateDisplayDetailsObj.outOfTerritoryDisabled = false;
                }
                mandateDisplayDetailsList.add(mandateDisplayDetailsObj);
            }
        }
        mandateDisplayDetailsList.sort();
        return mandateDisplayDetailsList;
    }

    @AuraEnabled
    public static List<TaskWrapper> getTask(String accountId){
        List<Display_Product__c> displayProductList = DisplayProductDAO.fetchDisplayProduct(new Set<Id>{accountId});
        List<Task> taskList = TaskDAO.getTasksByIdAndStatusForCM(new Set<Id>{accountId}, 'Open', true);
        List<TaskWrapper> taskWrapperList = new List<TaskWrapper>();
        Map<Id, Display_Product__c> displayProductMap = new Map<id, Display_Product__c>(displayProductList);

        for (Task task : taskList){
            Boolean addTask = true;
            if (task.Display_Product__c != null){
                if (task.ActivityDate < System.today()){
                    addTask = false;
                }
            }

            if (addTask){
                TaskWrapper taskWrapperObj = new TaskWrapper();
                taskWrapperObj.taskType = 'task';
                taskWrapperObj.Id = task.Id;
                taskWrapperObj.Priority = task.Priority;
                taskWrapperObj.Subject = task.Subject;
                taskWrapperObj.Description = task.Description;
                taskWrapperObj.ActivityDate = task.ActivityDate;
                taskWrapperObj.PriorityAbbreviated = task.Priority_Abbreviated__c;
                taskWrapperObj.DisplayProduct = task.Display_Product__c;
                taskWrapperObj.OwnerName = task.Owner.Name;
                taskWrapperList.add(taskWrapperObj);
            }
        }

        Boolean isFound = false;
        for (Display_Product__c displayProduct : displayProductList){
            if (displayProduct.Account__c == accountId){
                Display_Product__c display = displayProductMap.get(displayProduct.Id);
                if (display.Number_of_Cases__c == null && !isFound){
                    isFound = true;
                    TaskWrapper taskWrapperObj = new TaskWrapper();
                    taskWrapperObj.Priority = 'High';
                    taskWrapperObj.Id = display.Id;
                    taskWrapperObj.Subject = 'DSOF';
                    taskWrapperObj.taskType = 'dsof';
                    taskWrapperObj.PriorityAbbreviated = 'H';
                    taskWrapperObj.Description = 'Complete DSOF Survey';
                    taskWrapperObj.ActivityDate = display.End_Date__c;
                    taskWrapperList.add(taskWrapperObj);
                }
            }
        }

        return taskWrapperList;
    }

    @AuraEnabled(cacheable = true)
    public static List<PriceBookEntry> getPricebookEntries(String accId, String productSelectValue){
        PriceBook2 accountPriceBook = [SELECT Id
                                       FROM PriceBook2
                                       WHERE AccountId__c = :accId
                                       AND Type__c != 'Pinned'][0];

        List<PriceBookEntry> priceBookEntriesDateCheck = [SELECT Id, snapshotDatetime__c
                                                        FROM PricebookEntry
                                                        WHERE Pricebook2Id = :accountPriceBook.Id
                                                        ORDER BY snapshotDatetime__c DESC];
        List<Date> snapshotDates = new List<Date>();
        for(PriceBookEntry priceBookEntryObj : priceBookEntriesDateCheck){
            snapshotDates.add(Date.valueOf(priceBookEntryObj.snapshotDatetime__c));
        }

        Date weekStart;
        if(!snapshotDates.isEmpty()){
            weekStart = snapshotDates[0];
        } else {
            weekStart = System.today().toStartOfWeek();
        }

        WCDCBSWrapper wcdCBSWrapperObject = getWCDCBSData(accId, productSelectValue);
        if (wcdCBSWrapperObject.salesPointersList.size() > 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ){
            return [SELECT Id, Feedback__c, Feedback_Reason__c, Feedback_Comments__c, Type__c, Product2.Name, Name, Story__c
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :accountPriceBook.Id
                    AND Feedback__c NOT IN ('Rejected', 'No Pitch') 
                    AND Product2.Sales_Pointer__c IN :wcdCBSWrapperObject.salesPointersList
                    AND snapshotDatetime__c >= :weekStart];
        } else if (wcdCBSWrapperObject.salesPointersList.size()== 0 && productSelectValue == '1' && !wcdCBSWrapperObject.teamMemberRole.contains('FSR') ) {
            return new List<PricebookEntry>();
        } else {
            return [SELECT Id, Feedback__c, Feedback_Reason__c, Feedback_Comments__c, Type__c, Product2.Name, Name, Story__c
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :accountPriceBook.Id
                    AND Feedback__c NOT IN ('Rejected', 'No Pitch')
                    AND snapshotDatetime__c >= :weekStart];
        }
    }

    /* Funnel Project saving feedback information to new prodcut feedback object */
    @AuraEnabled
    public static Id sendSuggestedSellFeedbackNew(String productId,String accountId){
                                         
        //below retrive current saved record
        Product_Feedback__c pfRecord = [Select id,Account__r.ExternalId__c,Product__r.SKU_External_Id__c,Snapshot_Date__c,
                                        Expiration_date__c,Feedback__c,Suggested_Feedback_Reason__c,Product__r.Subbrand_External_Id__c,Product__r.Brand_External_Id__c
                                        from Product_Feedback__c where Account__c=: accountId and Product__c = :productId];//TODO: check here to send accountid not sure about pricebookEntryId value
        
        String feedbackComments;
        if (pfRecord.Feedback__c == null){
            feedBackComments = '';
        } else{
            feedBackComments = pfRecord.Feedback__c;
        }
        
        String accountExternalId = pfRecord.Account__r.ExternalId__c;
        Integer productExternalId = 0;    

        if(pfRecord.Product__r.SKU_External_Id__c != null){
            productExternalId = integer.valueof(pfRecord.Product__r.SKU_External_Id__c);
        }else if(pfRecord.Product__r.Subbrand_External_Id__c != null){
            productExternalId = integer.valueof(pfRecord.Product__r.Subbrand_External_Id__c);
        }else if(pfRecord.Product__r.Brand_External_Id__c != null){
            productExternalId = integer.valueof(pfRecord.Product__r.Brand_External_Id__c);
        }
          
        Datetime temp = pfRecord.Snapshot_Date__c;
        Integer formattedSnapShotDateTime = integer.valueof(temp.format('yyyyMMdd'));
        Long formattedSubmissionTime = long.valueof(DateTime.now().format('yyyyMMddhhmmss'));
        JSONGenerator suggestedSellJSON = JSON.createGenerator(true);
        suggestedSellJSON.writeStartObject();
        suggestedSellJSON.writeNumberField('suggestionDateSID', formattedSnapShotDateTime);
        suggestedSellJSON.writeStringField('customerID', accountExternalId);
        suggestedSellJSON.writeNumberField('productID', productExternalId);
        suggestedSellJSON.writeNumberField('feedbackCD', Integer.ValueOf(pfRecord.Suggested_Feedback_Reason__c));
        suggestedSellJSON.writeStringField('comment', feedbackComments);
        suggestedSellJSON.writeNumberField('timestamp', formattedSubmissionTime);
        String jsonString = suggestedSellJSON.getAsString();
        if(!Test.isRunningTest()){
            HttpResponse suggestedSellFeedback = MulesoftUtility.mulesoftCallout('Suggested Sell Feedback', null, null, null, jsonString);
        }
        return pfRecord.id;
    }
    /* Funnel Project */
    
    @AuraEnabled
    public static Id sendSuggestedSellFeedback(String priceBookEntryId){
        PricebookEntry priceBookEntry = [SELECT Feedback_Reason__c, Feedback_Comments__c, snapshotDatetime__c, Type__c, Pricebook2.AccountId__r.ExternalId__c, Product2.SKU_External_Id__c
                                         FROM PricebookEntry
                                         WHERE Id = :priceBookEntryId];

        String feedbackComments;
        if (priceBookEntry.Feedback_Comments__c == null){
            feedBackComments = '';
        } else{
            feedBackComments = priceBookEntry.Feedback_Comments__c;
        }

        String accountExternalId = priceBookEntry.Pricebook2.AccountId__r.ExternalId__c;
        Integer productExternalId = integer.valueof(priceBookEntry.Product2.SKU_External_Id__c);
        Integer formattedSnapShotDateTime = integer.valueof(priceBookEntry.snapshotDatetime__c.format('yyyyMMdd'));
        Long formattedSubmissionTime = long.valueof(DateTime.now().format('yyyyMMddhhmmss'));
        JSONGenerator suggestedSellJSON = JSON.createGenerator(true);
        suggestedSellJSON.writeStartObject();
        suggestedSellJSON.writeNumberField('suggestionDateSID', formattedSnapShotDateTime);
        suggestedSellJSON.writeStringField('customerID', accountExternalId);
        suggestedSellJSON.writeNumberField('productID', productExternalId);
        if(!Test.isRunningTest()){
            suggestedSellJSON.writeNumberField('feedbackCD', Integer.ValueOf(priceBookEntry.Feedback_Reason__c));
        }
        suggestedSellJSON.writeStringField('comment', feedbackComments);
        suggestedSellJSON.writeNumberField('timestamp', formattedSubmissionTime);
        String jsonString = suggestedSellJSON.getAsString();
        if(!Test.isRunningTest()){
        	HttpResponse suggestedSellFeedback = MulesoftUtility.mulesoftCallout('Suggested Sell Feedback', null, null, null, jsonString);
        }
        return priceBookEntry.id;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, List<Option>> suggestedSellPicklistValues() {
        Map<String, List<Option>> valueMap = new Map<String, List<Option>>();
        valueMap.put('Rejected', new List<Option>{new Option('Already Carries Brand (On-Premise)', '1'), new Option('Previously Carried SKU', '2'), new Option('Viable opportunity / keep on list', '3')});
        valueMap.put('No Pitch', new List<Option>{new Option('Suggestion not viable for account', '4'), new Option('Wrong Package Type', '5'), new Option('Comments', '6')});

        return valueMap;
    }

    /* Funnel Project Begin get product feedback infromation for product feed object*/

    @AuraEnabled
    public static Product_Feedback__c getProductFeedbackRecord(String accountId, String productId){
        //below retrive current saved record
        Product_Feedback__c pfRecord  = null;
        try{
            pfRecord = [Select id,Account__r.ExternalId__c,Product__r.SKU_External_Id__c,Snapshot_Date__c,
                        Expiration_date__c,Feedback__c,Suggested_Feedback_Reason__c,Suggested_Feedback_Type__c
                        from Product_Feedback__c where Account__c=: accountId and Product__c = :productId];

        }catch(Exception ex){

        }
        return pfRecord;    
    }
    



    @AuraEnabled
    public static void createFeedbackRecord(String accountId,String feedbackComments,String feedbackType, String feedbackReason , String productId, String prodType){
        Product_Feedback__c newProductFeedback = getProductFeedbackRecord(accountId,productId);
        boolean isfeedbackRecordExists = false;
        
        if(newProductFeedback != null){
            isfeedbackRecordExists = true;
        }else{
            newProductFeedback = new Product_Feedback__c();
        }
        
        newProductFeedback.Account__c = accountId;
        newProductFeedback.Expiration_Date__c = System.today();
        newProductFeedback.Feedback__c = feedbackComments;
        if(feedbackType == 'Rejected' || feedbackType == 'No Pitch'){
            newProductFeedback.IsHidden__c = true;
        }else{
            newProductFeedback.IsHidden__c = false;
        }
        newProductFeedback.Product__c = productId;
        newProductFeedback.Type__c = prodType; 
        newProductFeedback.Snapshot_Date__c = System.today();
        newProductFeedback.Suggested_Feedback_Type__c = feedbackType;
        newProductFeedback.Suggested_Feedback_Reason__c = feedbackReason;
        newProductFeedback.Expiration_Date__c = system.today() +30;

        if(isfeedbackRecordExists){
            update newProductFeedback;
        }else{
            insert newProductFeedback;
        }
        
    }


    /* Funnel Project end */
    
    @AuraEnabled
    public static void updatePriceBookEntry(Id pricebookentryid, String feedbackreason, String comment, String feedback) {
        PricebookEntry PBE = new PricebookEntry(Id = pricebookentryid, Feedback_Reason__c = feedbackreason, Feedback_Comments__c = comment, Feedback__c = feedback);
        update PBE;
    }

    @AuraEnabled
    public static List<AlertWrapper> getAlerts(Id accountId) {
        List<Alert__c>  alertList = AlertDAO.getAlertsByAccountId(accountId);
        List<AlertWrapper> alertWrapperList = new List<AlertWrapper>();
        for(Alert__c alert : alertList){
            AlertWrapper alertWrap = new AlertWrapper();
            alertWrap.Id = alert.Id;
            alertWrap.AccountId = alert.Account__c;
            alertWrap.AlertName = alert.Name;
            alertWrap.RecordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+alert.Id;
            alertWrap.AlertMessage = alert.Alert_Message__c;
            alertWrap.isOrder = alert.Order_Alert__c;
            alertWrap.isAccount = alert.Account_Alert__c;
            alertWrap.StartDate = alert.Start_Date__c;
            alertWrap.EndDate = alert.End_Date__c;
            alertWrap.RequiresAction = alert.Requires_Action__c;
            alertWrap.Active = alert.Active__c;
            alertWrap.DueDate = alert.Due_Date__c;
            if (alert.Active__c == true) {
                alertWrapperList.add(alertWrap);
            } 
        }

        return alertWrapperList;
    }
       
    public class option{
        public option(String Label, String Value){
            this.label = label;
            this.value = value;
        }

        @AuraEnabled
        public string Label;
        @AuraEnabled
        public string Value;
    }

    @AuraEnabled
    public static WCDCBSWrapper getWCDCBSData(String accId, String productSelectValue){
        WCDCBSWrapper wcdCBSWrapperObject = new WCDCBSWrapper();
        List<Integer> salesPointer = new List<Integer>();
        List<String> salesPointerString = new List<String>();
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accId});
        List<AccountTeamMember> accountTeamMember = [SELECT Sales_Pointer__c, User.Assigned_route__c, TeamMemberRole, UserId, User.UserRole.Name
                                                     FROM AccountTeamMember
                                                     WHERE AccountId = :accId AND UserId = :UserInfo.getUserId()];

        if (accountTeamMember.size() > 0 && accountTeamMember[0].Sales_Pointer__c != null){
            salesPointerString = accountTeamMember[0].Sales_Pointer__c.split(';');
        }
        for (String s : salesPointerString){
            if (s != null){
                salesPointer.add(Integer.ValueOf(s));
            }
        }
        if(salesPointer != null){
            wcdCBSWrapperObject.salesPointersList = salesPointer;
        } else{
            wcdCBSWrapperObject.salesPointersList =  new List<Integer>();
        }

        if(accountTeamMember.size() > 0){
            for(AccountTeamMember atm : accountTeamMember){
                wcdCBSWrapperObject.userRole = atm.User.UserRole.Name;
                wcdCBSWrapperObject.teamMemberRole = atm.TeamMemberRole;
            }
        } else{
            wcdCBSWrapperObject.userRole = '';
            wcdCBSWrapperObject.teamMemberRole = 'FSR';
        }

        for(Account acct : accountList){
            wcdCBSWrapperObject.salesOrg = acct.VIP_Instance__c;
        }

        return wcdCBSWrapperObject;
    }

    public class CriticalMinuteWrapper{
        @AuraEnabled
        public List<TaskWrapper> taskList{ get; set; }

        @AuraEnabled
        public List<ObjectiveAccountWrapper> objectiveList{ get; set; }

        @AuraEnabled
        public NoteWrapper noteObj{ get; set; }

        @AuraEnabled
        public Boolean visitCompleted{ get; set; }

        @AuraEnabled
        public String chainIndependent{ get; set; }

        @AuraEnabled
        public String controllable{ get; set; }
        
        @AuraEnabled
        public PinnedProductWrapper pinnedProductDetails { get; set; }
    }

    public class ObjectiveAccountWrapper{
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public Id Objective;
        @AuraEnabled
        public String ObjectiveName;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public Date StartDate;
        @AuraEnabled
        public Date EndDate;
        @Auraenabled
        public Id RecordTypeId;
        @AuraEnabled
        public String StatusAbbrev;
        @AuraEnabled
        public Id Account;
        @AuraEnabled
        public Double NumOfOpportunites;
        @AuraEnabled
        public Double NumSubAndApp;
        @AuraEnabled
        public String flowRelation;
		@AuraEnabled	
        public String mboIconClass;	
        @AuraEnabled	
        public String completeIconClass;           
    }

    public class MandateDataWrapper{
        @AuraEnabled
        public List<MandateDisplayDetails> mandateList{ get; set; }

        @AuraEnabled
        public String mandateError{ get; set; }

        @AuraEnabled
        public String controllable{ get; set; }
        
        @AuraEnabled
        public String onprem{ get; set; }
        
        @AuraEnabled
        public MandateHelp helpText{ get; set; }
    }

    public class SuggestedSellDataWrapper{
        @AuraEnabled
        public List<SuggestedSellDetails> suggestedSellList{ get; set; }

        @AuraEnabled
        public String suggestedError{ get; set; }

        @AuraEnabled
        public String chainIndependent{ get; set; }
    }
    
    public class PinnedProductWrapper{
        @AuraEnabled
        public Boolean showPinnedProducts{ get; set; }

        @AuraEnabled
        public Integer numPinnedProducts{ get; set; }
    }

    
    public class PriorityListDataWrapper{
        @AuraEnabled
        public List<PriorityListDisplayDetails> priorityList{ get; set; }
        
        @AuraEnabled
        public String priorityListError{ get; set; }
        
        @AuraEnabled
        public String controllable{ get; set; }
        
        @AuraEnabled
        public String onprem{ get; set; }
        
        @AuraEnabled
        public MandateHelp helpText{ get; set; }
    }
    
    public class PriorityListDisplayDetails implements Comparable {
        //Data returned to the UI
        @AuraEnabled
        public String Id;
 
        @AuraEnabled
        public String productType;
        
        @AuraEnabled
        public String prodType;
        
        @AuraEnabled
        public String suggestionStory;
        
        @AuraEnabled
        public Decimal suggestionScore;
        
        @AuraEnabled
        public ProductDetails product1;
        
        @AuraEnabled
        public String containerType;
        
        @AuraEnabled
        public String lastInvoicedDate;
        @AuraEnabled
        public String onHandQty;
        @AuraEnabled
        public String warehouseAvailableQty;
        @AuraEnabled
        public String daysSinceSale;
        @AuraEnabled
        public String newIconClass;
        @AuraEnabled
        public String outOfTerritoryIcon;
        @AuraEnabled
        public String outOfTerritoryText;
        @AuraEnabled
        public String outOfTerritoryVariant;
        @AuraEnabled
        public Boolean outOfTerritoryDisabled;

      
        public String sortBy = 'prodType';

        //This is not passed to Interface, but just used to sort the wrapper
        public String sortData;
        //Comment
        
        public Integer compareTo(Object objToCompare) {
            //Sort by ProductType
            if(sortBy == 'prodType')
            {
                return prodType.compareTo(((PriorityListDisplayDetails)objToCompare).prodType);
            }
            return 0;
        }
            
    }
    //Funnel Project end changes
    
    
    public class AlertWrapper{
        @AuraEnabled public Id Id;
        @AuraEnabled public Id AccountId;
        @AuraEnabled public String AlertName;
        @AuraEnabled public String RecordLink;
        @AuraEnabled public Boolean isAccount;
        @AuraEnabled public Boolean isOrder;
        @AuraEnabled public Boolean RequiresAction;
        @AuraEnabled public String AlertMessage;
        @AuraEnabled public Date StartDate;
        @AuraEnabled public Date EndDate;
        @AuraEnabled public Boolean Active;
        @AuraEnabled public Date DueDate;
    }

    public class SuggestedSellDetails{
        @AuraEnabled
        public String customerExternalId;
        @AuraEnabled
        public String productExternalId;
        @AuraEnabled
        public String displaySequence;
        @AuraEnabled
        public String snapshotDatetime;
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String priceEntryID;
        @AuraEnabled
        public String feedBack;
        @AuraEnabled
        public String feedBackReason;
        @AuraEnabled
        public String feedBackComments;
        // BSSP-1046 Add Story from the Suggested sell response
        @AuraEnabled
        public String story;
    }

    public class MandateDetails {
        //This is data retrieved from the Mulesoft API
        public Date startDate;
        public Date endDate;
        public String openGapInd;
        public ProductDetails product1;
        public ProductDetails product2;
        public ProductDetails product3;
        public ProductDetails product4;
        public String onHandQty;
        public String warehouseAvailableQty;
        
    }

    public class ProductDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String itemNumber;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String desc_x;
        @AuraEnabled
        public Boolean discontinued;
        @AuraEnabled
        public String productDomainCd1;
        @AuraEnabled
        public String productDomainCd2;
        @AuraEnabled
        public String productDomainCd3;
        @AuraEnabled
        public String productDomainCd4;
        @AuraEnabled
        public String container;
        @AuraEnabled
        public Date invoiceDate;
        @AuraEnabled
        public BrandDetails brand;
        @AuraEnabled 
        public SubBrandDetails subBrand;
    }

    public class BrandDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String desc_x;
    }

    public class SubBrandDetails{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String desc_x;
    }

    public class MandateDisplayDetails implements Comparable {
        //Data returned to the UI
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public ProductDetails product1;
        @AuraEnabled
        public ProductDetails product2;
        @AuraEnabled
        public ProductDetails product3;
        @AuraEnabled
        public ProductDetails product4;
        @AuraEnabled
        public String containerType;
        @AuraEnabled
        public String lastInvoicedDate;
        @AuraEnabled
        public String onHandQty;
        @AuraEnabled
        public String warehouseAvailableQty;
        @AuraEnabled
        public String daysSinceSale;
        @AuraEnabled
        public String newIconClass;
        @AuraEnabled
        public String outOfTerritoryIcon;
        @AuraEnabled
        public String outOfTerritoryText;
        @AuraEnabled
        public String outOfTerritoryVariant;
        @AuraEnabled
        public Boolean outOfTerritoryDisabled;
        //This is not passed to Interface, but just used to sort the wrapper
        public String sortData;
        
        public Integer compareTo(Object instance) {
            MandateDisplayDetails that = (MandateDisplayDetails)instance;
            if (this.sortData > that.sortData) return 1;
            if (this.sortData < that.sortData) return -1;
            return 0;
        } 
    }
    
    public class MandateHelp {
        @AuraEnabled
        public String warehouseAvail;
        @AuraEnabled
        public String OnHandInv;
        @AuraEnabled
        public String NewMandate;
    }

    public class NoteWrapper {
        @AuraEnabled
        public String noteId;
        @AuraEnabled
        public String noteTitle;
        @AuraEnabled
        public String noteContent;
    }

    public class TaskWrapper{
        @AuraEnabled
        public String Priority;
        @AuraEnabled
        public String OwnerId;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String linkname;
        @AuraEnabled
        public String Subject;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public Date ActivityDate;
        @AuraEnabled
        public String taskType;
        @AuraEnabled
        public String PriorityAbbreviated;
        @AuraEnabled
        public String DisplayProduct;
        @AuraEnabled
        public String OwnerName;
    }

    public class TaskDetails{
        @AuraEnabled
        public String recordTypeId;
        @AuraEnabled
        public List<SelectDetails> priorityOptions;
        @AuraEnabled
        public List<SelectDetails> statusOptions;
        @AuraEnabled
        public List<SelectDetails> salesPointerOptions;
    }

    public class SelectDetails{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }

    public class WCDCBSWrapper{
        @AuraEnabled
        public List<Integer> salesPointersList{ get; set; }

        @AuraEnabled
        public String userRole{ get; set; }

        @AuraEnabled
        public String teamMemberRole{ get; set; }

        @AuraEnabled
        public String salesOrg{get; set;}
    }
    
    @InvocableMethod
    public static void sendMandateOutofTerritoryEmail(List<FlowInputs> req) {        
        //Send an email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setTemplateId([SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Mandate_Out_of_Territory'].Id);        
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setWhatId(req[0].recordId);
        mail.setSenderDisplayName('E360');        
        mail.setBccSender(false); 
        mail.setUseSignature(false); 
        mail.setSaveAsActivity(false);        
        Mandate_Setting__mdt ms = Mandate_Setting__mdt.getInstance('MDM_Email_Address');    
        mail.toaddresses = new String[] {ms.Value__c};
        Contact contact = new Contact(LastName='DeleteMe');  //We create a temp contact because we have to have a TargetObject if we are using an email template
        insert contact;
        mail.setTargetObjectId(contact.Id);
        if (isEmailTurnedOn()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
        }
        delete contact;          //Delete the fake contact
    }
    
    //Input variables
    public class FlowInputs {
        @InvocableVariable(label='Product Feedback Record Id')
        public String recordId;
    }
    
    public static Boolean isEmailTurnedOn() {
        try {
            Messaging.reserveSingleEmailCapacity(0);
            return true;
        } catch (System.NoAccessException e) {
            return false;        
        }
    }
    
}