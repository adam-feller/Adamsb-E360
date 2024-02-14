public with sharing class BatchCloseCallTasks implements Database.Batchable<sObject> {

    public String query;
    public Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
    public Date today = System.today();

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<task> taskList){
        try{
           System.debug('taskList' + taskList);
            for(task tsk : taskList){
                tsk.status = 'No order captured';
            }
            
            TaskDAO.updateTasks(taskList);

        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchCloseCallTasks', 'BatchCloseCallTasks.execute()');
        } 

    }

    public void finish(Database.BatchableContext BC){
    }

}