public class BatchUpdateObjectives implements Database.Batchable<sObject> {
    public String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Objective__c> objectiveList) {    
		System.enqueueJob(new UpdateObjectivesQueueable(objectiveList));
    }

    public void finish(Database.BatchableContext BC) {
        
    }
}