public class ctiCallWrapUpController {

   
	public String relObjId {get; set;}
    public String sObjType {get; set;}
    public String callResult {get; set;}
    public String callComments {get; set;}
    public String uniqueId {get; set;}
    public Boolean isOpen {get; set;}
    public Boolean updateBool {get; set;}
   
    
    public ctiCallWrapUpController(){
        relObjId = '';
        sObjType = '';
        callResult = '';
        callComments = '';
        uniqueId = '';
        isOpen = false;
        updateBool = true;
     
    }
    
    public void myMethod(){
        System.debug(sObjType);
        System.debug(callResult);
        System.debug(callComments);
        System.debug(uniqueId);
        System.debug(isOpen);
    }
    

    
    //taking in CRM Data and finding the correct outbound task
    public List<Task> CallTaskOut (){
        Id callRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        System.debug(sObjType);
        System.debug(relObjId);
        Date today = Date.today();
        String accountId;
        
        
        List<Task> tasksToUpdate = new List<Task>();
        
        //if the ISR calls from the account object
        if(sObjType == 'Account'){
            System.debug('type is account');
            tasksToUpdate = [SELECT Id, Subject, WhatId
                             FROM Task 
                             WHERE WhatId = :relObjId 
                             AND RecordTypeId = :callRecordTypeId
                             AND ActivityDate = :today
                             AND Status = 'Open'];
            accountId = relObjId;
            List<Task> ctiCreatedTasks = getTasksByUniqueId();
            if(!ctiCreatedTasks.isEmpty()){
                for(Task t : ctiCreatedTasks){
                    t.WhatId = relObjId;
                    tasksToUpdate.add(t);
                }
            }
            
        //if the ISR calls from the ACR
        } else if(sObjType == 'AccountContactRelation'){
            System.debug('type is account contact relation');
			AccountContactRelation acr = [SELECT AccountId 
                                          FROM AccountContactRelation 
                                          WHERE Id = :relObjId
                                          
                                          LIMIT 1];
            tasksToUpdate = [SELECT Id, Subject, WhatId
                             FROM Task 
                             WHERE WhatId = :acr.AccountId 
                             AND RecordTypeId = :callRecordTypeId
                             AND ActivityDate = :today
                             AND Status = 'Open'];
			accountId = acr.AccountId;
            
            List<Task> ctiCreatedTasks = getTasksByUniqueId();
            if(!ctiCreatedTasks.isEmpty()){
                for(Task t : ctiCreatedTasks){
                    t.WhatId = acr.AccountId;
                    tasksToUpdate.add(t);
                }
            }
        //if the ISR calls from the Contact record.
        } else if (sObjType == 'Contact'){
            System.debug('type is contact');
            List<AccountContactRelation> acr = [SELECT AccountId 
                                          FROM AccountContactRelation 
                                          WHERE ContactId = :relObjId
                                          ];
            if(acr.size() == 1){
            	tasksToUpdate = [SELECT Id, Subject, WhatId
                             	FROM Task 
                             	WHERE WhatId = :acr[0].AccountId 
                             	AND RecordTypeId = :callRecordTypeId
                             	AND ActivityDate = :today
                                AND Status = 'Open'];
            	accountId = acr[0].AccountId;
                
            	List<Task> ctiCreatedTasks = getTasksByUniqueId();
            	if(!ctiCreatedTasks.isEmpty()){
                	for(Task t : ctiCreatedTasks){
                    	t.WhatId = acr[0].AccountId;
                    	tasksToUpdate.add(t);
                	}
            	}
            //can't update based on ACR because there are more than one
            } else {
                updateBool = false;
            }
        
        
        } else {
            //for incoming calls
            tasksToUpdate = getTasksByUniqueId();
            for(Task t : tasksToUpdate){
                //if there is an account Id, update the What Id on the task.  Otherwise, the ISR will need to select using the link button
                if(accountId != null){
                    t.WhatId = accountId;
                }
            }
          
        }
        
        System.debug(accountId);
        //if for some reason, tasks are empty, get tasks by unique id.  May no longer need this...
        if(tasksToUpdate.isEmpty()){
            tasksToUpdate = getTasksByUniqueId();
            System.debug(tasksToUpdate);
            for(Task t: tasksToUpdate){
                if(accountId != null){
                    t.WhatId = accountId;
                }
            }
        }
        
        update tasksToUpdate;
        
        return tasksToUpdate;
    }
    
    
    public void onSave(){
    	System.debug('in the save action');
        System.debug(callComments);
        System.debug(callResult);
        updateBool = true;
        List<Task> tasks = CallTaskOut();
        if(tasks != null){
            for(Task t : tasks){
                System.debug(t.Id);
                t.Description = callComments;
                t.Call_Result__c = callResult;
            }
        }else{
            
            System.debug('there is not a task, so you prob need the unique id');
        }

        if(updateBool == true){
        	try {
        		update tasks;
        	} catch(Exception e) {
            	System.debug('The following exception has occurred: ' + e.getMessage());
        	}
        }
        
        isOpen = false;
        callResult = '';
        callComments = '';
        updateBool = false;
    }
    
     	//Get picklist options for Call Result field
    public List<selectoption> getCallResultOptions(){
        list<selectoption> callResults = new list<selectoption>();
        schema.DescribeFieldResult field = Task.Call_result__c.getdescribe();
        list<schema.picklistentry> picklist = field.getpicklistvalues();
        for(schema.picklistentry f: picklist){
            callResults.add(new Selectoption(f.getlabel(),f.getvalue()));
        }
        return callResults;
    }
    
	//Method that finds the CTI created task
    public List<Task> getTasksByUniqueId(){
        List<Task> t = [SELECT Id,
                         WhatId,
                 		 Call_Result__c,
                  		 Description,
                 		 CallObject,
                 		 cnx__UniqueId__c
                  FROM Task
                  WHERE cnx__UniqueId__c = :uniqueId];
        return t;
    }
  

}