@isTest
public class getTasksInvocableTest {
	@TestSetup
    public static void testData(){
        Task t = new Task();
        t.Subject = 'Test Subject For Invocable';
        t.ActivityDate = Date.today();
        t.Priority = 'High';
        t.Status = 'Open';
        insert t;
    }
    
    @isTest
    public static void testGetTaskInvocable(){
        List<Task> testTasks = [SELECT Id FROM Task WHERE Subject='Test Subject For Invocable'];
        List<String> idStrings = new List<String>();
        for(Task t : testTasks){
            idStrings.add(t.Id);
        }
        List<List<String>> idStringsList = new List<List<String>>();
        idStringsList.add(idStrings);
        
        
        List<List<Task>> tasks = getTasksInvocable.getTasks(idStringsList);
    }
}