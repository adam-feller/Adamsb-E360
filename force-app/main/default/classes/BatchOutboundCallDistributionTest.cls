@isTest
private class BatchOutboundCallDistributionTest {


    @TestSetup
    static void setup(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile callCenterProfile = [SELECT Id FROM Profile WHERE Name = 'Call Center'];
        UserRole managerRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        UserRole isrRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin'];
        User adminManager = TestFactory.createUser(adminProfile.Id, managerRole.Id, 'mr1Manager@gmail.com', null);

        System.runAs(adminManager){
            //Insert Users
            List<User> usersToInsert = new List<User>();
            for(Integer i=0; i<6; i++){
                User testUser = new User();
                testUser.ProfileId = callCenterProfile.Id;
                testUser.UserName = i+'-callCenter@gmail.com';
                testUser.Email = i+'-callCenter@gmail.com';
                testUser.EmailenCodingKey = 'UTF-8';
                testUser.LocalesIdKey = 'en_US';
                testUser.LanguageLocaleKey = 'en_US';
                testUser.TimeZonesIdKey = 'America/Los_Angeles';
                testUser.Alias = 'extUser';
                testUser.FirstName = 'Test';
                testUser.LastName = 'User';
                testUser.VIP_Company__c = 'HDI';
                testUser.UserRoleId = isrRole.Id;
                if (i == 0) {
                    testUser.Spanish_Bilingual__c = true;   //Set one user to be Spanish Bilingual
                }
                usersToInsert.add(testUser);
            }
            insert usersToInsert;

            //Insert Shifts
            List<Shift__c> shiftsToInsert = new List<Shift__c>();
            for(Integer i=0; i<6; i++){
                Shift__c testShift = new Shift__c();
                testShift.Employee__c = usersToInsert[i].Id;
                testShift.Start_Time__c = Time.newInstance(7, 0, 0, 0);
                testShift.End_Time__c = Time.newInstance(15, 30, 0, 0);
                shiftsToInsert.add(testShift);
            }
            insert shiftsToInsert;                       

            //Insert Warehouses
            List<Warehouse__c> warehousesToInsert = new List<Warehouse__c>();
            for(Integer k=0; k<3; k++){
                Warehouse__c testWarehouse = new Warehouse__c();
                testWarehouse.Name = k + '-Warehouse';
                testWarehouse.ISR_1__c = usersToInsert[k].Id;
                testWarehouse.Warehouse_ID__c = k + '-Warehouse';
                testWarehouse.OrderCutoff__c = Time.newInstance(16, 0, 0, 0);
                warehousesToInsert.add(testWarehouse);
            }
            insert warehousesToInsert;

			//Insert Contacts
            List<Contact> contactsToInsert = new List<Contact>();
            for(Integer l=0; l<warehousesToInsert.size(); l++){
                for(Integer j=0; j<80; j++){
                    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                    
                    Contact testContact = new Contact();
                    testContact.FirstName = 'Ms.' + String.valueOf(j)+String.valueOf(l)+' Tester'+String.ValueOf(randomInt);
                    testContact.LastName = 'McTest'+String.ValueOf(randomInt) ;   
					testContact.Call_Window_Start__c = Time.newInstance(10,0,0,0);
                    testContact.Call_Window_End__c = Time.newInstance(11,0,0,0);
					testContact.Phone = String.valueOF(Integer.valueOf(math.rint(math.random()*1000000000)));
                    contactsToInsert.add(testContact);
                }
            }            
            insert contactsToInsert;

			//Insert Accounts
            List<Account> accountsToInsert = new List<Account>();
            for(Integer l=0; l<warehousesToInsert.size(); l++){
                for(Integer j=0; j<80; j++){
                    Account testAccount = new Account();
                    testAccount.Name = String.valueOf(j)+String.valueOf(l)+'-Retail Liqour Store' ;
                    testAccount.Account_Type__c = 'None';
                    testAccount.VIP_Account_Number__c = String.valueOf(j)+String.valueOf(l);
                    testAccount.VIP_Instance__c = 'PVA';
                    testAccount.ExternalId__c = '72245';
                    testAccount.Primary_POC__c = contactsToInsert[j].Id;
                    testAccount.Chain__c = 'FOOD LION';
                    testAccount.Warehouse__c = warehousesToInsert[l].Name;
                    testAccount.Store_Number__c = String.valueOf(j)+String.valueOf(l);
                    testAccount.Territories__c = '10';
                    testAccount.Status__c = 'A';
                    accountsToInsert.add(testAccount);
                }
            }
            insert accountsToInsert;

			//Insert Tasks
            List<Task> tasksToInsert = new List<Task>();
            for(Integer m=0; m<67; m++){
                Task newTask = new Task();
                newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
                newTask.OwnerId = usersToInsert[0].Id;
                newTask.Subject = accountsToInsert[m].Name;
                newTask.ActivityDate = System.today();
                newTask.WhatId = accountsToInsert[m].Id;
                tasksToInsert.add(newTask);
            }

            for(Integer m=67; m<168; m++){
                Task newTask = new Task();
                newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
                newTask.OwnerId = usersToInsert[1].Id;
                newTask.Subject = accountsToInsert[m].Name;
                newTask.ActivityDate = System.today();
                newTask.WhatId = accountsToInsert[m].Id;
                tasksToInsert.add(newTask);
            }

            for(Integer m=168; m<240; m++){
                Task newTask = new Task();
                newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
                newTask.OwnerId = usersToInsert[2].Id;
                newTask.Subject = accountsToInsert[m].Name;
                newTask.ActivityDate = System.today();
                newTask.WhatId = accountsToInsert[m].Id;
                tasksToInsert.add(newTask);
            }
            insert tasksToInsert;

            List<AggregateResult> taskByOwnerResults = [SELECT Owner.Username, COUNT(Id) FROM Task GROUP BY Owner.Username ];
        }
    }


