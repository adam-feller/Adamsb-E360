public class BatchDeleteObjectiveSubmissions Implements Database.batchable<sobject> {

    public Database.QueryLocator start(Database.BatchableContext BC){        
        String open = 'Open';
        String query = 'SELECT Id FROM Objective_Submission__c WHERE Status__c =:' + open + ' AND Objective_Account__r.Objective__r.Days_Remaining__c < -4';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Objective_Submission__c> objectiveSubmissionList) {
		Integer objectiveSubmissionSize = objectiveSubmissionList.size();
        if(objectiveSubmissionSize > 0) {
            delete objectiveSubmissionList;
        }
    }

    public void finish(Database.BatchableContext BC){

    }

}