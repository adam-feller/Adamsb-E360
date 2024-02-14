@isTest
public class BatchDeleteOldTasksTest {
    @TestSetup
   private static void setup(){
       List<Task> TaskList = new List<Task>();
       for(integer i = 0; i < 100; i++){
        Task testTask = new Task();
        date myDate = date.today().addDays(-65);
        testTask.ActivityDate = myDate;
        testTask.Status = 'Open';
        testTask.Subject = 'Outbound Call';
        TaskList.add(testTask);
       }
       insert TaskList;
       
    }
    
      @isTest
    static void testBatchDeleteObjectiveDisplaysList(){
		List<Task> tskl = [Select ActivityDate,Id,Status,Subject
					FROM Task
					WHERE Subject LIKE '%Outbound%'];
        System.assertEquals(tskl.size(), 100, 'There should be 100 tasks');
        
        Test.startTest();
           BatchDeleteOldTasks obj = new BatchDeleteOldTasks();
		   Database.executeBatch(obj);
        Test.stopTest();
        
        List<Task> tskl2 = [Select ActivityDate,Id,Status,Subject
					FROM Task
					WHERE Subject LIKE '%Outbound%'];
        System.assertEquals(tskl2.size(), 0, 'There should be 0 tasks');
    }

}