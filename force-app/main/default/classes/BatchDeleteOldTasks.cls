public class BatchDeleteOldTasks Implements Database.batchable<sobject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        date sixtyDaysAgo = date.today().addDays(-60);
        String status = 'Open';
        String outBound = '%Outbound%';
        String query = 'Select ActivityDate,Id,Status,Subject FROM Task WHERE ActivityDate < :sixtyDaysAgo AND Status = :status AND Subject LIKE :outBound';
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Task> taskList){
		Integer taskListSize = taskList.size();
        system.debug('taskListSize: ' + taskListSize);
        if(taskListSize > 0){
            delete taskList;
        }
    }

    public void finish(Database.BatchableContext BC){

    }
}