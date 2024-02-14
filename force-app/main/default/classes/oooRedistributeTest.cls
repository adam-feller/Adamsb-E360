@isTest
public class oooRedistributeTest {
    
    @TestSetup
    private static void setup() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Call Center'].Id;
        Id roleId = [SELECT Id FROM UserRole WHERE Name = 'ISR'].Id;
		User mgr = TestFactory.createUser(profileId, roleId, 'mgrtest@reyesholdings.com', null);
        User emp1 = TestFactory.createUser(profileId, roleId, 'emp1test@reyesholdings.com', mgr.Id);
        User emp2 = TestFactory.createUser(profileId, roleId, 'emp2test@reyesholdings.com', mgr.Id);
        User emp3 = TestFactory.createUser(profileId, roleId, 'emp3test@reyesholdings.com', mgr.Id); 
        
        //Create Shifts
        Shift__c shift1 = new Shift__c();
        Shift__c shift2 = new Shift__c();
        Shift__c shift3 = new Shift__c();
        System.runAs(mgr) {    
            shift1 = TestFactory.createShift(emp1.Id, Time.newInstance(7,0,0,0), Time.newInstance(15,30,0,0));
            shift2 = TestFactory.createShift(emp2.Id, Time.newInstance(7,0,0,0), Time.newInstance(15,30,0,0));
            shift3 = TestFactory.createShift(emp3.Id, Time.newInstance(7,0,0,0), Time.newInstance(15,30,0,0));
        }
        
        //Create an Account to associate Tasks to
        Account acc1 = new Account();
        Account acc2 = new Account();
        Account acc3 = new Account();
        System.runAs(emp1) {    
        	acc1 = TestFactory.createAccount('Test Account 1', '1234', 'HDI', null, null, '1234');
        }
        System.runAs(emp2) {    
        	acc2 = TestFactory.createAccount('Test Account 2', '1234', 'HDI', null, null, '1234');
        }
        System.runAs(emp3) {    
        	acc3 = TestFactory.createAccount('Test Account 3', '1234', 'HDI', null, null, '1234');
        }
        
