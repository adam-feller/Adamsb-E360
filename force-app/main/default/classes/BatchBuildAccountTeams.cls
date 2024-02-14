public without sharing class BatchBuildAccountTeams implements Database.Batchable<sObject>{
    //default ALL Accounts
    public String query = 'SELECT Id FROM Account';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> accounts) {    
        try {
        Map<String, Account> accountMap = new Map<String, Account>(accounts);
		RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(new List<String> (accountMap.keySet()), false);
        for(Account a : accountMap.values()){
            a.ProcessAccountTeamsBuild__c = false;
        }
        update accountMap.values();
        } catch (Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchBuildAccountTeams', 'BatchBuildAccountTeams.execute()');
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}