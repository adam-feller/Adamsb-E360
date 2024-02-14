public without sharing class BatchInsertAccountTeamsList implements Database.Batchable<sObject> {
    public List<AccountTeamMember> accountTeamMembersToInsert;
    public Set<Id> accountIds;

    public List<SObject> start(Database.BatchableContext context){
        return accountTeamMembersToInsert;
    }

    public void execute(Database.BatchableContext BC, List<AccountTeamMember> accountTeamMembersToInsert){
        try{
            AccountTeamMemberDAO.insertAccountTeamMembers(accountTeamMembersToInsert);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchInsertAccountTeamsList', 'execute');
        }
    }

    public void finish(Database.BatchableContext BC){
        List<Objective_Account__c> objectiveAccountsToUpdate = RouteAssignmentHandler.reassignObjectiveAccountOwners(accountIds);
        if(!objectiveAccountsToUpdate.isEmpty()){
            BatchReassignObjectiveAccountOwners batchReassignObjectiveAcc = new BatchReassignObjectiveAccountOwners();
            batchReassignobjectiveAcc.objectiveAccountsToUpdate = objectiveAccountsToUpdate;
            Database.executeBatch(batchReassignObjectiveAcc, 2000);
        }
    }
}