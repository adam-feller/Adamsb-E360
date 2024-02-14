global with sharing class tasksComponentController {
       
 	@AuraEnabled 
 	public static List<ListView> fetchListViewData(){
        
        return [
            SELECT Id,
            	   Name,
            	   DeveloperName,
            	   SObjectType
            FROM ListView
            WHERE SObjectType = 'Task'
            LIMIT 50
        ];
    }
    @AuraEnabled 
    public static List<Task> fetchListViewFilters(String filterId) {
            	List<Task> tasks = new List<Task>();
    	String query = '';
        String objectName = 'Task';
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String endPoinURL = 'callout:Reyes_Callout_Self_Loop/services/data/v50.0/sobjects/'+ objectName +'/listviews/'+ filterId +'/describe';
  
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        system.debug(req.getEndpoint());
        //req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        
        
        Http http = new Http();
        
        HttpResponse response = http.send(req);
        
        if( response.getStatusCode() == 200 ) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');
            System.debug(query);
            List<Task> filteredTasks = Database.query(query);
            for(Task t : filteredTasks){
                tasks.add(t);
            }
            
        }
        
        System.debug(response.getBody());
        
        return tasks;
	}
    
    @AuraEnabled 
    public static Task thisTask(String taskId){
	Task myTask = [SELECT Id,
                  		  Subject,
                   		  OwnerId,
                   		  Owner.Name,
                   		  Who.Name,
                   		  Description,
                   		  ActivityDate,
                          What.Name,
                   		  Priority,
                   		  Status,
                   		  IsReminderSet,
                   		  IsRecurrence,
                   		  RecurrenceRegeneratedType,
                   		  RecurrenceInterval,
                   		  CreatedBy.Name,
                   		  LastModifiedBy.Name,
                   		  Warehouse__c,
                   		  Accountnumber__c,
                   		  BU__c,
                   		  Type
                   
                  FROM Task
                  WHERE Id = :taskId
                  LIMIT 1
               ];
        
        return myTask;
                
            
        
    }
    
    @AuraEnabled
    public static List<String> myPriorityPicklist() {

      List<String> myPicklist = new List<String>();
      Schema.DescribeFieldResult field = Task.Priority.getDescribe();

      for (Schema.PicklistEntry f : field.getPicklistValues()){
        myPicklist.add(f.getLabel());
        }
	System.debug('heres my picklist');
    System.debug(myPicklist);
        

    return myPicklist;          
  
	}
    
    @AuraEnabled   
    public static List<String> myStatusPicklist() {
  
    

      List<String> myPicklist = new List<String>();
      Schema.DescribeFieldResult field = Task.Status.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues()){
        myPicklist.add(f.getLabel());
        }
	System.debug('heres my picklist');
    System.debug(myPicklist);
        

    return myPicklist;          
  
	}
    
    @AuraEnabled
    public static Task updateTask(String taskId, 
                                  String Subject, 
                                  String OwnerId, 
                                  String Comments, 
                                  Date DueDate, 
                                  String Priority, 
                                  String Status){
        Task myTask = [SELECT Id,
                      		  Subject,
                       		  Owner.Name,
                       		  What.Name,
                      		  OwnerId,
                         	  Description,
                      		  ActivityDate,
                      		  Priority,
                      		  Status,
                              Who.Name,
                   		  	  IsReminderSet,
                   		  	  IsRecurrence,
                   		  	  RecurrenceRegeneratedType,
                   		  	  RecurrenceInterval,
                   		  	  CreatedBy.Name,
                   		  	  LastModifiedBy.Name
                       		  
                       FROM Task
                       WHERE Id = :taskId
                       LIMIT 1];
        User owner = [SELECT Name
                      FROM User
                      WHERE Id = :myTask.OwnerId];
                                      
        myTask.Subject = Subject;
        myTask.OwnerId = OwnerId;
        myTask.Description = Comments;
        myTask.ActivityDate = DueDate;
        myTask.Priority = Priority;
        myTask.Status = Status;
                                      
                                      System.debug('this is the owner name');
                                      System.debug(myTask.Owner.Name);
        
        update myTask;
        
        return myTask;
    } 
    
}