@isTest
private class DateScheduleUtilityTest {

    @TestSetup
    private static void setup(){
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
    }

    static Account getAccount(String Name){
        return [SELECT Id, Name, VIP_Account_Number__c, Beer_Company__c, Warehouse__c, Territories__c, Requested_Delivery_Days__c, Delivery_Frequency_Type__c,
                Batch_Call_Date_Created__c, Warehouse_Lookup__r.ISR_1__c, OwnerId, Call_Days__c
                FROM Account
                WHERE Name = :name
                LIMIT 1];
    }

    @isTest
    static void testReturnListOfTasksMonday(){
        Account testAccount = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Batch_Call_Date_Created__c = Date.NewInstance(2021,3,21).toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = Date.NewInstance(2021,3,21).toStartOfWeek().addDays(84);
        update testAccount;
      
        Date tdy = System.today();      
        Integer dayOfWeekNumber = DateScheduleUtility.dayOfWeekNumber(tdy);
        DateTime myDateTime = (DateTime) System.today();		
        Delivery_Date__c testDeliveryDate;
        String key = 'PVA*201*' + tdy.month() + '/' + tdy.day() + '/' + String.valueOf(tdy.year()).substring(2,4);
		if (dayOfWeekNumber != 1) {
            //Create a task for Today
            testDeliveryDate = new Delivery_Date__c();
        	testDeliveryDate.Delivery_Date__c = tdy;
        	testDeliveryDate.Account__c = testAccount.Id;
        	testDeliveryDate.External_Id__c = key;
        	insert testDeliveryDate;
        } else {
            //If Today is Monday then a task was already created
            testDeliveryDate = [SELECT Id, Delivery_Date__c, Account__c FROM Delivery_Date__c WHERE External_Id__c = :key];
        }
        
        Map<String, Delivery_Date__c> idToDeliveryDateMap = new Map<String, Delivery_Date__c>();
        idToDeliveryDateMap.put(testDeliveryDate.Account__c + String.valueOf(testDeliveryDate.Delivery_Date__c), testDeliveryDate);

        Map<Id, List<Delivery_Date__c>> idToDateSet = new Map<Id, List<Delivery_Date__c>>();
        idToDateSet.put(testDeliveryDate.Id, new List<Delivery_Date__c>{testDeliveryDate});
        
        String dayOfWeek = DateScheduleUtility.dayOfTheWeekForNumMap.get(dayOfWeekNumber);

        Test.startTest();
            List<Task> taskList = DateScheduleUtility.returnListOfTasks(new List<String>{dayOfWeek}, tdy, testAccount, DateScheduleUtility.dayOfTheWeekMap, idToDeliveryDateMap, idToDateSet, 'Weekly');
        Test.stopTest();

        System.assertEquals(taskList.size(), 1, '1 Task records should be found');
    }

    @isTest
    static void testReturnListOfTasksDayofWeek(){
        Account testAccount = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Batch_Call_Date_Created__c = Date.NewInstance(2021,3,24).toStartOfWeek().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = Date.NewInstance(2021,3,24).toStartOfWeek().addDays(84);
        update testAccount;

		Date tdy = System.today();      
        Integer dayOfWeekNumber = DateScheduleUtility.dayOfWeekNumber(tdy);
        DateTime myDateTime = (DateTime) System.today();		
        Delivery_Date__c testDeliveryDate;
        String key = 'PVA*201*' + tdy.month() + '/' + tdy.day() + '/' + String.valueOf(tdy.year()).substring(2,4);
		if (dayOfWeekNumber != 1) {
            //Create a task for Today
            testDeliveryDate = new Delivery_Date__c();
        	testDeliveryDate.Delivery_Date__c = tdy;
        	testDeliveryDate.Account__c = testAccount.Id;
        	testDeliveryDate.External_Id__c = key;
        	insert testDeliveryDate;
        } else {
            //If Today is Monday then a task was already created
            testDeliveryDate = [SELECT Id, Delivery_Date__c, Account__c FROM Delivery_Date__c WHERE External_Id__c = :key];
        }
                
        Map<String, Delivery_Date__c> idToDeliveryDateMap = new Map<String, Delivery_Date__c>();
        idToDeliveryDateMap.put(testDeliveryDate.Account__c + String.valueOf(testDeliveryDate.Delivery_Date__c), testDeliveryDate);

        Map<Id,List<Delivery_Date__c>> idToDateSet = new Map<Id, List<Delivery_Date__c>>();
        idToDateSet.put(testDeliveryDate.Id, new List<Delivery_Date__c>{testDeliveryDate});

        String dayOfWeek = DateScheduleUtility.dayOfTheWeekForNumMap.get(dayOfWeekNumber);

        Test.startTest();
            List<Task> taskList = DateScheduleUtility.returnListOfTasks(new List<String>{dayOfWeek}, System.today(), testAccount, DateScheduleUtility.dayOfTheWeekMap, idToDeliveryDateMap, idToDateSet, 'Weekly');
        Test.stopTest();

        System.assertEquals(taskList.size(), 1, '1 Task records should be created');
    }

