@isTest
public class TaskTriggerHelperTest {
    
    @TestSetup
    private static void setup() {
        
        //Create new Survey
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        //Create Store Visit Record
        CVS_Store_Visit__c sv = new CVS_Store_Visit__c();
        Date todayDate = Date.today();
        sv.Account__c = testAccount.Id;
        sv.Scheduled_Arrival__c = DateTime.newInstance(todayDate, Time.newInstance(0, 0, 0, 0));
        sv.Scheduled_Departure__c = DateTime.newInstance(todayDate, Time.newInstance(1, 0, 0, 0));
        insert sv;

    }
    //tests if one Store Visit is updated from a checkin Taskk
    @isTest
    static void testCheckIn() {  
        
        Account a = [SELECT Id FROM Account LIMIT 1];
        //Insert Task
        Task t = new Task();
        t.WhatId = a.Id;
        t.Subject = 'Check In @ Test Account';
        t.Status = 'Open';
        
        Test.startTest();
        insert t;
        Test.stopTest();

        Task task = [SELECT Id, CreatedDate FROM Task LIMIT 1];
        CVS_Store_Visit__c sv = [SELECT Id, Actual_Arrival__c FROM CVS_Store_Visit__c LIMIT 1];
        System.assertEquals(sv.Actual_Arrival__c, task.CreatedDate, 'Incorrect Actual Arrival DateTime');
    }
    //tests when there are two Store Visits on the same day for the same Account
    @isTest
    static void testCheckInTwoRecords() {  
        
        DateTime currentDateTime = Datetime.now();
        Account a = [SELECT Id FROM Account LIMIT 1];
        //Insert additional Store Visit
        CVS_Store_Visit__c sv = new CVS_Store_Visit__c();
        sv.Account__c = a.Id;
        sv.Scheduled_Arrival__c = currentDateTime;
        sv.Scheduled_Departure__c = currentDateTime.addHours(1);
        insert sv;

        //Insert Task
        Task t = new Task();
        t.WhatId = a.Id;
        t.Subject = 'Check In @ Test Account';
        t.Status = 'Open';
        
        Test.startTest();
        insert t;
        Test.stopTest();

        Task task = [SELECT Id, CreatedDate FROM Task LIMIT 1];
        CVS_Store_Visit__c storeVisit = [SELECT Id, Actual_Arrival__c, Scheduled_Arrival__c FROM CVS_Store_Visit__c WHERE Actual_Arrival__c != null LIMIT 1];
        System.assertEquals(storeVisit.Actual_Arrival__c, task.CreatedDate, 'Incorrect Actual Arrival DateTime');
        System.assertEquals(storeVisit.Scheduled_Arrival__c, currentDateTime, 'Incorrect Store Visit');
        CVS_Store_Visit__c storeVisit2 = [SELECT Id, Actual_Arrival__c, Scheduled_Arrival__c FROM CVS_Store_Visit__c WHERE Actual_Arrival__c = null LIMIT 1];
        System.assertEquals(storeVisit2.Actual_Arrival__c, null, 'Incorrect Store Visit');
    }
    //tests when there are two Store Visits on the same day for the same Account
    @isTest
    static void testCheckOut() {  
    
        DateTime currentDateTime = Datetime.now();
        Account a = [SELECT Id FROM Account LIMIT 1];

        //Insert Task
        Task t = new Task();
        t.WhatId = a.Id;
        t.Subject = 'Check In @ Test Account';
        t.Status = 'Open';
        insert t;
        //Update Task
        t.Status = 'Completed';
        
        Test.startTest();
        update t;
        Test.stopTest();

        Task task = [SELECT Id, CreatedDate, LastModifiedDate FROM Task LIMIT 1];
        CVS_Store_Visit__c storeVisit = [SELECT Id, Actual_Arrival__c, Scheduled_Arrival__c, Actual_Departure__c FROM CVS_Store_Visit__c LIMIT 1];
        System.assertEquals(storeVisit.Actual_Departure__c, task.LastModifiedDate, 'Incorrect Actual Departure Visit');
    }
}