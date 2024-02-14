/**
 * @description       : All processing on Objectives
 * @last modified on  : 02-01-2023
 * @last modified by  : cbraaten@reyesholdings.com
**/
public without sharing class ObjectivesController {

    //Get Objectives (Called from ObjectiveAssignmentHelper.cmp which is not currently being used but may be reinstated)
    @AuraEnabled
    public static List<ObjectiveWrapper> getObjectives(String permissionSetName, String buValue, String objectiveId) {
        List<Objective__c> objectiveList = ObjectiveDAO.getObjectives();
        Set<Id> objectiveIds = new Set<Id>();
        for (Objective__c objective : objectiveList) {
            if (objectiveId != null) {
                objectiveIds.add(objectiveId);
            } else {
                objectiveIds.add(objective.Id);
            }
        }

        List<Objective_Location__c> objectiveLocationList = new List<Objective_Location__c>();
        if (permissionSetName == 'National Objective Admin') {
            objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIds(objectiveIds);
        } else {
            objectiveLocationList = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIdsAndBU(objectiveIds, buValue);
        }

        Map<Id, List<Objective_Location__c>> objectiveLocationMap = new Map<Id, List<Objective_Location__c>>();
        for (Objective_Location__c objectiveLoc : objectiveLocationList) {
            List<Objective_Location__c> objectiveLocList = new List<Objective_Location__c>();
            if (objectiveLocationMap.containsKey(objectiveLoc.Objective__c)) {
                objectiveLocList = objectiveLocationMap.get(objectiveLoc.Objective__c);
            }
            objectiveLocList.add(objectiveLoc);
            objectiveLocationMap.put(objectiveLoc.Objective__c, objectiveLocList);
        }

        List<ObjectiveWrapper> objectiveWrapperList = new List<ObjectiveWrapper>();
        for (Objective__c obj : objectiveList) {
            if (objectiveLocationMap.containsKey(obj.Id)) {
                if (objectiveId != null) {
                    if (obj.Id == objectiveId) {
                        ObjectiveWrapper objectiveWrapperObj = new ObjectiveWrapper();
                        objectiveWrapperObj.Id = obj.Id;
                        objectiveWrapperObj.Name = obj.Name;
                        objectiveWrapperObj.priority = obj.Priority__c;
                        objectiveWrapperObj.type = obj.Objective_Type__c;
                        objectiveWrapperObj.startDate = obj.Start_Date__c;
                        objectiveWrapperObj.endDate = obj.End_Date__c;
                        objectiveWrapperObj.ParentChildInd = obj.Parent_Child_Independent__c;
                        objectiveWrapperObj.ChildProdSelType = obj.Child_Objective_Product_Selection_Type__c;
                        objectiveWrapperObj.ChildAccSelType = obj.Account_Universe_Selection__c;
                        objectiveWrapperObj.parentObjId = obj.Parent_Objective__c;
                        objectiveWrapperObj.updateAllowed = obj.Update_Allowed__c;
                        objectiveWrapperObj.powerbiReportLink = obj.PowerBI_Report_Link__c;
                        objectiveWrapperObj.children = objectiveLocationMap.get(obj.Id);
                        objectiveWrapperList.add(objectiveWrapperObj);
                    }
                } else {
                    ObjectiveWrapper objectiveWrapperObj = new ObjectiveWrapper();
                    objectiveWrapperObj.Id = obj.Id;
                    objectiveWrapperObj.Name = obj.Name;
                    objectiveWrapperObj.priority = obj.Priority__c;
                    objectiveWrapperObj.type = obj.Objective_Type__c;
                    objectiveWrapperObj.startDate = obj.Start_Date__c;
                    objectiveWrapperObj.endDate = obj.End_Date__c;
                    objectiveWrapperObj.ParentChildInd = obj.Parent_Child_Independent__c;
                    objectiveWrapperObj.ChildProdSelType = obj.Child_Objective_Product_Selection_Type__c;
                    objectiveWrapperObj.ChildAccSelType = obj.Account_Universe_Selection__c;
                    objectiveWrapperObj.parentObjId = obj.Parent_Objective__c;
                    objectiveWrapperObj.updateAllowed = obj.Update_Allowed__c;
                    objectiveWrapperObj.powerbiReportLink = obj.PowerBI_Report_Link__c;
                    objectiveWrapperObj.children = objectiveLocationMap.get(obj.Id);
                    objectiveWrapperList.add(objectiveWrapperObj);
                }
            }
        }
        return objectiveWrapperList;
    }
    
    //Return Parent Products List
    //Called from updateProductsOnObjective and getProductFilterDetails methods
    @AuraEnabled
    public static List<Product2> getParentProducts(String recordId) {
        List<Product2> parentProducts = New List<Product2>();
        parentProducts = ObjectiveDAO.getObjectiveProducts(recordId);
        return parentProducts;
    }

    //Get Objective Locations (Called from ProductFilters.cmp)
    @AuraEnabled
    public static List<Objective_Location__c> getObjectiveLocations(String recordId) {
        List<Objective_Location__c> objLocations = New List<Objective_Location__c>();
        objLocations = ObjectiveLocationDAO.getObjectiveLocationByObjectiveId(recordId);
        return objLocations;
    }
    
    //Get Objective Products (Called from AccountFilters.cmp)
    @AuraEnabled
    public static List<Objective_Product__c> getObjectiveProducts(String recordId) {
        List<Objective_Product__c> objProducts = New List<Objective_Product__c>();
        objProducts = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{recordId});
        return objProducts;
    }
    
    //Check to see if the user is a Market Leader who can create Parent Objectives
    @AuraEnabled
    public static Boolean isUserMarketLeaderForParentCreate() {        
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Enable_Parent_Objective_Create');
        return hasCustomPermission;
    }

    //Get User Data (Called from ProductFilters.cmp and AccountFilters.cmp)
    //Get's the current user's permissions for creating objectives   
    @AuraEnabled
    public static UserDataWrapper getUserData(Id objectiveId) {
        List<PermissionSetAssignment> permissionSetAssignmentList = PermissionSetAssignmentDAO.getPermissionSetAssignmentsByUserId(UserInfo.getUserId());
        Set<Id> permissionSetIds = new Set<Id>();
        for (PermissionSetAssignment permissionSetAssign : permissionSetAssignmentList) {
            permissionSetIds.add(permissionSetAssign.PermissionSetId);
        }
        List<PermissionSet> permissionSetList = PermissionSetDAO.getPermissionSetByIdsAndName(permissionSetIds);
        String permissionSetName = '';
        for (PermissionSet permSetObj : permissionSetList) {
            permissionSetName = permSetObj.Label;
        }

        UserDataWrapper userDataWrapperObj = new UserDataWrapper();
        userDataWrapperObj.permissionSetName = permissionSetName;
        return userDataWrapperObj;
    }
    
    //Get Objective Record (Called from ProductFilters.cmp and AccountFilters.cmp)
    @AuraEnabled
    public static Objective__c getObjectiveRecord(String recordId) {
        List<Objective__c> objectiveList = ObjectiveDAO.getObjectiveById(recordId);
        return objectiveList[0];
    }
    
    /***********************************
     * Account Processing
     * *********************************/
    //Get Account Filter Details (Called from AccountFilters.cmp)
    //Loads the Filter Values from the Custom Metadata
    @AuraEnabled
    public static List<FilterDetails> getAccountFilterDetails(String recordId) {
        String filters = '';
        String filtersInclude = '';
        Map<String, String> filterDetailsMap = new Map<String, String>();
        Map<String, Boolean> filterDetailsIncludeMap = new Map<String, Boolean>();
        if (recordId != null) {
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectivesByIds(new Set<Id>{recordId});
            for (Objective__c objDetail : objectiveList) {
                if (objDetail.FiltersLong__c != null) {
                    filters = objDetail.FiltersLong__c;
                }
                if (objDetail.FiltersInclude__c != null) {
                    filtersInclude = objDetail.FiltersInclude__c;
                }
            }
            if (filters != null && filters != '') {
                 filterDetailsMap = (Map<String, String>)JSON.deserialize(filters, Map<String, String>.class);
            }
            if (filtersInclude != null && filtersInclude != '' && (filtersInclude.contains('true') || filtersInclude.contains('false'))) {
                filterDetailsIncludeMap	= (Map<String, Boolean>)JSON.deserialize(filtersInclude, Map<String, Boolean>.class);
            }
        }	
            
        List<Objective_Filter__mdt> objectiveAccountFilters = ObjectiveFilterDAO.getObjectiveAccountFilters();  
        List<FilterDetails> filterDetailsList = new List<FilterDetails>();
                
        for (Objective_Filter__mdt objectiveAccountFilter : objectiveAccountFilters) {
            FilterDetails filterDetailsObject = new FilterDetails();
            filterDetailsObject.filterLabel = objectiveAccountFilter.MasterLabel;
            filterDetailsObject.filterAPIName = objectiveAccountFilter.API_Field_Name__c;
            filterDetailsObject.filterType = objectiveAccountFilter.Field_Type__c;
            filterDetailsObject.filterQueryCondition = objectiveAccountFilter.Query_Filter_Condition__c;
            filterDetailsObject.helpText = objectiveAccountFilter.Filter_Help_Text__c;
            filterDetailsObject.order = Integer.valueOf(objectiveAccountFilter.Order__c);
            filterDetailsObject.filterValues = new List<String>();
            filterDetailsObject.include = true;
            filterDetailsObject.includeString = '';
            filterDetailsObject.filterValue = '';            
            if (objectiveAccountFilter.Filter_Options_API_Object__c != null && objectiveAccountFilter.Filter_Options_API_Field_Name__c != null) {
                DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectiveAccountFilter.Filter_Options_API_Object__c).getDescribe();
				//If this is a Picklist field then get the picklist values
                if (objResult.fields.getMap().get(objectiveAccountFilter.Filter_Options_API_Field_Name__c) != null && objResult.fields.getMap().get(objectiveAccountFilter.Filter_Options_API_Field_Name__c).getDescribe().getType() == Schema.DisplayType.PICKLIST) {		   	        
		   	        filterDetailsObject.options = getFieldPicklistValues(objResult.fields.getMap().get(objectiveAccountFilter.Filter_Options_API_Field_Name__c).getDescribe());
                } else {
                  	//This is a text field so we have to get all the possible values from the records by doing a query                    
                    List<Objective_Location__c> objLocs = getObjectiveLocations(recordId);
                    List<String> listBUs = new List<String>();
                    for (Objective_Location__c objLoc : objLocs) {
                        if (objLoc.BU__c != null) {
                        	listBUs.add(objLoc.BU__c);
                        }
                    }
                    filterDetailsObject.options = getAggregateFieldValues(objectiveAccountFilter.Filter_Options_API_Object__c, objectiveAccountFilter.Filter_Options_API_Field_Name__c, listBUs);
                }                
            }
            if (recordId != null) {
                if (filterDetailsMap.containsKey(filterDetailsObject.filterLabel)) {
                    if (filterDetailsObject.filterType == 'Multi Select') {
                        filterDetailsObject.filterValues = filterDetailsMap.get(filterDetailsObject.filterLabel).split(',');
                        filterDetailsObject.includeString = filterDetailsObject.filterLabel;
                        filterDetailsObject.include = filterDetailsIncludeMap.get(filterDetailsObject.includeString);
                        if (filterDetailsObject.include == null) {
                        	filterDetailsObject.includeString = filterDetailsMap.get(filterDetailsObject.filterLabel);
                        	filterDetailsObject.include = filterDetailsIncludeMap.get(filterDetailsObject.includeString);
                        }
                    } else {
                        filterDetailsObject.filterValue = filterDetailsMap.get(filterDetailsObject.filterLabel);
                        filterDetailsObject.include = filterDetailsIncludeMap.get(filterDetailsObject.filterLabel);
                    }
                }
            }
            filterDetailsList.add(filterDetailsObject);
        }
        return filterDetailsList;
    }
    
    //Update Accounts (Called from AccountFilters.cmp)
    //User clicks "Update Filter Added Objective Accounts" button which updates FiltersLong__c and FiltersInclude__c with Filters user has selected
    //Then updates all the Filter Added Accounts related to the Objective
    @AuraEnabled
    public static ObjectiveErrorResponse updateAccounts(String recordId, String filters) {
		try {
	        //Update the Filter Fields on the Objective
	       	List<FilterDetails> filterDetailsList = (List<FilterDetails>)JSON.deserialize(filters, List<FilterDetails>.class);
			
	       	Map<String, String> filterValueMap = new Map<String, String>();
	       	Map<String, Boolean> filterIncludeMap = new Map<String, Boolean>();
	       	for (FilterDetails filterObj : filterDetailsList) {
	            if (filterObj.filterValues != null) {
	                if (!filterObj.filterValues.isEmpty()) {
	                    filterValueMap.put(filterObj.filterLabel, String.join(filterObj.filterValues, ','));
	                    filterIncludeMap.put(filterObj.filterLabel, filterObj.include);
	                }
	            }
	            if (filterObj.filterValue != null && filterObj.filterValue != '') {
	                filterValueMap.put(filterObj.filterLabel, filterObj.filterValue);
	                filterIncludeMap.put(filterObj.filterLabel, filterObj.include);
	            }
	        }
	       	Objective__c updateObjectiveFilter = new Objective__c();
	       	updateObjectiveFilter.Id = recordId;
	        updateObjectiveFilter.FiltersLong__c = JSON.serialize(filterValueMap);
	   	    updateObjectiveFilter.FiltersInclude__c = JSON.serialize(filterIncludeMap);
	       	ObjectiveDAO.updateObjectives(new List<Objective__c>{updateObjectiveFilter});

           	if (updateObjectiveFilter.FiltersLong__c != '{}') {
				List<AsyncApexJob> lstJobs = [SELECT Id FROM AsyncApexJob WHERE (status = 'Holding' OR status = 'Queued' OR status = 'Preparing' OR status = 'Processing') AND (ApexClass.Name = 'UpdateObjectivesQueueable')];
        		if (lstJobs.size() == 0) {                
	                //Run Update Objective in the Background
	            	runUpdateObjectives(recordId);                
   	        		//Return
					ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            		objectiveErrorRes.id = recordId;
	            	objectiveErrorRes.error = false;
    	        	objectiveErrorRes.errorMsg = null;
   	    	    	return objectiveErrorRes;
                } else {
					//Return
					ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            		objectiveErrorRes.id = recordId;
	            	objectiveErrorRes.error = true;
    	        	objectiveErrorRes.errorMsg = 'This objective is already being updated in the background, please try again.';
   	    	    	return objectiveErrorRes;
                }
            } else {
                //Return Message that no filters have been applied
				ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	           	objectiveErrorRes.id = recordId;
		        objectiveErrorRes.error = true;
	            objectiveErrorRes.errorMsg = 'No filters have been applied.';
    	   	    return objectiveErrorRes;
            }        
        } catch(Exception ex) {
            ErrorLog.insertErrorLog('Record: ' + recordId + ' : ' + ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ObjectivesController', 'updateAccounts');
            ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            objectiveErrorRes.error = true;
            objectiveErrorRes.errorMsg = ex.getMessage();
            objectiveErrorRes.batchProcessing = false;
            return objectiveErrorRes;
        }
    }
    
    /***********************************
     * Product Processing
     * *********************************/   
    //Update Products (Called from ProductFilters.cmp)
    //User clicks "Update Filter Added Objective Products" button which updates ProductFiltersLong__c and ProductFiltersInclude__c with Filters user has selected
    //Then updates all the Filter Added Products related to the Objective
    @AuraEnabled
    public static ObjectiveErrorResponse updateProducts(String recordId, String productFilters, Boolean createObjectiveProducts) {
		try {
        	List<FilterDetails> filterDetailsList = (List<FilterDetails>)JSON.deserialize(productFilters, List<FilterDetails>.class);
			
        	Map<String, String> filterValueMap = new Map<String, String>();
        	Map<String, Boolean> filterIncludeMap = new Map<String, Boolean>();
        	for (FilterDetails filterObj : filterDetailsList) {
	            if (filterObj.filterValues != null) {
                	if (!filterObj.filterValues.isEmpty()) {
	                    filterValueMap.put(filterObj.filterLabel, String.join(filterObj.filterValues, ','));
	                    filterIncludeMap.put(filterObj.filterLabel, filterObj.include);
	                }
	            }
	            if (filterObj.filterValue != null && filterObj.filterValue != '') {
	                filterValueMap.put(filterObj.filterLabel, filterObj.filterValue);
	                filterIncludeMap.put(filterObj.filterLabel, filterObj.include);
	            }
    	    }
	
        	Objective__c updateObjectiveFilter = new Objective__c();
        	updateObjectiveFilter.Id = recordId;
        	updateObjectiveFilter.ProductFiltersLong__c = JSON.serialize(filterValueMap);
        	updateObjectiveFilter.ProductFiltersInclude__c = JSON.serialize(filterIncludeMap);
        	ObjectiveDAO.updateObjectives(new List<Objective__c>{updateObjectiveFilter});
                
           	if (updateObjectiveFilter.ProductFiltersLong__c != '{}') {
				if (createObjectiveProducts == true) {	
                	//Now update the Products from the Filters
                	ObjectiveErrorResponse objectiveErrorRes = updateProductsOnObjective(new Set<Id> {updateObjectiveFilter.Id});                
                	if (objectiveErrorRes.error == false) {
						List<AsyncApexJob> lstJobs = [SELECT Id FROM AsyncApexJob WHERE (status = 'Holding' OR status = 'Queued' OR status = 'Preparing' OR status = 'Processing') AND (ApexClass.Name = 'UpdateObjectivesQueueable')];
        				if (lstJobs.size() == 0) {                
			                //Run Update Objective in the Background
			            	runUpdateObjectives(recordId);                
		   	        		//Return
							objectiveErrorRes = new ObjectiveErrorResponse();
		            		objectiveErrorRes.id = recordId;
			            	objectiveErrorRes.error = false;
		    	        	objectiveErrorRes.errorMsg = null;
		   	    	    	return objectiveErrorRes;
		                } else {
							//Return
							objectiveErrorRes = new ObjectiveErrorResponse();
		            		objectiveErrorRes.id = recordId;
				            objectiveErrorRes.error = true;
		    	        	objectiveErrorRes.errorMsg = 'This objective is already being updated in the background, please try again.';
	   		    	    	return objectiveErrorRes;
		                }                
                    }
                    return objectiveErrorRes;
                } else {
		   	        //Return
					ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
		            objectiveErrorRes.id = recordId;
			        objectiveErrorRes.error = false;
		    	    objectiveErrorRes.errorMsg = null;
		   	    	return objectiveErrorRes;
                }
            } else {
                //Return Message that no filters have been applied
				ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	           	objectiveErrorRes.id = recordId;
		        objectiveErrorRes.error = true;
	            objectiveErrorRes.errorMsg = 'No filters have been applied.';
    	   	    return objectiveErrorRes;
            }    
        } catch(Exception ex) {
            ErrorLog.insertErrorLog('Record: ' + recordId + ' : ' + ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ObjectivesController', 'updateProducts');
            ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            objectiveErrorRes.error = true;
            objectiveErrorRes.errorMsg = ex.getMessage();
            objectiveErrorRes.batchProcessing = false;
            return objectiveErrorRes;
        }
    }
    
    //Function to update the Product record on an Objective based on the filters selected
    public static ObjectiveErrorResponse updateProductsOnObjective(Set<Id> objIds) {
        try {
    		//Query for the Products and update
        	List<Objective_Filter__mdt> objectiveProductFilters = ObjectiveFilterDAO.getObjectiveProductFilters();
        	String filterString = '';            
	        
	        //Get all the Objectives
	        List<Objective__c> objs = ObjectiveDAO.getObjectivesByIds(objIds);
	        
	        List<Objective_Product__c> objectiveProductsToInsert = new List<Objective_Product__c>();
	        List<Objective_Product__c> objectiveProductsToDelete = new List<Objective_Product__c>();
	        
	        //Loop through all the Objectives
	        for (Objective__c obj : objs) {
                filterString = '';
	            if (obj.ProductFiltersLong__c <> '{}' && obj.ProductFiltersLong__c != null) {
		        	//Loop through all the possible filters
		        	String recordTypeId = '';
		        	for (Objective_Filter__mdt objectiveProductFilter : objectiveProductFilters) {
				    	JSONParser parser = JSON.createParser(obj.ProductFiltersLong__c);
				        while (parser.nextToken() != null) {
				        	if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == objectiveProductFilter.MasterLabel)) {
				               	if (filterString != '') {
					    	    	filterString += ' AND ';
					            }
								//Set the Record Type
				                recordTypeId = objectiveProductFilter.RecordTypeId__c;
					            //Get the values
					            parser.nextToken();   
                                String vals = '';
                                if (objectiveProductFilter.Filter_Options_API_Field_Name__c == 'SKU_External_Id__c') {
                                    List<String> multiVals = parser.getText().split(',');                                    
                                    for (String parseVal : multiVals) {
                                        if (vals == '') {
                                        	vals = parseVal.substringBefore(' ');
                                        } else {
                                            vals += '\',\'' + parseVal.substringBefore(' ');
                                        }
                                    }
                                } else {
                                	vals = parser.getText().replace(',','\',\'');    
                                }
					            //Append to the filter String
					            JSONParser parser2 = JSON.createParser(obj.ProductFiltersInclude__c);                		
				        		while (parser2.nextToken() != null) {
					            	if ((parser2.getCurrentToken() == JSONToken.FIELD_NAME) && (parser2.getText() == objectiveProductFilter.MasterLabel)) {
							    	    //Get the value
					                	parser2.nextToken();
				                        //Append to the filter String
				                        if (parser2.getBooleanValue()) {	                    				                    
						            		filterString += '(' + objectiveProductFilter.Filter_Options_API_Field_Name__c + ' IN (\'' + vals + '\'))';            	                                            
				                        } else {
				                            filterString += '(' + objectiveProductFilter.Filter_Options_API_Field_Name__c + ' NOT IN (\'' + vals + '\'))';            	
				                        }
				                	}
				             	}                  	
				          	}
				       	}
		            }
			   	
					//Now replace API Names in the filter String depending on what Record Type we are querying
				  	for (Objective_Filter__mdt objectiveProductFilter : objectiveProductFilters) {
			    		if (objectiveProductFilter.MasterLabel.contains('Brand') && recordTypeId == objectiveProductFilter.RecordTypeId__c) {
			        		filterString = filterString.replace(objectiveProductFilter.Filter_Options_API_Field_Name__c,'Name');
			            }
			        }
		            
			        //Now update the related Products            
			        //Create a Query to Get the Products that Should be Included
					String queryString = 'SELECT Id, Territories__c FROM Product2 WHERE IsActive=true AND RecordTypeId = \'' + recordTypeId + '\' AND ' + filterString + ' LIMIT 50000';
                    List<Product2> results = database.query(queryString);
	
	                //Get the list of BUs
	                List<Objective_Location__c> objLocs = getObjectiveLocations(obj.Id);
	                List<String> listBUs = new List<String>();
	                for (Objective_Location__c objLoc : objLocs) {
	                	if (objLoc.BU__c != null) {
	                       	listBUs.add(objLoc.BU__c);
	                    }
	                }
	                
				    //Create a Set of Filter Products
				    Set<Id> productIds = new Set<Id>();
                    //If this is a Child Objective and Exclusive                    
	                if (obj.Parent_Child_Independent__c == 'Child' && obj.Child_Objective_Product_Selection_Type__c == 'Exclusive') {
                        List<Product2> parentProducts = getParentProducts(obj.Parent_Objective__c);
                        for (Product2 prod : results) {
                            for (Product2 prod2 : parentProducts) {
                                if (prod.Id == prod2.Id) {
                                    productIds.add(prod.Id);
                                }
                            }
                        }
                    } else {
					    for (Product2 prod : results) {
		                    for (String bu : listBUs) {
		                        if (prod.Territories__c != null) {
		                        	if (prod.Territories__c.contains(bu)) {
					       				productIds.add(prod.Id);
			                            break;
			     	               }
		                        } else {
		                        	productIds.add(prod.Id);	//This is probably a Brand or Sub-Brand, they don't have Territories
		                        }		
		                    }
				   	   	}                        
                    }
	                
					//If this is a Child Objective and Semi-Exclusive compare the productIds to the parent Objective productIds (at least 1 must match)
	                if (obj.Parent_Child_Independent__c == 'Child' && obj.Child_Objective_Product_Selection_Type__c == 'Semi Exclusive') {
	                    Boolean childProductMatch = false;
	                    List<Product2> parentProducts = getParentProducts(obj.Parent_Objective__c);
	                    Set<Id> parentProductIds = new Set<Id>();
                        for (Product2 parentProduct : parentProducts) {
                            parentProductIds.add(parentProduct.Id);
                        }
	                    for (Id parentId: parentProductIds) {
	                        for (Id childId : productIds) {
	                            if (parentId == childId) {
	                                childProductMatch = true;
	                                break;
	                            }
	                        }
	                    }
	                    if (!childProductMatch) {
	                        //Return
							ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	            			objectiveErrorRes.id = obj.Id;
		            		objectiveErrorRes.error = true;
	    	        		objectiveErrorRes.errorMsg = 'At least one cascaded product must be selected';
	   	    	    		return objectiveErrorRes;
	                    }                    
	                }
	                
		        	//Now get the existing Products so we can compare
		        	Set<Id> existingProductIds = new Set<Id>();
		        	List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{obj.Id});   //In some cases this may be the parent Id?
		        
		        	for (Objective_Product__c objProd : objectiveProductList) {
				     	if (objProd.Manual_Product_Upload__c != true) {
					       	existingProductIds.add(objProd.Product__c);
				            if (!productIds.contains(objProd.Product__c)) {
					   	    	objectiveProductsToDelete.add(objProd);
					       	}
			            }
			        }
			    
				    for (String prod : productIds) {
					    if (!existingProductIds.contains(prod)) {
					    	Objective_Product__c objProd = new Objective_Product__c();
					        objProd.Product__c = prod;
				         	objProd.Objective__c = obj.Id;
				       	   	objectiveProductsToInsert.add(objProd);
				       	}
				    }
	        	}
	        
		    	if (!objectiveProductsToInsert.isEmpty()) {
				   	ObjectiveProductDAO.insertObjectiveProducts(objectiveProductsToInsert);
				}
	
			    if (!objectiveProductsToDelete.isEmpty()) {
		    	    ObjectiveProductDAO.deleteObjectiveProducts(objectiveProductsToDelete);
	        	}	            
	        }
            //Return
			ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	        objectiveErrorRes.id = objs[0].Id;
		    objectiveErrorRes.error = false;
			objectiveErrorRes.errorMsg = null;
	   	    return objectiveErrorRes;
		} catch(Exception ex) {
            ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            objectiveErrorRes.error = true;
            objectiveErrorRes.errorMsg = ex.getMessage();
            objectiveErrorRes.batchProcessing = false;
            return objectiveErrorRes;
        }
	}
        
    //Starts the Queueable job to update records on the Objective
    public static void runUpdateObjectives(String recordId) {
        //Run Update Objective in the Background
        Objective__c obj = [SELECT Id, Name, Objective_Type__c, Picture_Required__c, FiltersLong__c, FiltersInclude__c, ProductFiltersLong__c, 
	                        ProductFiltersInclude__c, Display_Location__c, Parent_Child_Independent__c,
                            (SELECT Id, BU__c, Warehouse__c, SalesOrg__c FROM Objective_Locations__r)
	                        FROM Objective__c WHERE Id =:recordId];
	    System.enqueueJob(new UpdateObjectivesQueueable(new List<Objective__c> {obj}));
    }
    
    
    //Get Product Filter Details (Called from ProductFilters.cmp)
    //Loads the Filter Values from the Custom Metadata
    @AuraEnabled
    public static List<FilterDetails> getProductFilterDetails(String recordId) {
        String filters = '';
        String filtersInclude = '';
        Boolean isExclusive = false;
        List<String> suppliers = new List<String>();
        List<String> brands = new List<String>();
        List<String> subbrands = new List<String>();
        List<String> draftpackages = new List<String>();
        List<String> packages = new List<String>();
        List<Product2> parentProducts = new List<Product2>();
        Map<String, String> filterDetailsMap = new Map<String, String>();
        Map<String, Boolean> filterDetailsIncludeMap = new Map<String, Boolean>();
        if (recordId != null) {            
            List<Objective__c> objectiveList = ObjectiveDAO.getObjectivesByIds(new Set<Id>{recordId});
            for (Objective__c objDetail : objectiveList) {
                if (objDetail.ProductFiltersLong__c != null) {
                    filters = objDetail.ProductFiltersLong__c;
                }
                if (objDetail.ProductFiltersInclude__c != null) {
                    filtersInclude = objDetail.ProductFiltersInclude__c;
                }
                //Set the Exclusive Flag
                if (objDetail.Parent_Child_Independent__c == 'Child' && objDetail.Child_Objective_Product_Selection_Type__c == 'Exclusive') {
                    isExclusive = true;                    
                }
                //Get Parent Products
                if (objDetail.Parent_Objective__c != null) {
                    parentProducts = getParentProducts(objDetail.Parent_Objective__c);
                }
            }
            if (filters != null && filters != '') {
                filterDetailsMap = (Map<String, String>)JSON.deserialize(filters, Map<String, String>.class);
            }
            if (filtersInclude != null && filtersInclude != '') {
                filterDetailsIncludeMap	= (Map<String, Boolean>)JSON.deserialize(filtersInclude, Map<String, Boolean>.class);
            }            
        }
        
        //Set the values of each filter down to Package so we can filters the selections
        if (filterDetailsMap.get('Supplier') != null) {
        	suppliers = filterDetailsMap.get('Supplier').split(',');
        }
        if (filterDetailsMap.get('Brand') != null) {
        	brands = filterDetailsMap.get('Brand').split(',');
        }
        if (filterDetailsMap.get('Sub Brand') != null) {
        	subbrands = filterDetailsMap.get('Sub Brand').split(',');
        }        
        if (filterDetailsMap.get('Draft/Package') != null) {
        	draftpackages = filterDetailsMap.get('Draft/Package').split(',');
        }
        if (filterDetailsMap.get('Container Type') != null) {
        	packages = filterDetailsMap.get('Container Type').split(',');
        }
        
        //Get a set of the Objective Locations
		List<Objective_Location__c> objLocs = getObjectiveLocations(recordId);
        Set<String> setBUs = new Set<String>();
        for (Objective_Location__c objLoc : objLocs) {
            if (objLoc.BU__c != null) {
                setBUs.add(objLoc.BU__c);
            }
		}
        
        //Get All Products
        List<Product2> listProductsAll = ProductDAO.getAllActiveSKUProducts();

		//Now filter all the products by the BUs                
        List<Product2> objectiveProducts = new List<Product2>();
        for (Product2 prod : listProductsAll) {
        	for (String bu : setBUs) {
            	if (prod.Territories__c != null) {
					if (prod.Territories__c.contains(bu)) {
	                    objectiveProducts.add(prod);
		            }
                }
            }
        }        
        
        //Get Product Filters from the Custom Metadata
        List<Objective_Filter__mdt> objectiveProductFilters = ObjectiveFilterDAO.getObjectiveProductFilters();
        List<FilterDetails> filterDetailsList = new List<FilterDetails>();
        
        for (Objective_Filter__mdt objectiveProductFilter : objectiveProductFilters) {
            FilterDetails filterDetailsObject = new FilterDetails();
            filterDetailsObject.filterLabel = objectiveProductFilter.MasterLabel;
            filterDetailsObject.filterAPIName = objectiveProductFilter.API_Field_Name__c;
            filterDetailsObject.filterType = objectiveProductFilter.Field_Type__c;
            filterDetailsObject.filterQueryCondition = objectiveProductFilter.Query_Filter_Condition__c;
            filterDetailsObject.helpText = objectiveProductFilter.Filter_Help_Text__c;
            filterDetailsObject.order = Integer.valueOf(objectiveProductFilter.Order__c);
            filterDetailsObject.filterValues = new List<String>();
            filterDetailsObject.include = true;
            filterDetailsObject.includeString = '';
            filterDetailsObject.filterValue = '';
            if (objectiveProductFilter.Filter_Options_API_Object__c != null && objectiveProductFilter.API_Field_Name__c != null) {
                DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectiveProductFilter.Filter_Options_API_Object__c).getDescribe();
                //For Exclusive Objectives we are only going to set Filter Values to those matching the Parent Product Selections
                if (isExclusive) {
                	if (parentProducts.size() > 0) {                            
						filterDetailsObject.options = getFieldValuesFromParent(objectiveProductFilter.Filter_Options_API_Field_Name__c, parentProducts);
					}
                //For Cascade, Local and Child Semi-Exclusive we need to get all the possible filters values
                } else {                	                            
    	            filterDetailsObject.options = getAggregateFieldValuesProducts(objectiveProducts, objectiveProductFilter.Filter_Options_API_Object__c, 
                                                                                  objectiveProductFilter.Filter_Options_API_Field_Name__c, suppliers, 
                                                                                  brands, subbrands, draftpackages, packages);
                }
            }
            if (recordId != null) {
                if (filterDetailsMap.containsKey(filterDetailsObject.filterLabel)) {
                    if (filterDetailsObject.filterType == 'Multi Select') {
                        filterDetailsObject.filterValues = filterDetailsMap.get(filterDetailsObject.filterLabel).split(',');
                        filterDetailsObject.includeString = filterDetailsObject.filterLabel;
                        filterDetailsObject.include = filterDetailsIncludeMap.get(filterDetailsObject.includeString);
                    } else {
                        filterDetailsObject.filterValue = filterDetailsMap.get(filterDetailsObject.filterLabel);
                        filterDetailsObject.include = filterDetailsIncludeMap.get(filterDetailsObject.filterLabel);
                    }
                }
            }            
            filterDetailsList.add(filterDetailsObject);
        }
        return filterDetailsList;
    }

    @TestVisible
    private static List<SelectDetails> getFieldPicklistValues(Schema.DescribeFieldResult fieldResult) {
        List<SelectDetails> fieldOptions = new List<SelectDetails>();
        List<Schema.PicklistEntry> fieldList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry fieldVal : fieldList) {
			SelectDetails selectOptionObj = new SelectDetails();            
            selectOptionObj.label = fieldVal.getLabel();
            selectOptionObj.value = fieldVal.getValue();
            fieldOptions.add(selectOptionObj);   
        }
        return fieldOptions;
    }
    
    @TestVisible
    private static List<SelectDetails> getFieldValuesFromParent(String fieldName, List<Product2> parentProducts) {
        List<SelectDetails> fieldOptions = new List<SelectDetails>();
        Set<String> setOptions = new Set<String>();
		Id skuProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
	    Id subBrandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
	    Id brandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();        
        for (Product2 prod : parentProducts) {
            String val = null;
            if (fieldName == 'BrewerId__r.Name') {
            	val = prod.BrewerId__r.Name;
            } else if (fieldName == 'BrandId__r.Name') {
                if (prod.RecordTypeId == brandProductRecordTypeId) {
   	            	val = prod.Name;
                } else {
   	                val = prod.BrandId__r.Name;
                }                    
            } else if (fieldName == 'Subbrandid__r.Name') {
                if (prod.RecordTypeId == subBrandProductRecordTypeId) {
                	val = prod.Name;
                } else {
                    val = prod.Subbrandid__r.Name;
                }
            } else if (fieldName == 'SKU_External_Id__c') {
                val = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
            } else {
            	val = (String)prod.get(fieldName);
            }
            if (val != null) {
				setOptions.add(val);
	        }            
        }
		List<String> setList = new List<String>(setOptions);  //Need to convert to a list so we can sort        
       	setList.sort();
        for (String option : setList) {
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = option;
           	selectOptionObj.value = option;
           	fieldOptions.add(selectOptionObj);
        }     
        return fieldOptions;
    }    
    
    @TestVisible
    private static List<SelectDetails> getAggregateFieldValuesProducts(List<Product2> allProds, String objectName, String fieldName, 
                                                                       List<String> suppliers, List<String> brands, List<String> subbrands, 
                                                                       List<String> draftpackages, List<String> packages) {                                                                       
        /*Product filters are cascaded down, so if a user selects a 'Supplier', then we scale down the rest of the filters to match the Supplier, etc.*/
        List<SelectDetails> fieldOptions = new List<SelectDetails>();
        Set<String> setOptions = new Set<String>();
		for (Product2 prod : allProds) {
	   		String fieldValue;	
            //Have to hard code cross reference field names due to 'invalid field' errors 	 
	        //SUPPLIER
            if (fieldName == 'BrewerId__r.Name') {   
            	fieldValue = prod.BrewerId__r.Name;
		    //BRAND
            } else if (fieldName == 'BrandId__r.Name') {
            	//Filters by Suppliers selected if there are any
                if (suppliers.size() != 0) {
                 	//If this Product contains one of the Suppliers selected
                 	if (suppliers.contains(prod.BrewerId__r.Name)) {
			        	fieldValue = prod.BrandId__r.Name;                                           
	                }
                } else {
					fieldValue = prod.BrandId__r.Name;
        	    }
			//SUB BRAND
			} else if (fieldName == 'Subbrandid__r.Name') {
				//Filters by Brands selected if there are any
				if (brands.size() != 0) {
					//If this Product contains one of the Brands selected
					if (brands.contains(prod.BrandId__r.Name)) {	
                        fieldValue = prod.Subbrandid__r.Name;                        
                    }
                } else {
                    if (suppliers.size() != 0) {                                    
						//If this Product contains one of the Suppliers selected
                    	if (suppliers.contains(prod.BrewerId__r.Name)) {
			            	fieldValue = prod.Subbrandid__r.Name;                           
	                    }
					} else {
						fieldValue = prod.Subbrandid__r.Name;
					}
				}
			//DRAFT/PACKAGE
			} else if (fieldName == 'DRAFT_OR_PACKAGE__c') {                             
				//Filters by Sub Brands selected if there are any
				if (subbrands.size() != 0) {
					//If this Product contains one of the Sub Brands selected
					if (subbrands.contains(prod.Subbrandid__r.Name)) {
						fieldValue = prod.DRAFT_OR_PACKAGE__c;                          
					}
					//Filters by Brands selected if there are any                                
				} else if (brands.size() != 0) {
					//If this Product contains one of the Brands selected
					if (brands.contains(prod.BrandId__r.Name)) {
						fieldValue = prod.DRAFT_OR_PACKAGE__c;                          
					}
					//Filters by Supplier selected if there are any                                                                
				} else {
					if (suppliers.size() != 0) {                                    
						//If this Product contains one of the Suppliers selected
						if (suppliers.contains(prod.BrewerId__r.Name)) {
							fieldValue = prod.DRAFT_OR_PACKAGE__c;                           
						}
					} else {
						fieldValue = 'Must select a Supplier, Brand or Sub Brand to show Draft/Package options.';
					}
                }
            //CONTAINER TYPE
			} else if (fieldName == 'SKU_Package_Type__c') {
				//Filters by Sub Brands selected if there are any
				if (subbrands.size() != 0) {
					//If this Product contains one of the Sub Brands selected
					if (subbrands.contains(prod.Subbrandid__r.Name)) {
						if (draftpackages.size() != 0)	{
							if (draftpackages.contains(prod.DRAFT_OR_PACKAGE__c)) {
								fieldValue = prod.SKU_Package_Type__c;                          
							}
                        } else {
                            fieldValue = prod.SKU_Package_Type__c;                                        
                        }       
                    }
				//Filters by Brands selected if there are any                                
				} else if (brands.size() != 0) {
                    //If this Product contains one of the Brands selected
                    if (brands.contains(prod.BrandId__r.Name)) {
                        if (draftpackages.size() != 0)	{
                            if (draftpackages.contains(prod.DRAFT_OR_PACKAGE__c)) {
                                fieldValue = prod.SKU_Package_Type__c;
                            }
                        } else {
                            fieldValue = prod.SKU_Package_Type__c;                                        
                        }        
                    }
                //Filters by Suppliers selected if there are any                                                                
                } else {
                    if (suppliers.size() != 0) {                                    
                        //If this Product contains one of the Suppliers selected
                        if (suppliers.contains(prod.BrewerId__r.Name)) {
                            if (draftpackages.size() != 0)	{
                                if (draftpackages.contains(prod.DRAFT_OR_PACKAGE__c)) {
                                    fieldValue = prod.SKU_Package_Type__c;                          
                                }
                            } else {
                                fieldValue = prod.SKU_Package_Type__c;
                            }                                 
                        }
                    } else {
                        fieldValue = 'Must select a Supplier, Brand or Sub Brand to show Container Type options.';
                    }
                }                                                        
			//SKU
            } else if (fieldName == 'SKU_External_Id__c') {
                //Filters by Sub Brands selected if there are any
				if (subbrands.size() != 0) {
                    //If this Product contains one of the Sub Brands selected
					if (subbrands.contains(prod.Subbrandid__r.Name)) {
                        if (packages.size() != 0) {
                            if (packages.contains(prod.SKU_Package_Type__c)) {
                                fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
                            }
                        } else if (draftpackages.size() != 0)	{
                            if (draftpackages.contains(prod.DRAFT_OR_PACKAGE__c)) {
                                fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
                            }
                        } else {
                            fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
                        }
                    }
                } else if (brands.size() != 0) {
                    //If this Product contains one of the Brands selected
                    if (brands.contains(prod.BrandId__r.Name)) {
						if (packages.size() != 0)	{
							if (packages.contains(prod.SKU_Package_Type__c)) {
								fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
                            }
                        } else if (draftpackages.size() != 0)	{
                            if (draftpackages.contains(prod.DRAFT_OR_PACKAGE__c)) {
                                fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
                            }
                        } else {
                            fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;
                        }
                    }
                } else {
                    if (suppliers.size() != 0) {                                    
                        //If this Product contains one of the Suppliers selected
                        if (suppliers.contains(prod.BrewerId__r.Name)) {
                            if (packages.size() != 0) {
                                if (packages.contains(prod.SKU_Package_Type__c)) {
                                    fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;                          
                                }
                            } else if (draftpackages.size() != 0)	{
                                if (draftpackages.contains(prod.DRAFT_OR_PACKAGE__c)) {
                                    fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;                          
                                }
                            } else {
                                fieldValue = prod.SKU_External_Id__c + ' - ' + prod.Product_Description_VIP__c;                                       
                            }
                        }
                    } else {
                        fieldValue = 'Must select a Supplier, Brand or Sub Brand to show SKU options.';
                    }
                }
            } else {
                fieldValue = (String)prod.get(fieldName);
            }
            if (fieldValue != null) {
                setOptions.add(fieldValue);
			}
	    }
        List<String> setList = new List<String>(setOptions);  //Need to convert to a list so we can sort        
       	setList.sort();
        for (String option : setList) {
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = option;
           	selectOptionObj.value = option;
           	fieldOptions.add(selectOptionObj);
        }     
        return fieldOptions;
    }
        
    @TestVisible
    private static List<SelectDetails> getAggregateFieldValues(String objectName, String fieldName, List<String> listBUs) {
        List<SelectDetails> fieldOptions = new List<SelectDetails>();
        Set<String> setOptions = new Set<String>();
		if (objectName == 'Account' && fieldName == 'Parent.Name') {
            String queryString = 'SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE ' + fieldName + ' != null AND Parent.Name != \'INDEPENDENT\' AND VIP_Instance__c IN (\'' + String.join(listBUs,'\',\'') + '\') ORDER BY ' + fieldName + ' LIMIT 40000';
            List<Account> results = database.query(queryString);
            //Add Independent because we excluded from the query above
            setOptions.add('INDEPENDENT');
            for (Account acc : results) {
                setOptions.add(acc.Parent.Name);
            }           
        } else {
            String queryString = 'SELECT ' + fieldName + ', Count(Id) FROM ' + objectName + ' GROUP BY ' + fieldName + ' LIMIT 50000';
            List<AggregateResult> groupedResults = database.query(queryString);
        	for (AggregateResult ar : groupedResults) {
            	setOptions.add(String.valueOf(ar.get('Name')));
        	}
        }
        for (String option : setOptions) {
            SelectDetails selectOptionObj = new SelectDetails();
            selectOptionObj.label = option;
           	selectOptionObj.value = option;
           	fieldOptions.add(selectOptionObj);
        }
        return fieldOptions;
    }
    
    public class FilterDetails {
        @AuraEnabled public String filterLabel;
        @AuraEnabled public String filterAPIName;
        @AuraEnabled public String filterType;
        @AuraEnabled public String filterQueryCondition;
        @AuraEnabled public String helpText;
        @AuraEnabled public Integer order;
        @AuraEnabled public List<String> filterValues;
        @AuraEnabled public String filterValue;
        @AuraEnabled public List<SelectDetails> options;
        @AuraEnabled public Boolean include;
        @AuraEnabled public String includeString;
    }

    public class SelectDetails {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class AccountFilterResponse {
        @AuraEnabled public Integer accountCount;
    }

	@TestVisible
    private static String buildBuWarehouseQueryString(List<String> buSelected, List<String> warehouseSelected, List<String> salesorgSelected, Map<String, List<String>> buDivisionMap) {
        String query = '';
        if (warehouseSelected.size() == 0 && salesorgSelected.contains('--None--')){
            query += 'VIP_Instance__c IN :buSelected';
        } else if (warehouseSelected.size() > 0 && salesorgSelected.contains('--None--')){
        	query += 'VIP_Instance__c IN :buSelected AND Warehouse__c IN :warehouseSelected';
        } else if(warehouseSelected.size() == 0 && !salesorgSelected.contains('--None--')){
        	query += 'VIP_Instance__c IN :buSelected AND SalesOrg__c IN :salesorgSelected';
        } else {
        	query += 'VIP_Instance__c IN :buSelected AND (Warehouse__c IN :warehouseSelected AND SalesOrg__c IN :salesorgSelected)';
        }
        return query;
    }

    @TestVisible
    private static String buildWhereClauseString(List<FilterDetails> filterDetailsList){
        String query = '';

        for(FilterDetails filterObj : filterDetailsList){
            if (!filterObj.filterValues.isEmpty()) {
                if(filterObj.filterQueryCondition == 'AND' && filterObj.include == true){
                    query += ' AND ' + filterObj.filterAPIName + ' IN ' + convertListStringToLiteral(filterObj.filterValues);
                } else if (filterObj.filterQueryCondition == 'AND' && filterObj.include == false) {
                    query += ' AND ' + filterObj.filterAPIName + ' NOT IN ' + convertListStringToLiteral(filterObj.filterValues);
                }
            } else if(filterObj.filterValue != null && filterObj.filterValue != ''){
                if(filterObj.filterQueryCondition == 'AND' && filterObj.include == true){
                    query += ' AND ' + filterObj.filterAPIName + ' IN ' + convertListStringToLiteral(filterObj.filterValue.split(','));
                }else if(filterObj.filterQueryCondition == 'AND' && filterObj.include == false) {
                    query += ' AND ' + filterObj.filterAPIName + ' NOT IN ' + convertListStringToLiteral(filterObj.filterValue.split(','));
                }
            }
        }

        query += ')';

        for(FilterDetails filterObj : filterDetailsList){
            if(!filterObj.filterValues.isEmpty()){
                if(filterObj.filterQueryCondition == 'OR' && filterObj.include == true){
                    query += ' OR ' + filterObj.filterAPIName + ' IN ' + convertListStringToLiteral(filterObj.filterValues);
                }else if(filterObj.filterQueryCondition == 'OR' && filterObj.include == false) {
                    query += ' OR ' + filterObj.filterAPIName + ' NOT IN ' + convertListStringToLiteral(filterObj.filterValues);
                }
            } else if(filterObj.filterValue != null && filterObj.filterValue != ''){
                if(filterObj.filterQueryCondition == 'OR' && filterObj.include == true){
                    query += ' OR ' + filterObj.filterAPIName + ' IN ' + convertListStringToLiteral(filterObj.filterValue.split(','));
                }else if(filterObj.filterQueryCondition == 'OR' && filterObj.include == false) {
                    query += ' OR ' + filterObj.filterAPIName + ' NOT IN ' + convertListStringToLiteral(filterObj.filterValues);
                }
            }
        }
        return query;
    }

    @TestVisible
    private static Integer queryStringBuilderCount(String query, List<String> buSelected, List<String> warehouseSelected, List<String> salesorgSelected, Map<String, List<String>> buDivisionMap, 
                                                    List<FilterDetails> filterDetailsList){
        query += buildBuWarehouseQueryString(buSelected, warehouseSelected, salesorgSelected, buDivisionMap);
        query += buildWhereClauseString(filterDetailsList);
        return Database.countQuery(query);
    }

    @TestVisible
    private static String convertListStringToLiteral(List<String> stringList){
        String newSetStr = '' ;
        for(String str : stringList){
            newSetStr += '\'' + str + '\',';
        }
        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;
        return newSetStr;
    }

    //This method is called from UpdateObjectivesQueueable
    @AuraEnabled
    public static ObjectiveErrorResponse createObjectives(List<String> productIds, Objective__c objectiveRec, Boolean updateObjective, String accountFilters, Boolean batchProcessing,
                                List<String> buSelected, List<String> warehouseSelected, List<String> salesorgSelected, List<Objective_Location__c> objectiveLocationsToInsert, List<Objective_Location__c> existingObjectiveLocations,
                                List<String> deleteLocs, Boolean manualUpload) {		
		
		try {
            List<Objective__c> parentObjective = new List<Objective__c>();
            if (!updateObjective) {
                if (objectiveRec != null) {
                    parentObjective = ObjectiveDAO.insertObjectives(new List<Objective__c>{objectiveRec});
                }
            } else {
                if (objectiveRec != null) {
                    parentObjective = ObjectiveDAO.updateObjectives(new List<Objective__c>{objectiveRec});
                }
            }
            
			Boolean batchProcessed = false;
            Set<Id> existingProductIds = new Set<Id>();
            List<Objective_Product__c> objectiveProductList = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{parentObjective[0].Id});
            List<Objective_Product__c> objectiveProductsToDelete = new List<Objective_Product__c>();
            for (Objective_Product__c objProd : objectiveProductList) {
	        	existingProductIds.add(objProd.Product__c);
	            if (!productIds.contains(objProd.Product__c)) {
	                objectiveProductsToDelete.add(objProd);
	            }
            }

	        List<Objective_Product__c> objectiveProductsToInsert = new List<Objective_Product__c>();
	        for (String prod : productIds) {
	        	if (!existingProductIds.contains(prod)) {
	        		Objective_Product__c objProd = new Objective_Product__c();
	            	objProd.Product__c = prod;
	            	objProd.Objective__c = objectiveRec.Id;
	            	objectiveProductsToInsert.add(objProd);
	        	}
	        }

	        if (!objectiveProductsToInsert.isEmpty()) {
	        	ObjectiveProductDAO.insertObjectiveProducts(objectiveProductsToInsert);
	        }

	        if (!objectiveProductsToDelete.isEmpty()) {
	        	ObjectiveProductDAO.deleteObjectiveProducts(objectiveProductsToDelete);
	        }
	
	        for (Objective_Location__c objectiveLoc : objectiveLocationsToInsert) {
	            objectiveLoc.Objective__c = objectiveRec.Id;
	        }
	
	        if (!deleteLocs.isEmpty()){
	            List<Objective_Location__c> objLocations = ObjectiveLocationDAO.getObjectiveLocationByObjectiveLocationIds(deleteLocs);
	            ObjectiveLocationDAO.deleteObjectiveLocations(objLocations);
	        }
	
	        Map<String, String> objectiveLocationMap = new Map<String,String>();
	        if(!objectiveLocationsToInsert.isEmpty()){
	            List<Objective_Location__c> objectiveLocationsReturned = ObjectiveLocationDAO.insertObjectiveLocations(objectiveLocationsToInsert);
	            for(Objective_Location__c objLoc : objectiveLocationsReturned){
	                objectiveLocationMap.put(objLoc.BU__c, objLoc.Id);
	            }
	        }
	        if(!objectiveLocationsToInsert.isEmpty()){
	            if(objectiveRec.Goal_Type__c == 'Individual Goal'){
	                List<Objective_Location__c> individualObjectiveLoc =  new List<Objective_Location__c>();
	                Objective_Location__c individualObjeLoc = new Objective_Location__c();
	                individualObjeLoc.Objective__c = objectiveRec.Id;
	                individualObjectiveLoc.add(individualObjeLoc);
	                ObjectiveLocationDAO.insertObjectiveLocations(individualObjectiveLoc);
	            }
	        }
	
	        if (existingObjectiveLocations != null) {
	            if (!existingObjectiveLocations.isEmpty()) {
	                List<Objective_Location__c> objectiveLocationsReturned = ObjectiveLocationDAO.updateObjectiveLocations(existingObjectiveLocations);
	                for (Objective_Location__c objLoc : objectiveLocationsReturned) {
	                    objectiveLocationMap.put(objLoc.BU__c, objLoc.Id);
	                }
	            }
	        }
	
	        Map<String, List<String>> buDivisionMap = new Map<String, List<String>>();
	        String query = '';
	        List<BU_Division__mdt> buDivisions = BUDivisionDAO.getBuDivisions();
	        for(BU_Division__mdt buDivisionObj : buDivisions){
	            List<String> divisionList = new List<String>();
	            if(buDivisionMap.containsKey(buDivisionObj.Division__c)){
	                divisionList = buDivisionMap.get(buDivisionObj.Division__c);
	            }
	            divisionList.add(buDivisionObj.MasterLabel);
	            buDivisionMap.put(buDivisionObj.Division__c, divisionList);
	        }
	
	        if (updateObjective) {           
	            if (existingObjectiveLocations != null) {
	                if (!existingObjectiveLocations.isEmpty()) {
	                    for (Objective_Location__c objLocObj : existingObjectiveLocations) {
	                        if (objLocObj.BU__c != null) {
	                            buSelected.add(objLocObj.BU__c);
	                        }
	                        if(objLocObj.BU__c != null && objLocObj.SalesOrg__c != null) {
	                            salesorgSelected.add(objLocObj.SalesOrg__c);
	                        }
                            if(objLocObj.BU__c != null && objLocObj.Warehouse__c != null && objLocObj.Warehouse__c != '--None--') {
	                            warehouseSelected.add(objLocObj.Warehouse__c);
	                        }
	                    }
	                }
	            }
	        }            
	
	        List<FilterDetails> filterDetailsList = (List<FilterDetails>)JSON.deserialize(accountFilters, List<FilterDetails>.class);
            
            //If the user hasn't applied any filters, then don't proceed
            String buildWhereClauseString = buildWhereClauseString(filterDetailsList);
            if (buildWhereClauseString != ')') {
	        	query = 'SELECT Id, Name, VIP_Instance__c, Warehouse__c, SalesOrg__c, OwnerId, Territories__c FROM Account WHERE (';
	        	query += buildBuWarehouseQueryString(buSelected, warehouseSelected, salesorgSelected, buDivisionMap);
	        	query += buildWhereClauseString;
	
	        	Map<String, String> filterValueMap = new Map<String, String>();
	        	Map<String, Boolean> filterIncludeMap = new Map<String, Boolean>();
	        	for (FilterDetails filterObj : filterDetailsList) {
	            	if (filterObj.filterValues != null) {
		                if (!filterObj.filterValues.isEmpty()) {
	                    	filterValueMap.put(filterObj.filterLabel, String.join(filterObj.filterValues, ','));
	                    	filterIncludeMap.put(filterObj.filterLabel, filterObj.include);
	                	}
	            	}
	            	if (filterObj.filterValue != null && filterObj.filterValue != '') {
		                filterValueMap.put(filterObj.filterLabel, filterObj.filterValue);
		                filterIncludeMap.put(filterObj.filterLabel, filterObj.include);
		            }
		        }
	
	        	Objective__c updateObjectiveFilter = new Objective__c();
	        	updateObjectiveFilter.Id = objectiveRec.Id;
	        	updateObjectiveFilter.FiltersLong__c = JSON.serialize(filterValueMap);
	        	updateObjectiveFilter.FiltersInclude__c = JSON.serialize(filterIncludeMap);
	        	ObjectiveDAO.updateObjectives(new List<Objective__c>{updateObjectiveFilter});
	
		        String queryCount = 'SELECT count() FROM Account WHERE (';
		        Integer accountCount = queryStringBuilderCount(queryCount, buSelected, warehouseSelected, salesorgSelected, buDivisionMap, filterDetailsList);
	
        	    if (objectiveRec.Parent_Child_Independent__c != 'Cascade') {   //We don't want to create Objective Accounts for Cascade Objectives (only for Local and Child)
		    	    if (accountCount < 5000) {
	                	Set<Id> totalAccountIds = new Set<Id>();
	                	List<Account> accountTotalList = Database.query(query);
	                	for (Account accountObj : accountTotalList) {
	                    	totalAccountIds.add(accountObj.Id);
	                	}
	                	Set<Id> existingAccountIds = new Set<Id>();
	                	List<Objective_Account__c> objectiveAccountList = ObjectiveAccountDAO.getObjectiveAccountsByObjective(new Set<Id>{parentObjective[0].Id});
	                	List<Objective_Account__c> objectiveAccountsToDelete = new List<Objective_Account__c>();
	                	Map<Id, Objective_Account__c> existingObjectiveAccountMap = new Map<Id, Objective_Account__c>();
	                	for (Objective_Account__c objAcc : objectiveAccountList) {
		                    existingAccountIds.add(objAcc.Account__c);                       
		                    if (!totalAccountIds.contains(objAcc.Account__c) && objAcc.Manual_Upload__c != true) {
		                        //Adding a safety precaution here, only add to delete if the Objective Account has not had activity (i.e., Objective Submission created, only applies to Price Feature, Reset and Display objectives)
		                    	if ((objAcc.Objective_Type__c != 'Price Feature' && objAcc.Objective_Type__c != 'Reset' && objAcc.Objective_Type__c != 'Display') || (objAcc.Status__c == 'Incomplete' && objAcc.Completed_Count__c == 0)) {
		                        	objectiveAccountsToDelete.add(objAcc);
		                        }
	                    	} else {
	                    	    existingObjectiveAccountMap.put(objAcc.Account__r.Id, objAcc);
	                    	}
                    	}
	
	                	List<Objective_Product__c> objectiveProductListTerr = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{parentObjective[0].Id});
	                	Set<String> productIdSet = new Set<String>();
	                	for (Objective_Product__c objProd : objectiveProductListTerr) {
	                    	productIdSet.add(objProd.Product__c);
	                	}
	                	List<Product2> selectedProducts = ProductDAO.getProductByIds(productIdSet);
	                	Set<String> skuProductIds = new Set<String>();
	                	Set<String> subBrandProductIds = new Set<String>();
	                	Set<String> brandProductIds = new Set<String>();
	                	Id skuProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('SKU').getRecordTypeId();
	                	Id subBrandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Subbrand').getRecordTypeId();
	                	Id brandProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Brand').getRecordTypeId();
	                	for (Product2 prodObj : selectedProducts) {
	                    	if (prodObj.RecordTypeId == skuProductRecordTypeId) {
	                        	skuProductIds.add(prodObj.Id);
	                    	}
	                    	if (prodObj.RecordTypeId == subBrandProductRecordTypeId) {
	                        	subBrandProductIds.add(prodObj.Id);
	                    	}
	                    	if (prodObj.RecordTypeId == brandProductRecordTypeId) {
	                        	brandProductIds.add(prodObj.Id);
	                    	}
	                	}
	
	                	List<Product2> skuSubBrandBrandProductList = ProductDAO.getProductByIdSubBrandBrand(skuProductIds, subBrandProductIds, brandProductIds, skuProductRecordTypeId);
	                	Set<String> productTerritories = new Set<String>();
	                	for (Product2 prodObj: skuSubBrandBrandProductList) {
	                    	if (prodObj.Territories__c != null) {
	                        	List<String> objProdTerrSplit = prodObj.Territories__c.split(',');
	                        	for (String terr: objProdTerrSplit) {
	                            	productTerritories.add(terr);
	                        	}
                    		}
                		}
	
	                	Territory_Matching__c terrMatchingCustomSetting = Territory_Matching__c.getInstance();
	
	                	List<Objective_Account__c> objectiveAccountsToInsert = new List<Objective_Account__c>();
	                	List<Objective_Account__c> objectiveAccountsToUpdate = new List<Objective_Account__c>();
	                	for (Account accountObj : accountTotalList) {
	                    	//Territory Matching is turned On/Off in the Custom Settings, although we don't expect it to ever be turned off
	                    	if (terrMatchingCustomSetting.Territory_Matching__c) { 
	                        	if (!existingAccountIds.contains(accountObj.Id)) {
	                            	//Objective Account Needs to be Created
	                            	if (accountObj.Territories__c != null) {
		                                Boolean terrMisMatch = true;
		                                List<String> accountTerr = accountObj.Territories__c.split(',');
		                                for (String productTerr : productTerritories) {
		                                    if (accountTerr.contains(productTerr)) {
	                                        terrMisMatch = false;
	    	                                }
		                                }
		                                if (!terrMisMatch) {
	    	                                Objective_Account__c objAcc = new Objective_Account__c();
	        	                            objAcc.RecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get(objectiveRec.Objective_Type__c).getRecordTypeId();
		                                    objAcc.Account__c = accountObj.Id;
		                                    objAcc.Objective__c = objectiveRec.Id;
		                                    if (objectiveLocationMap.containsKey(accountObj.VIP_Instance__c)) {
		                                        objAcc.Objective_Location__c = objectiveLocationMap.get(accountObj.VIP_Instance__c);
		                                    }
		                                    if (parentObjective[0].Picture_Required__c) {
		                                        objAcc.Pictured_Required__c = true;
		                                    }		                                    
	                            			if (objAcc.OwnerId <> accountObj.OwnerId) {
	                            				objAcc.OwnerId = accountObj.OwnerId;
	                            			}
	                    	                objectiveAccountsToInsert.add(objAcc);
	                        	        }
	                            	}
	                        	} else {
	                            	//The Objective Account already exists, check that the Owner is correct
	                            	Objective_Account__c objAcc = existingObjectiveAccountMap.get(accountObj.Id);
	                            	if (accountObj.Territories__c != null) {
	                                	Boolean terrMisMatch = true;
	                                	List<String> accountTerr = accountObj.Territories__c.split(',');
	                                	for (String productTerr : productTerritories) {
	                                    	if (accountTerr.contains(productTerr)) {
	                                        	terrMisMatch = false;
	                                    	}
	                                	}
	                                	if (!terrMisMatch) {
	        	                            if (objAcc.OwnerId <> accountObj.OwnerId) {
	            	                        	objAcc.OwnerId = accountObj.OwnerId;
                                                objectiveAccountsToUpdate.add(objAcc);
	                	                    }                                            
	                                	}
	                            	}                            
	                        	}
	                    	} else {
	                        	//Only executes if Territory Matching is turned off which will probably never happen
	                        	if(!existingAccountIds.contains(accountObj.Id)){
	                            	//Objective Account Needs to be Created
	                            	Objective_Account__c objAcc = new Objective_Account__c();
	                            	objAcc.RecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get(objectiveRec.Objective_Type__c).getRecordTypeId();
	                            	objAcc.Account__c = accountObj.Id;
	                            	objAcc.Objective__c = objectiveRec.Id;
	                            	if (objectiveLocationMap.containsKey(accountObj.VIP_Instance__c)) {
	                                	objAcc.Objective_Location__c = objectiveLocationMap.get(accountObj.VIP_Instance__c);
	                            	}
	                            	if (parentObjective[0].Picture_Required__c) {
	                                	objAcc.Pictured_Required__c = true;
	                            	}
	                            	if (objAcc.OwnerId <> accountObj.OwnerId) {
	                            		objAcc.OwnerId = accountObj.OwnerId;
	                            	}
	                            	objectiveAccountsToInsert.add(objAcc);
	                        	}
	                    	}
	                	}
	                	if (manualUpload == false) {
	    	                if (!objectiveAccountsToInsert.isEmpty()) {
	                    	    ObjectiveAccountDAO.insertObjectiveAccounts(objectiveAccountsToInsert);	
	                    	}
	                    	if (!objectiveAccountsToUpdate.isEmpty()) {
	                        	ObjectiveAccountDAO.updateObjectiveAccounts(objectiveAccountsToUpdate);
	                    	}
	                    	if (!objectiveAccountsToDelete.isEmpty()) {
	                    		ObjectiveAccountDAO.deleteObjectiveAccounts(objectiveAccountsToDelete);
	                		}
	                	}
	            	}  else if (manualUpload == false) {
		                batchProcessed = true;
		                BatchProcessObjectiveLocations batchProcessObjectiveLocation = new BatchProcessObjectiveLocations();
		                batchProcessObjectiveLocation.query = query;
		                batchProcessObjectiveLocation.pictureRequired = parentObjective[0].Picture_Required__c;
		                batchProcessObjectiveLocation.objectiveId = parentObjective[0].Id;
		                batchProcessObjectiveLocation.objectiveLocationMap = objectiveLocationMap;
		                batchProcessObjectiveLocation.objectiveType = objectiveRec.Objective_Type__c;
		                batchProcessObjectiveLocation.buSelected = buSelected;
		                batchProcessObjectiveLocation.warehouseSelected = warehouseSelected;
		                batchProcessObjectiveLocation.salesorgSelected = salesorgSelected;
		                List<AsyncApexJob> lstJobs = [SELECT Id FROM AsyncApexJob WHERE (status = 'Holding' OR status = 'Queued' OR status = 'Preparing' OR status = 'Processing') AND (ApexClass.Name = 'BatchProcessObjectiveLocations' OR ApexClass.Name = 'BatchDeleteObjectiveAccounts')];
		                if (lstJobs.IsEmpty() || UserInfo.getName().contains('Data Migration')) {   //If is being run by Data Migration we allow multiple jobs to get queued
	    	                Id batchProcessId = Database.executeBatch(batchProcessObjectiveLocation);
	        	        } else {
	            	        ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	                	    objectiveErrorRes.id = parentObjective[0].Id;
		                	objectiveErrorRes.error = true;
		                	objectiveErrorRes.errorMsg = 'Already processing changes, please wait before making updates.';
	    	        		objectiveErrorRes.batchProcessing = false;
	        	        	return objectiveErrorRes;
	            	    }
	            	}
	        	}
            
	            if (!updateObjective) {
                	ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
                	objectiveErrorRes.id = parentObjective[0].Id;
                	objectiveErrorRes.error = false;
                	objectiveErrorRes.errorMsg = null;
                	objectiveErrorRes.batchProcessing = batchProcessed;
                	return objectiveErrorRes;
            	} else {
	                ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	                objectiveErrorRes.id = objectiveRec.Id;
	                objectiveErrorRes.error = false;
	                objectiveErrorRes.errorMsg = null;
	                objectiveErrorRes.batchProcessing = batchProcessed;
	                return objectiveErrorRes;
	            }
            } else {
            	ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
	            objectiveErrorRes.id = parentObjective[0].Id;
		        objectiveErrorRes.error = true;
		        objectiveErrorRes.errorMsg = 'No Account Filters have been selected.';
	    	    objectiveErrorRes.batchProcessing = false;
	        	return objectiveErrorRes;
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'ObjectivesController', 'createObjectives');
            ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            objectiveErrorRes.error = true;
            objectiveErrorRes.errorMsg = ex.getMessage();
            objectiveErrorRes.batchProcessing = false;
            return objectiveErrorRes;
        }
    }
       
    //Search for Products to Manually Add to Objective (Called from objectiveProductSearch lwc)
    @AuraEnabled
    public static List<Product2> getProductSearchResults(String searchKey, String recordId) {
        List<Product2> productsForTerritory = new List<Product2>();
        List<Product2> productList = Database.query('SELECT Id, Name, Territories__c FROM Product2 WHERE (Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' OR SKU_External_Id__c = \'' + String.escapeSingleQuotes(searchKey) + '\') AND IsActive=true ORDER BY Name');
		//Get a list of BUs
        List<Objective_Location__c> objLocs = getObjectiveLocations(recordId);
        List<String> listBUs = new List<String>();
        for (Objective_Location__c objLoc : objLocs) {
        	listBUs.add(objLoc.BU__c);
        }
   		for (Product2 prod : productList) {
        	if (prod.Territories__c != null) {
	        	for (String bu : listBUs) {
	            	if (prod.Territories__c.contains(bu)) {
	                    productsForTerritory.add(prod);
	                    break;
                    }
                }
            }
        }
        return productsForTerritory;
    }
    
    //Add Selected Product to an Objective (Called from objectiveProductSearch lwc)
    @AuraEnabled
    public static void addProductToObjectiveManual(String recordId, String productId) {
        Objective_Product__c prodObj = new Objective_Product__c();
		prodObj.Objective__c = recordId;
        prodObj.Product__c = productId;
        prodObj.Manual_Product_Upload__c = true;
        insert prodObj;
    }
    
    //Search for Accounts to Manually Add to Objective (Called from objectiveAccountSearch lwc)
    @AuraEnabled
    public static List<Account> getAccountSearchResults(String searchKey, String recordId) {
        List<Account> accountsForTerritory = new List<Account>();
        List<Account> accountList = Database.query('SELECT Id, Name, Territories__c FROM Account WHERE (Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' OR ExternalId__c LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\') AND Status__c=\'A\' ORDER BY Name');
		//Get a list of BUs
        List<Objective_Location__c> objLocs = getObjectiveLocations(recordId);
        List<String> listBUs = new List<String>();
        for (Objective_Location__c objLoc : objLocs) {
        	listBUs.add(objLoc.BU__c);
        }
   		for (Account acc : accountList) {
        	if (acc.Territories__c != null) {
	        	for (String bu : listBUs) {
	            	if (acc.Territories__c.contains(bu)) {
	                    accountsForTerritory.add(acc);
	                    break;
                    }
                }
            }
        }
        return accountsForTerritory;
    }
    
    //Add Selected Account to an Objective (Called from objectiveAccountSearch lwc)
    @AuraEnabled
    public static void addAccountToObjectiveManual(String recordId, String accountId) {
        List<Objective__c> objList = ObjectiveDAO.getObjectivesByIds(new Set<Id>{recordId});
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Id = :accountId LIMIT 1];
        Objective_Account__c accObj = new Objective_Account__c();
        accObj.RecordTypeId = Schema.SObjectType.Objective_Account__c.getRecordTypeInfosByName().get(objList[0].Objective_Type__c).getRecordTypeId();
		accObj.Objective__c = recordId;
        accObj.Account__c = accountId;
        accObj.Manual_Upload__c = true;
        accObj.OwnerId = acc.OwnerId;
		insert accObj;
    }

    public class ObjectiveWrapper {
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String priority {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public Date startDate {get; set;}
        @AuraEnabled public Date endDate {get; set;}
        @AuraEnabled public String ParentChildInd {get; set;}
        @AuraEnabled public String ChildProdSelType {get; set;}
        @AuraEnabled public String ChildAccSelType {get; set;}
        @AuraEnabled public String parentObjId {get; set;}
        @AuraEnabled public Boolean updateAllowed {get; set;}
        @AuraEnabled public String powerbiReportLink {get; set;}
        @AuraEnabled public List<Objective_Location__c> children {get; set;}
    }

    public class UserDataWrapper {
        @AuraEnabled public String permissionSetName {get; set;}
    }

    public class ObjectiveErrorResponse {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public Boolean error {get; set;}
        @AuraEnabled public String errorMsg {get; set;}
        @AuraEnabled public Boolean batchProcessing {get; set;}
    }
}