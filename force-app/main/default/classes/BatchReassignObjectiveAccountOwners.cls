public without sharing class BatchReassignObjectiveAccountOwners implements Database.Batchable<sObject> {
    public List<Objective_Account__c> objectiveAccountsToUpdate;

    public List<SObject> start(Database.BatchableContext context){
        return objectiveAccountsToUpdate;
    }

    public void execute(Database.BatchableContext BC, List<Objective_Account__c> objectiveAccountsToUpdate){
        try{
            ObjectiveAccountDAO.updateObjectiveAccounts(objectiveAccountsToUpdate);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchReassignObjectiveAccountOwners', 'execute');
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}