    @isTest
    static void testNonSpanishCallDistribution(){
        Test.startTest();
		BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
		batchCallDistribution.empId = null;
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 10000);
        test.stopTest();

        //Assert that the tasks were distributed evenly
        List<AggregateResult> taskByOwnerResults = [SELECT Owner.Username, COUNT(Id) FROM Task GROUP BY Owner.Username];
        System.assertEquals(40, taskByOwnerResults[0].get('expr0'));
        System.assertEquals(40, taskByOwnerResults[1].get('expr0'));
        System.assertEquals(40, taskByOwnerResults[2].get('expr0'));
        System.assertEquals(40, taskByOwnerResults[3].get('expr0'));
        System.assertEquals(40, taskByOwnerResults[4].get('expr0'));
        System.assertEquals(40, taskByOwnerResults[5].get('expr0'));
    }

    @isTest
    static void testOutOfOffice(){
		//Create some Out of Offices for the Test Users
		User oooUser = [SELECT Id FROM User WHERE email = '0-callCenter@gmail.com' LIMIT 1];
        User oooUser2 = [SELECT Id FROM User WHERE email = '1-callCenter@gmail.com' LIMIT 1];
        User oooUser3 = [SELECT Id FROM User WHERE email = '2-callCenter@gmail.com' LIMIT 1];
        
        DateTime currentDateTime = System.now();
        DateTime startDate = Datetime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day(), 6, 0, 0);
        DateTime endDate = Datetime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day(), 18, 0, 0);
        
        //Starts before Today
        Out_of_Office__c ooo = new Out_of_Office__c(Name='PTO', Who_is_Out__c = oooUser.Id, Start_Date__c = startDate.addDays(-1), End_Date__c = endDate);
        insert ooo;
        //Only for Today
        Out_of_Office__c ooo2 = new Out_of_Office__c(Name='PTO', Who_is_Out__c = oooUser2.Id, Start_Date__c = startDate, End_Date__c = endDate);
        insert ooo2;
        //Ends after Today
        Out_of_Office__c ooo3 = new Out_of_Office__c(Name='PTO', Who_is_Out__c = oooUser3.Id, Start_Date__c = startDate, End_Date__c = endDate.addDays(1));
        insert ooo3;
        
        test.startTest();
		BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
		batchCallDistribution.empId = null;
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 10000);
        test.stopTest();
        
        //Assert that the Out of Office Users were assigned 0 tasks and the others were assigned evenly (80)
        List<AggregateResult> taskByOwnerResults = [SELECT Owner.Username, COUNT(Id) FROM Task GROUP BY Owner.Username];        
        System.assertEquals(80, taskByOwnerResults[0].get('expr0'));
        System.assertEquals(80, taskByOwnerResults[1].get('expr0'));
        System.assertEquals(80, taskByOwnerResults[2].get('expr0'));
    }
    
    @isTest
    static void testOutOfOfficePartialDay(){
		//Create some Out of Offices for the Test Users
		User oooUser = [SELECT Id FROM User WHERE email = '0-callCenter@gmail.com' LIMIT 1];
        
        DateTime currentDateTime = System.now();
        DateTime startDate = Datetime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day(), 6, 0, 0);
        DateTime endDate = Datetime.newInstance(currentDateTime.year(), currentDateTime.month(), currentDateTime.day(), 12, 0, 0);
        
		//Out for only part of the shift
        Out_of_Office__c ooo = new Out_of_Office__c(Name='PTO', Who_is_Out__c = oooUser.Id, Start_Date__c = startDate, End_Date__c = endDate);
        insert ooo;
        
        test.startTest();
		BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
		batchCallDistribution.empId = null;
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 10000);
        test.stopTest();
        
        //Assert that the user with less hours in their shift gets half or less that the other employees get
        List<AggregateResult> taskByOwnerResults = [SELECT Owner.Username, COUNT(Id) FROM Task GROUP BY Owner.Username];        
        System.assert(Integer.valueOf(taskByOwnerResults[0].get('expr0')) <= Integer.valueOf(taskByOwnerResults[1].get('expr0'))/2);
    }    
   
    @isTest
    static void testMismatchedLanguage(){        
        //Update 1 Primary Contact to be Spanish
        Contact spanishContact = [SELECT Id FROM Contact WHERE Name LIKE 'Ms.790 Tester%' LIMIT 1];
        spanishContact.Language__c = 'Spanish';
        update spanishContact;
                
        test.startTest();
		BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
		batchCallDistribution.empId = null;
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 10000);
        test.stopTest();
        
        //Assert that the Spanish Account's Tasks are assigned to the Spanish Employee
        List<Task> tasks = [SELECT Id, OwnerId FROM Task WHERE Account.Primary_POC__r.Language__c = 'Spanish'];
        User user = [SELECT Id FROM User WHERE Spanish_Bilingual__c = true AND Email LIKE '%-callCenter@gmail.com'];
        System.assertEquals(user.Id, tasks[0].OwnerId);
    }
    
    @isTest
    static void testEmployeeRedistribution() {
        User user1 = [SELECT Id FROM User WHERE email = '1-callCenter@gmail.com' LIMIT 1];
        
        test.startTest();        
        BatchOutboundCallDistribution batchCallDistribution = new BatchOutboundCallDistribution();
        //Parameters we are passing into the Batch job
        batchCallDistribution.callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        batchCallDistribution.today = System.today();
		batchCallDistribution.empId = user1.Id;
        //Call the batch job to process the Tasks
        Database.executebatch(batchCallDistribution, 10000);
        test.stopTest();
        
		//Assert that no Tasks are assigned to the ISRs whose tasks we are redistributing
        Integer ownerCnt = [SELECT Count() FROM Task WHERE Owner.Id =: user1.Id];
        System.assertEquals(0, ownerCnt);
    }
}