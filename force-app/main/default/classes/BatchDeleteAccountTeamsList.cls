public without sharing class BatchDeleteAccountTeamsList implements Database.Batchable<sObject> {
    public List<AccountTeamMember> accountTeamMembersToInsert;
    public List<AccountTeamMember> accountTeamMembersToDelete;
    public Set<Id> accountIds;

    public List<SObject> start(Database.BatchableContext context){
        return accountTeamMembersToDelete;
    }

    public void execute(Database.BatchableContext BC, List<AccountTeamMember> accountTeamMembersToDelete){
        try{
            AccountTeamMemberDAO.deleteAccountTeamMembers(accountTeamMembersToDelete);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchDeleteAccountTeamsList', 'execute');
        }
    }

    public void finish(Database.BatchableContext BC){
        BatchInsertAccountTeamsList batchInsertAccountTeam = new BatchInsertAccountTeamsList();
        batchInsertAccountTeam.accountTeamMembersToInsert = accountTeamMembersToInsert;
        batchInsertAccountTeam.accountIds = accountIds;
        Database.executeBatch(batchInsertAccountTeam, 2000);
    }
}