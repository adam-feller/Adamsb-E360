public class BatchUpdateObjectiveAccWithGoal implements Database.Batchable<sObject> {
    public String query;
    public Map<Id, Map<Id, Id>> objGoalUserMap;
    public Set<Id> objectiveIds;

    public BatchUpdateObjectiveAccWithGoal() {
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Objective_Account__c> objAccList){
        try{
            List<Objective_Account__c> updateObjectiveAccountList = new List<Objective_Account__c>();
            for(Objective_Account__c objAcc : objAccList){
                if(objAcc.Objective__c != null){
                    if(objGoalUserMap.containsKey(objAcc.Objective__c)){
                        Map<Id, Id> userGoalMap = objGoalUserMap.get(objAcc.Objective__c);
                        if(objAcc.Account__c != null){
                            if(userGoalMap.containsKey(objAcc.Account__r.OwnerId)){
                                objAcc.Objective_Goal__c = userGoalMap.get(objAcc.Account__r.OwnerId);
                                updateObjectiveAccountList.add(objAcc);
                            }
                        }
                    }
                }
            }

            if(!updateObjectiveAccountList.isEmpty()){
                ObjectiveAccountDAO.updateObjectiveAccounts(updateObjectiveAccountList);
            }

            List<Objective__c> objectivesToUpdateList = new List<Objective__c>();
            for(Id objId : objectiveIds){
                Objective__c testObj = new Objective__c();
                testObj.Id = objId;
                testObj.Processed__c = true;
                objectivesToUpdateList.add(testObj);
            }

            if(!objectivesToUpdateList.isEmpty()){
                ObjectiveDAO.updateObjectives(objectivesToUpdateList);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchUpdateObjectiveAccWithGoal', 'BatchUpdateObjectiveAccWithGoal.execute()');
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}