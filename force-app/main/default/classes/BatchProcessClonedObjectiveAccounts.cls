public class BatchProcessClonedObjectiveAccounts implements Database.Batchable<sObject>{
    public String query;
    public Id newObjectiveId;
    public Id clonedObjectiveId;

    public BatchProcessClonedObjectiveAccounts(){
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Objective_Account__c> objectiveAccountList){
        for(Objective_Account__c objAcc : objectiveAccountList){
            objAcc.id = null;
            objAcc.Status__c = 'Incomplete';
            objAcc.Objective__c = newObjectiveId;
        }

        if(!objectiveAccountList.isEmpty()){
            ObjectiveAccountDAO.insertObjectiveAccounts(objectiveAccountList);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}