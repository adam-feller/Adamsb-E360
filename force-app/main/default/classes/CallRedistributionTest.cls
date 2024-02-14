@isTest
public class CallRedistributionTest {
    
    @TestSetup
    private static void setup(){

        
        Warehouse__c testWarehouseCBS = TestFactory.createWarehouse('CBS Warehouse', UserInfo.getUserId(), 'CBS', null, null, null, null, null);
        Warehouse__c testWarehouseFlorida = TestFactory.createWarehouse('Florida', UserInfo.getUserId(), 'CBS', null, null, null, null, null);
        

        Account testAccountCBS1 = TestFactory.createAccount('Test AccountCBS1', '101', 'PVA', 'CBS Warehouse', null, '4444');
        Account testAccountCBS2 = TestFactory.createAccount('Test AccountCSB2', '201', 'PVA', 'CBS Warehouse', null, '5555');
        Account testAccountCBS3 = TestFactory.createAccount('Test AccountCSB3', '301', 'PVA', 'CBS Warehouse', null, '6666');
        
        Account testAccountFlorida1 = TestFactory.createAccount('Test AccountFlorida1', '101', 'PVA', 'Florida', null, '1111');
        Account testAccountFlorida2 = TestFactory.createAccount('Test AccountFlorida2', '201', 'PVA', 'Florida', null, '2222');
        Account testAccountFlorida3 = TestFactory.createAccount('Test AccountFlorida3', '301', 'PVA', 'Florida', null, '3333');
        
        List<Account> accountList = new List<Account>();
        testAccountCBS1.Delivery_Frequency_Type__c = 'Weekly';
        testAccountCBS1.Sell_Type__c = 'NATIONAL ACCTS';
        testAccountCBS1.Premise__c = 'On Premise';
        accountList.add(testAccountCBS1);
        testAccountCBS2.Delivery_Frequency_Type__c = 'Weekly';
        testAccountCBS2.Sell_Type__c = 'NATIONAL ACCTS';
        testAccountCBS2.Premise__c = 'On Premise';
        accountList.add(testAccountCBS2);
        testAccountCBS3.Delivery_Frequency_Type__c = 'Weekly';
        testAccountCBS3.Sell_Type__c = 'NATIONAL ACCTS';
        testAccountCBS3.Premise__c = 'On Premise';
        accountList.add(testAccountCBS3);
        testAccountFlorida1.Delivery_Frequency_Type__c = 'Weekly';
        testAccountFlorida1.Sell_Type__c = 'NATIONAL ACCTS';
        testAccountFlorida1.Premise__c = 'On Premise';
        accountList.add(testAccountFlorida1);
        testAccountFlorida2.Delivery_Frequency_Type__c = 'Weekly';
        testAccountFlorida2.Sell_Type__c = 'NATIONAL ACCTS';
        testAccountFlorida2.Premise__c = 'On Premise';
        accountList.add(testAccountFlorida2);
        testAccountFlorida3.Delivery_Frequency_Type__c = 'Weekly';
        testAccountFlorida3.Sell_Type__c = 'NATIONAL ACCTS';
        testAccountFlorida3.Premise__c = 'On Premise';
        accountList.add(testAccountFlorida3);
        update accountList;


        List<Task> tasksToInsert = new List<Task>();
        
        Task newTask1 = new Task();
        newTask1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        newTask1.OwnerId = UserInfo.getUserId();
        newTask1.subject = testAccountCBS1.Name;
        newTask1.ActivityDate = System.today();
        newTask1.WhatId = testAccountCBS1.Id;

        newTask1.Account__c = testAccountCBS1.Id;

        tasksToInsert.add(newTask1);
        
        Task newTask2 = new Task();
        newTask2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        newTask2.OwnerId = UserInfo.getUserId();
        newTask2.subject = testAccountCBS2.Name;
        newTask2.ActivityDate = System.today();
        newTask2.WhatId = testAccountCBS2.Id;

        newTask2.Account__c = testAccountCBS2.Id;

        tasksToInsert.add(newTask2);
        
        Task newTask3 = new Task();
        newTask3.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        newTask3.OwnerId = UserInfo.getUserId();
        newTask3.subject = testAccountCBS3.Name;
        newTask3.ActivityDate = System.today();
        newTask3.WhatId = testAccountCBS3.Id;

        newTask3.Account__c = testAccountCBS3.Id;

        tasksToInsert.add(newTask3);
        
        Task newTask4 = new Task();
        newTask4.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        newTask4.OwnerId = UserInfo.getUserId();
        newTask4.subject = testAccountFlorida1.Name;
        newTask4.ActivityDate = System.today();
        newTask4.WhatId = testAccountFlorida1.Id;

        newTask4.Account__c = testAccountFlorida1.Id;

        tasksToInsert.add(newTask4);
        
        Task newTask5 = new Task();
        newTask5.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        newTask5.OwnerId = UserInfo.getUserId();
        newTask5.subject = testAccountFlorida2.Name;
        newTask5.ActivityDate = System.today();
        newTask5.WhatId = testAccountFlorida2.Id;

        newTask5.Account__c = testAccountFlorida2.Id;

        tasksToInsert.add(newTask5);
        
        Task newTask6 = new Task();
        newTask6.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        newTask6.OwnerId = UserInfo.getUserId();
        newTask6.subject = testAccountFlorida3.Name;
        newTask6.ActivityDate = System.today();
        newTask6.WhatId = testAccountFlorida3.Id;

        newTask6.Account__c = testAccountFlorida3.Id;

        tasksToInsert.add(newTask6);
        
        insert tasksToInsert;	

    }
    