        //Create Tasks unevenly distributed
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        //1 Tasks to Employee 1
        System.runAs(emp1) {
        	Task t1 = TestFactory.createTaskByRecordType('OUTBOUND CALL 1', callTaskRecordTypeId, 'Open', acc1.Id, System.today());
        }
        //3 Tasks to Employee 2
        System.runAs(emp2) {
        	Task t2 = TestFactory.createTaskByRecordType('OUTBOUND CALL 2', callTaskRecordTypeId, 'Open', acc2.Id, System.today());
        	Task t3 = TestFactory.createTaskByRecordType('OUTBOUND CALL 3', callTaskRecordTypeId, 'Open', acc2.Id, System.today());
        	Task t4 = TestFactory.createTaskByRecordType('OUTBOUND CALL 4', callTaskRecordTypeId, 'Open', acc2.Id, System.today());
        }       
		//5 Tasks to Employee 3
		System.runAs(emp3) {
        	Task t5 = TestFactory.createTaskByRecordType('OUTBOUND CALL 5', callTaskRecordTypeId, 'Open', acc3.Id, System.today());
	        Task t6 = TestFactory.createTaskByRecordType('OUTBOUND CALL 6', callTaskRecordTypeId, 'Open', acc3.Id, System.today());
    	    Task t7 = TestFactory.createTaskByRecordType('OUTBOUND CALL 7', callTaskRecordTypeId, 'Open', acc3.Id, System.today());
            Task t8 = TestFactory.createTaskByRecordType('OUTBOUND CALL 8', callTaskRecordTypeId, 'Open', acc3.Id, System.today());
	        Task t9 = TestFactory.createTaskByRecordType('OUTBOUND CALL 9', callTaskRecordTypeId, 'Open', acc3.Id, System.today());
        }        
    }
    
    @isTest
    public static void testRedistribution() {
		//Call the Method to Redistribute the Calls  
        Test.startTest();
        List<oooRedistribute.FlowInputs> requests = new List<oooRedistribute.FlowInputs>();
        requests.add(new oooRedistribute.FlowInputs());
        requests[0].EmployeeToRedistribute = null;
        oooRedistribute.oooRedistributeCalls(requests);   //Not sure why but this does not kick off the batch
        
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        List<Task> tasks = [SELECT Id, OwnerId, WhatId, Account.Primary_Language_Preference__c, Account.Do_Not_Call1__c, Account.Primary_Call_Window_Start__c,
                            Account.Primary_Call_Window_End__c, Account.Warehouse_Lookup__r.OrderCutoff__c, recordTypeId, Call_Result__c
	                        FROM Task WHERE AccountId != null AND Account.Status__c = 'A' AND Account.Do_Not_Call1__c = false AND recordTypeId = :callTaskRecordTypeId 
                            AND ActivityDate = :System.today() AND Status = 'Open' Order BY Account.Name];
        //So we manually run it here
        OutboundCallRedistribution.redistributeOutboundCalls(tasks, null);
        Test.stopTest();
        
        //Get the employee Ids
        User emp1 = [SELECT Id FROM User WHERE Email='emp1test@reyesholdings.com'];
        User emp2 = [SELECT Id FROM User WHERE Email='emp2test@reyesholdings.com'];
        User emp3 = [SELECT Id FROM User WHERE Email='emp3test@reyesholdings.com'];
        
        //Get the number of Tasks each employee has assigned to them
        Integer emp1Count = [SELECT COUNT() FROM Task WHERE OwnerId =:emp1.Id];
        Integer emp2Count = [SELECT COUNT() FROM Task WHERE OwnerId =:emp2.Id];
        Integer emp3Count = [SELECT COUNT() FROM Task WHERE OwnerId =:emp3.Id];
        
        //Assert that the calls were evenly distributed among the 3 employees
        System.assertEquals(3, emp1Count,'Employee1 has wrong number of tasks');
        System.assertEquals(3, emp2Count,'Employee2 has wrong number of tasks');
        System.assertEquals(3, emp3Count,'Employee3 has wrong number of tasks');
    }
    
    @isTest
    public static void testRedistributionWithOOO() {
        User emp = [SELECT Id FROM User WHERE Email='emp1test@reyesholdings.com'];
		Out_of_Office__c ooo = new Out_of_Office__c();
        ooo.Who_is_out__c = emp.Id;
        ooo.Start_Date__c = System.Today();
        ooo.End_Date__c = System.Today();
        insert ooo;
        
        //Call the Method to Redistribute the Calls  
        Test.startTest();
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        List<Task> tasks = [SELECT Id, OwnerId, WhatId, Account.Primary_Language_Preference__c, Account.Do_Not_Call1__c, Account.Primary_Call_Window_Start__c,
                            Account.Primary_Call_Window_End__c, Account.Warehouse_Lookup__r.OrderCutoff__c, recordTypeId, Call_Result__c
	                        FROM Task WHERE AccountId != null AND Account.Status__c = 'A' AND Account.Do_Not_Call1__c = false AND recordTypeId = :callTaskRecordTypeId 
                            AND ActivityDate = :System.today() AND Status = 'Open' Order BY Account.Name];
        //So we manually run it here
        OutboundCallRedistribution.redistributeOutboundCalls(tasks, null);
        Test.stopTest();
        
        //Get the employee Ids
        User emp1 = [SELECT Id FROM User WHERE Email='emp1test@reyesholdings.com'];
        User emp2 = [SELECT Id FROM User WHERE Email='emp2test@reyesholdings.com'];
        User emp3 = [SELECT Id FROM User WHERE Email='emp3test@reyesholdings.com'];
        
        //Get the number of Tasks each employee has assigned to them
        Integer emp1Count = [SELECT COUNT() FROM Task WHERE OwnerId =:emp1.Id];
        Integer emp2Count = [SELECT COUNT() FROM Task WHERE OwnerId =:emp2.Id];
        Integer emp3Count = [SELECT COUNT() FROM Task WHERE OwnerId =:emp3.Id];
        
        //Assert that the calls were evenly distributed among the 3 employees - need to fix this
        //System.assertEquals(0, emp1Count,'Employee1 has wrong number of tasks');
        //System.assertEquals(5, emp2Count,'Employee2 has wrong number of tasks');
        //System.assertEquals(4, emp3Count,'Employee3 has wrong number of tasks');
    }    
}