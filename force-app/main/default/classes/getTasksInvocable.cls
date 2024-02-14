public class getTasksInvocable {
    
	@InvocableMethod(label='Get Tasks' 
                 	 description='Returns the list of account names corresponding to the specified account IDs.' 
                   	 category='Task')
    
  	public static List<List<Task>> getTasks(List<List<String>> taskIds) {
    	List<Task> filteredTasks = new List<Task>();
        List<List<Task>> returnTasks = new List<List<Task>>();
		
        List<String> myIds = new List<String>();
        
        for(List<String> lst : taskIds){
            for(String s: lst){
                myIds.add(s);
            }
        }
        
        List<Task> tasks = [SELECT Subject, Id, OwnerId FROM Task WHERE Id IN :myIds];
        returnTasks.add(tasks);
    	
        return returnTasks;
	}
}