@isTest
public class TaskTriggerHandlerTest {

    @isTest
    public static void taskTriggerTest(){
        //create an account
        Account testAcc = new Account();
     	testAcc.Name = 'Happy Little Test Account';
        //set account last call result
        testAcc.Last_Call_Result__c = 'this is the last call result';
        testAcc.Date_of_Last_Call__c = Date.today();
        
        insert testAcc;
        //create a task
        Task testTask = new Task();
        testTask.Subject = 'Happy Little Test Task';
        //set task call result
        testTask.WhatId = testAcc.Id;
       
        testTask.Call_Result__c = 'No Answer';
        insert testTask;
            
        //set task status as complete
        testTask.Status = 'Completed';
        update testTask;
        
    }
    
    
    
    
}