    @isTest
    static void testReturnListOfTasksBasedOnTask(){
        Account testAccount = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Batch_Call_Date_Created__c = Date.NewInstance(2021,3,24).toStartOfWeek().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = Date.NewInstance(2021,3,24).toStartOfWeek().addDays(84);
        update testAccount;

        Date tdy = System.today();      
        Integer dayOfWeekNumber = DateScheduleUtility.dayOfWeekNumber(tdy);
        DateTime myDateTime = (DateTime) System.today();		
        Delivery_Date__c testDeliveryDate;
        String key = 'PVA*201*' + tdy.month() + '/' + tdy.day() + '/' + String.valueOf(tdy.year()).substring(2,4);        
		if (dayOfWeekNumber != 1) {
            //Create a task for Today
            testDeliveryDate = new Delivery_Date__c();
        	testDeliveryDate.Delivery_Date__c = tdy;
        	testDeliveryDate.Account__c = testAccount.Id;
        	testDeliveryDate.External_Id__c = key;
        	insert testDeliveryDate;
        } else {
            //If Today is Monday then a task was already created
            testDeliveryDate = [SELECT Id, Delivery_Date__c, Account__c FROM Delivery_Date__c WHERE External_Id__c = :key];
        }

        Map<String, Delivery_Date__c> idToDeliveryDateMap = new Map<String, Delivery_Date__c>();
        idToDeliveryDateMap.put(testDeliveryDate.Account__c + String.valueOf(testDeliveryDate.Delivery_Date__c), testDeliveryDate);

        Map<Id,List<Task>> idToTaskSet = new Map<Id, List<Task>>();

        String dayOfWeek = DateScheduleUtility.dayOfTheWeekForNumMap.get(dayOfWeekNumber);

        Test.startTest();
            List<Task> taskList = DateScheduleUtility.returnListOfTasksBasedOnTask(new List<String>{dayOfWeek}, System.today(), testAccount, DateScheduleUtility.dayOfTheWeekMap, idToDeliveryDateMap, idToTaskSet, 'Weekly');
        Test.stopTest();

        System.assertEquals(taskList.size(), 1, '1 Task records should be created');
    }

    @isTest
    static void testDayOfWeekNumber(){
        Test.startTest();
            Integer dateNum = DateScheduleUtility.dayOfWeekNumber(System.today().toStartOfWeek());
        Test.stopTest();

        System.assertEquals(dateNum, 0, 'Sunday should be returned as 0');
    }
    
    @isTest
    static void testGetDaysOffset(){
        Test.startTest();
            Integer offset = DateScheduleUtility.getDaysOffset('Monday', 'Sunday');
        Test.stopTest();

        System.assertEquals(6, offset, 'Offset days should be 6 - Monday to Sunday');
    }

    @isTest
    static void testCreateTask(){
        Account testAccount = getAccount('Test Account');
        testAccount.Requested_Delivery_Days__c = 'Monday';
        testAccount.Delivery_Frequency_Type__c = 'Weekly';
        testAccount.Batch_Call_Date_Created__c = System.today().toStartOfWeek();
        testAccount.Batch_Call_Date_Ended__c = System.today().toStartOfWeek().addDays(84);
        update testAccount;

        Delivery_Date__c testDeliveryDate = new Delivery_Date__c();
        testDeliveryDate.Delivery_Date__c = Date.NewInstance(2021,3,23);
        testDeliveryDate.Account__c = testAccount.Id;
        insert testDeliveryDate;

        Test.startTest();
            Task taskObj = DateScheduleUtility.createTask(testAccount, Date.NewInstance(2021,3,24), testDeliveryDate);
        Test.stopTest();

        System.assertEquals(taskObj.Subject, 'Outbound Call - Test Account', 'Task Subject should be Test Account');
    }

    @isTest
    static void testAddBusinessDays(){
        Test.startTest();
            DateScheduleUtility.AddBusinessDays(Date.NewInstance(2021,3,27), 1);
        Test.stopTest();
    }

    @isTest
    static void testReturnDateSetFromString(){
        Test.startTest();
            Set<Date> dates = DateScheduleUtility.returnDateSetFromString('(2021-06-11 00:00:00)');
        Test.stopTest();

        System.assertEquals(dates.size(), 1, '1 date should be returned');
    }

    @isTest
    static void testGetCallScheduleStartAndEndDates(){
        Test.startTest();
            DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndObj = DateScheduleUtility.getCallScheduleStartAndEndDates(Date.newInstance(2021, 05, 16));
        Test.stopTest();

        System.assertEquals(callScheduleStartEndObj.startDate, Date.newInstance(2021, 05, 16), 'Start date should be 5/16 as its the start of the 4 week cycle');
    }

    @isTest
    static void testGetCallScheduleStartAndEndDates1weekAhead(){
        Test.startTest();
            DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndObj = DateScheduleUtility.getCallScheduleStartAndEndDates(Date.newInstance(2021, 05, 23));
        Test.stopTest();

        System.assertEquals(callScheduleStartEndObj.startDate, Date.newInstance(2021, 05, 16), 'Start date should be 5/16 as its the start of the 4 week cycle');
    }

    @isTest
    static void testGetCallScheduleStartAndEndDates2weeksAhead(){
        Test.startTest();
            DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndObj = DateScheduleUtility.getCallScheduleStartAndEndDates(Date.newInstance(2021, 05, 30));
        Test.stopTest();

        System.assertEquals(callScheduleStartEndObj.startDate, Date.newInstance(2021, 05, 16), 'Start date should be 5/16 as its the start of the 4 week cycle');
    }

    @isTest
    static void testGetCallScheduleStartAndEndDates3weeksAhead(){
        Test.startTest();
            DateScheduleUtility.CallScheduleStartEndWrapper callScheduleStartEndObj = DateScheduleUtility.getCallScheduleStartAndEndDates(Date.newInstance(2021, 06, 06));
        Test.stopTest();

        System.assertEquals(callScheduleStartEndObj.startDate, Date.newInstance(2021, 05, 16), 'Start date should be 5/16 as its the start of the 4 week cycle');
    }
}