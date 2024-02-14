@isTest
public class tasksComponentControllerTest {
    @TestSetup
    public static void createDate(){
        
    	Task newTask = new Task();
        newTask.Subject = 'Test subject for my test class';
        newTask.Description = 'here are some comments';
        insert newTask;
        
        
    }
    
    @isTest
    public static void testTasksComponent(){
      
       
        
        Task testTask = [SELECT Id,
                         		Subject,
                         		OwnerId,
                         		Description,
                         		ActivityDate,
                         		Priority,
                         		Status
                         FROM Task
                         WHERE Subject = 'Test subject for my test class'];
        String taskId = String.valueOf(testTask.Id);
        tasksComponentController.thisTask(taskId);
        tasksComponentController.myPriorityPicklist();
        tasksComponentController.myStatusPicklist();
        tasksComponentController.updateTask(testTask.Id, 
                                            String.ValueOf(testTask.Subject), 
                                            String.ValueOf(testTask.OwnerId), 
                                            String.ValueOf(testTask.Description), 
                                            testTask.ActivityDate, 
                                            String.ValueOf(testTask.Priority), 
                                            String.ValueOf(testTask.Status)
                                           );
        
    }
    
        @isTest static void testCallout() {
        
        List<ListView> listViews = tasksComponentController.fetchListViewData();
            System.debug(listViews);
        Test.setMock(HttpCalloutMock.class, new MockListViewHttpResponseGenerator());
        
       Test.startTest();
        List<Task> res = tasksComponentController.fetchListViewFilters(listViews[0].Id);

    
        Test.stopTest();
    }

}