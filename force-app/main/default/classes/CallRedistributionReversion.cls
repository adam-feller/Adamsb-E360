global with sharing class CallRedistributionReversion {

    @InvocableMethod
    public static void revertPlan(List<ReversionInputs> inputs){

        //Grabbing Initial Values
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();

        String userName = UserInfo.getUserName();
        List<User> activeUser = UserDAO.getUser(UserInfo.getUserId());
        String userEmail = activeUser[0].Email;

        String planId = inputs[0].planId;
        String planName = inputs[0].planName;
        String warehouses = inputs[0].warehouses;
        List<String> selectedWarehouseList = new List<String>();
        if(!String.isBlank(warehouses)){
            selectedWarehouseList = warehouses.split('; ');
        }

        List<Plan__c> planObj = PlanDAO.getPlansByIds(new Set<Id>{planId});
        List<String> warehouseList = new List<String>();

        if(!String.isBlank(planObj[0].Warehouses__c)){
            warehouseList = planObj[0].Warehouses__c.split('; ');
        }

        List<String> updatedWarehouseList = new List<String>();
        for(String warehouse : warehouseList){
            if(!selectedWarehouseList.contains(warehouse)){
                updatedWarehouseList.add(warehouse);
            }
        }

        planObj[0].Warehouses__c = String.join(updatedWarehouseList, '; ');
        planDAO.updatePlans(new List<Plan__c>{planObj[0]});

        String queryHPRDD = 'SELECT Id, Delivery_Date__c, Original_Delivery_Date__c, Account__r.Warehouse__c, Status__c' +
        ' FROM Delivery_Date__c' +
        ' WHERE Plan__c = :planId' +
        ' AND Account__r.Warehouse__c IN :warehouseList' ;

        BatchHolidayPlanningReversionDD batchHPRDD = new BatchHolidayPlanningReversionDD();
        batchHPRDD.planId = planId;
        batchHPRDD.planName = planName;
        batchHPRDD.warehouses = warehouses;
        batchHPRDD.userEmail = userEmail;
        batchHPRDD.query = queryHPRDD;
        database.executeBatch(batchHPRDD, 2000);

        String queryHPRTask = 'SELECT Id, ActivityDate, Original_Call_Date__c, Account__r.Warehouse__c, Status' +
        ' FROM Task' +
        ' WHERE Plan__c = :planId' +
        ' AND Account__r.Warehouse__c IN :warehouseList' ;

        BatchHolidayPlanningReversionTask batchHPRTask = new BatchHolidayPlanningReversionTask();
        batchHPRTask.planId = planId;
        batchHPRTask.planName = planName;
        batchHPRTask.warehouses = warehouses;
        batchHPRTask.userEmail = userEmail;
        batchHPRTask.query = queryHPRTask;
        database.executeBatch(batchHPRTask, 2000);

        String queryHPRAlert = 'SELECT id, Account__r.Warehouse__c' +
        ' FROM Alert__c' +
        ' WHERE Plan__c = :planId' +
        ' AND Account__r.Warehouse__c IN :warehouseList' ;

        BatchHolidayPlanningReversionAlert batchHPRAlert = new BatchHolidayPlanningReversionAlert();
        batchHPRAlert.planId = planId;
        batchHPRAlert.warehouses = warehouses;
        batchHPRAlert.query = queryHPRAlert;
        database.executeBatch(batchHPRAlert, 2000);
    }

    global class ReversionInputs{

        @InvocableVariable
        global Boolean summaryOnly;

        @InvocableVariable
        global String planId;

        @InvocableVariable
        global String planName;

        @InvocableVariable
        global String warehouses;
    }
}