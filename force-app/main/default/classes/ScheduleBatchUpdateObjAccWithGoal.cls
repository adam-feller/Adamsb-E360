public class ScheduleBatchUpdateObjAccWithGoal implements Schedulable {

    public void execute(SchedulableContext sc) {
        Set<Id> objectiveIds = new Set<Id>();
        List<Objective__c> objectiveList = ObjectiveDAO.getObjectiveByStatusReadyForExecution();
        for(Objective__c obj : objectiveList){
            objectiveIds.add(obj.Id);
        }

        if(!objectiveIds.isEmpty()){
            List<Objective_Goal__c> objectiveGoalList = ObjectiveGoalDAO.getObjectiveGoalsByObjectiveIds(objectiveIds);
            Map<Id, Map<Id, Id>> objGoalUserMap = new Map<Id, Map<Id, Id>>();
            for(Objective_Goal__c objGoal : objectiveGoalList){
                Map<Id, Id> userGoalMap = new Map<Id, Id>();
                if(objGoalUserMap.containsKey(objGoal.Objective__c)){
                    userGoalMap = objGoalUserMap.get(objGoal.Objective__c);
                }
                userGoalMap.put(objGoal.Goal_Assignee__c, objGoal.Id);
                objGoalUserMap.put(objGoal.Objective__c, userGoalMap);
            }
            BatchUpdateObjectiveAccWithGoal batchObjAccUpdateGoal = new BatchUpdateObjectiveAccWithGoal();
            batchObjAccUpdateGoal.query = 'SELECT Id, Objective__c, Account__c, Account__r.OwnerId' +
                                        ' FROM Objective_Account__c' + 
                                        ' WHERE Objective__c IN :objectiveIds';
            batchObjAccUpdateGoal.objGoalUserMap = objGoalUserMap;
            batchObjAccUpdateGoal.objectiveIds = objectiveIds;
            Database.executebatch(batchObjAccUpdateGoal);
        }
    }
}