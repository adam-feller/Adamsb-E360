public with sharing class ScheduleBatchDeleteOldTasks implements Schedulable {
      public void execute(SchedulableContext sc) {
      BatchDeleteOldTasks BDOT = new BatchDeleteOldTasks();
	  Database.executeBatch(BDOT);
   }
}