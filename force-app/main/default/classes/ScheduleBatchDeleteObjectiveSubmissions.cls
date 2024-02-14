public with sharing class ScheduleBatchDeleteObjectiveSubmissions implements Schedulable{
   public void execute(SchedulableContext sc) {
      BatchDeleteObjectiveSubmissions BDOD = new BatchDeleteObjectiveSubmissions();
	  Database.executeBatch(BDOD);
   }
}