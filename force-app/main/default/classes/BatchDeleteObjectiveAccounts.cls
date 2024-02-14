public class BatchDeleteObjectiveAccounts implements Database.Batchable<sObject>{
    public String query;
    public String objectiveId;
    public Set<Id> selectedAccountIds = new Set<Id>();

    public BatchDeleteObjectiveAccounts() {
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Objective_Account__c> objectiveAccountList) {
        try{
            List<Objective_Account__c> objectiveAccountsToDelete = new List<Objective_Account__c>();
            for(Objective_Account__c objAcc : objectiveAccountList){
                if(!selectedAccountIds.contains(objAcc.Account__c) && objAcc.Manual_Account_Upload__c != true){
                	//Adding a safety precaution here, only add to delete if the Objective Account has not had activity (i.e., Objective Submission created, only applies to Price Feature, Reset and Display objectives)
	                if ((objAcc.Objective_Type__c != 'Price Feature' && objAcc.Objective_Type__c != 'Reset' && objAcc.Objective_Type__c != 'Display') || (objAcc.Status__c == 'Incomplete' && objAcc.Completed_Count__c == 0)) {
                    	objectiveAccountsToDelete.add(objAcc);
                    }
                }
            }

            if(!objectiveAccountsToDelete.isEmpty()) {
                ObjectiveAccountDAO.deleteObjectiveAccounts(objectiveAccountsToDelete);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchDeleteObjectiveAccounts', 'BatchDeleteObjectiveAccounts.execute()');
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}