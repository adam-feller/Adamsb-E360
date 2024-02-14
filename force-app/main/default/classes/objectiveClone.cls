public without sharing class objectiveClone {

    @AuraEnabled
    public static Objective__c getObjectiveRecord(String recordId){
        List<Objective__c> objectiveList = ObjectiveDAO.getObjectiveById(recordId);
        return objectiveList[0];
    }

    @AuraEnabled
    public static ObjectiveErrorResponse createObjectives(Objective__c objectiveRec, String objName, Date objStartDate, Date objEndDate){
        try{
            Objective__c tempObj = objectiveRec.clone(false, false, false, false);
            tempObj.Name = objName;
            tempObj.Start_Date__c = objStartDate;
            tempObj.End_Date__c = ObjEndDate;
            tempObj.Status__c = 'New';
            ObjectiveDAO.insertObjectives(new List<Objective__c>{tempObj});

            List<Objective_Product__c> objProduct = ObjectiveProductDAO.getObjectiveProductByObjectiveIds(new Set<Id>{objectiveRec.Id});
            if(objProduct.size() > 0){
                for(Objective_Product__c obj :objProduct){
                    obj.id = null;
                    obj.Objective__c = tempObj.Id;
                }
                ObjectiveProductDAO.insertObjectiveProducts(objProduct);
            }

            List<Objective_Location__c> objLoc = ObjectiveLocationDAO.getObjectiveLocationByObjectiveIdsAllTime(new Set<Id>{objectiveRec.Id});
            if(objLoc.size() > 0){
                for(Objective_Location__c obj :objLoc){
                    obj.id = null;
                    obj.Objective__c = tempObj.Id;
                }
                ObjectiveLocationDAO.insertObjectiveLocations(objLoc);
            }

            BatchProcessClonedObjectiveAccounts batchProcessClonedObjAcc = new BatchProcessClonedObjectiveAccounts();
            batchProcessClonedObjAcc.query = 'SELECT Id, Objective__c, Account__r.OwnerId, Account__c, Account__r.Name, Status__c, Manual_Upload__c, OwnerId ' +
                                            ' FROM Objective_Account__c ' +
                                            ' WHERE Objective__c = :clonedObjectiveId' + 
                                            ' AND RecordType.Name != \'Deleted\'';
            batchProcessClonedObjAcc.newObjectiveId = tempObj.Id;
            batchProcessClonedObjAcc.clonedObjectiveId = objectiveRec.Id;
            Id batchProcessId = Database.executeBatch(batchProcessClonedObjAcc);

            ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            objectiveErrorRes.id = tempObj.Id;
            objectiveErrorRes.error = false;
            objectiveErrorRes.errorMsg = null;
            objectiveErrorRes.batchId = batchProcessId;
            return objectiveErrorRes;
        } catch(Exception ex){
            ObjectiveErrorResponse objectiveErrorRes = new ObjectiveErrorResponse();
            objectiveErrorRes.id = null;
            objectiveErrorRes.error = true;
            objectiveErrorRes.errorMsg = ex.getMessage();
            return objectiveErrorRes;
        }
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
                                FROM AsyncApexJob 
                                WHERE Id = :jobId];
        return jobInfo;
    }

    public class ObjectiveErrorResponse {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public Boolean error {get; set;}
        @AuraEnabled public String errorMsg {get; set;}
        @AuraEnabled public String batchId {get; set;}
    }
}