    @isTest
    public static void testEvenDistribution(){
        List<Warehouse__c> warehouseObjList = [Select id, Name FROM Warehouse__c];
        String warehousesString;
        
        for (Warehouse__c wrhse : WarehouseObjList){
            if(warehousesString == null){
                warehousesString = wrhse.Name;
           	}else{
				warehousesString = warehousesString + ';' + wrhse.name;
			}
        }
        
        List<Date> rescheduleDateList = new List<Date>{Date.newInstance(2021, 2, 2),Date.newInstance(2021, 2, 3), Date.newInstance(2021, 2, 4) };
        List<Integer> reschedulePercentagesList = new List<Integer>{33,33,34};
            
        List<CallRedistribution.CallRedistributionInputs> inputs = new List<CallRedistribution.CallRedistributionInputs>{new CallRedistribution.CallRedistributionInputs()} ;


        inputs[0].warehouses = warehousesString;
        inputs[0].originalDate = System.today();
        inputs[0].rescheduleDates = rescheduleDateList;
        inputs[0].reschedulePercentages = reschedulePercentagesList;
        inputs[0].selectCities = false;
        inputs[0].rescheduleReason = 'Other';
        inputs[0].summaryOnly = false;
        inputs[0].frequencies = 'Weekly;Daily';
        inputs[0].sellTypes = 'NATIONAL ACCTS';
        inputs[0].premises = 'On Premise';
        inputs[0].cities = new List<String>{'Chicago', 'Miami'};
        inputs[0].planName = 'Plan XXX'; 




        Test.startTest();
            CallRedistribution.redistributeCallsPerWarehouse(inputs);
        Test.stopTest();
        
        Date today = System.today();
        Date feb2 = Date.newInstance(2021, 2, 2);
        Date feb3 = Date.newInstance(2021, 2, 3);
        Date feb4 = Date.newInstance(2021, 2, 4);



        List<Task> feb2TaskList = [SELECT Id, ActivityDate, Account.Name, Account.Warehouse__c FROM Task WHERE ActivityDate = :feb2];
        List<Task> feb3TaskList = [SELECT Id, ActivityDate, Account.Name, Account.Warehouse__c FROM Task WHERE ActivityDate = :feb3];
        List<Task> feb4TaskList = [SELECT Id, ActivityDate, Account.Name, Account.Warehouse__c FROM Task WHERE ActivityDate = :feb4];

        System.assertEquals(2, feb2TaskList.size());
        System.assertEquals(2, feb3TaskList.size());       
        System.assertEquals(2, feb4TaskList.size());       

    }

}