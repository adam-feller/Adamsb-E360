/**
 * Created by nicholas.vree on 12/24.
 */


public with sharing class TaskCreationHandler {

    //QUEUE BY NAME
    public static Id getTaskQueue(String DeveloperName){
        return [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :DeveloperName LIMIT 1].Id;
    }

    //BASIC TASK
    public static Task createBaseTask(String subject, Date activityDate, Id whatId, Id ownerId, String description, String recordTypeId){
        Task newTask = new Task();
                    newTask.subject = subject;
                    newTask.WhatId = whatId;
                    newTask.OwnerId = ownerId;
                    newTask.ActivityDate = activityDate;
                    newTask.description = description;
                    newTask.recordTypeId = recordTypeId;

        return newTask;
    }


    //When an accounts is assigned to a new FSR, give them a New Account Visit Task
    public static void createTaskForNewlyAssignedFSR(List<Account> newAccounts, Map<Id, Account> oldAccountMap){
        try{
            String generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Task').getRecordTypeId();
            List<Task> insertTasks = new List<Task>();
            for(Account acc : newAccounts){
                Boolean changeSellType = false;
                Boolean newFSR = false;
                Boolean isFSRInsert = false;

                //Check conditions
                if(oldAccountMap != null){
                    changeSellType = (oldAccountMap.get(acc.Id).Sell_Type__c == 'PRESELL' || oldAccountMap.get(acc.Id).Sell_Type__c == null) && (acc.Sell_Type__c == 'INSIDE SALES' || acc.Sell_Type__c == 'NATIONAL ACCTS');
                    newFSR = (acc.Beer_Salesman_2_FSR__c != null && acc.Beer_Salesman_2_FSR__c != oldAccountMap.get(acc.Id).Beer_Salesman_2_FSR__c);
                }else if (acc.Sell_Type__c == 'INSIDE SALES' || acc.Sell_Type__c == 'NATIONAL ACCTS'){
                    isFSRInsert = true;
                }
                
                //If conditions met, create a new task accordignly

                if(((changeSellType || newFSR ||  isFSRInsert ) && (!String.isEmpty(acc.Beer_Salesman_2_FSR__c)))){
                    Task newTask = new Task();
                    newTask.recordTypeId = generalTaskRecordTypeId;
                    newTask.subject = 'New Account Visit - ' + acc.Name;
                    newTask.WhatId = acc.Id;
                    newTask.ownerId = acc.Beer_Salesman_2_FSR__c;
                    newTask.ActivityDate = DateScheduleUtility.addBusinessDays(System.today(), 5);
                    insertTasks.add(newTask);
                }
            }
            TaskDAO.insertTasks(insertTasks);
        }catch (Exception ex) {
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'TaskCreationHandler', 'createTaskForNewlyAssignedFSR');
        }
    }

    //If there's a Order Posting Error, create a Order Posting Task
    // Used OrderChangeEvent trigger here
    public static void createTaskForOrderPostingErrors(List<OrderChangeEvent> orderChangeEvents){
        try{
            String generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General Task').getRecordTypeId();
            String INTEGRATION_SERVICE_ACCOUNT = 'Integration Service Account';

            List<Task> orderPostingErrorTasks = new List<Task>();
            Set<String> orderIds = new Set<String>();

            //Obtain Order Ids
            for(OrderChangeEvent event : orderChangeEvents){
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                Set<String> setIds = new Set<String>(header.recordIds);
                orderIds.addAll(setIds);
            }

            //Use Order Ids to query Orders - the Update CE's don't have all necessary fields.
            Map<Id, Order> IdToOrderMap = new Map<Id,Order>(OrderDAO.getOrderDetailsbyId(orderIds));

            for (OrderChangeEvent event : orderChangeEvents) {
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                if (header.changedFields.contains('Status') || !String.isEmpty(event.Status)){
                    if (event.Status == 'Posting Error') {
                        for (String recordId : header.recordIds) {
                            //Assign to the ownerId - or - if the order created by the Integration Service Account, assign to a General Task Queue
                            Id ownerId;
                            Order currentOrder = idToOrderMap.get(recordId);
                            If(currentOrder.owner.Name != INTEGRATION_SERVICE_ACCOUNT){
                                ownerId = currentOrder.ownerId;
                            } else if (!String.isEmpty(CurrentOrder.Account.Primary_Language_Preference__c)){
                                ownerId = getTaskQueue('General_Task_Queue_' + currentOrder.Account.Primary_Language_Preference__c);
                            } else {
                                ownerId = getTaskQueue('General_Task_Queue_English');
                            }
                            String subject = 'Order Posting Error - ' + currentOrder.OrderNumber + ' - ' + currentOrder.Account.Name;

                            Task newTask = createBaseTask(subject, currentOrder.Delivery_Date__c-1, currentOrder.AccountId, ownerId, null, generalTaskRecordTypeId);
                            newTask.Order__c = currentOrder.Id;
                            newTask.OrderErrors__c = currentOrder.Order_Errors__c == null ? currentOrder.Order_Errors__c.left(255) : null;
                            newTask.Account__c = currentOrder.AccountId;
                            orderPostingErrorTasks.add(newTask);
                        }
                    }
                }
            }
            TaskDAO.insertTasks(orderPostingErrorTasks);
        }catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'TaskCreationHandler', 'createTaskForOrderPostingErrors');
        }
    }

    //If an order is made, close call tasks that equal the Order Delivery Date
    // Used OrderChangeEvent trigger here
    public static void closeScheduledCallsBasedOnOrder(List<OrderChangeEvent> orderChangeEvents){
        try{
            Map<Id, List<OrderChangeEvent>> accountIdToOrderCEMap = new Map<Id, List<OrderChangeEvent>>();
            List<Task> callTasksToClose = new List<Task>();
            Set<String> orderIds = new Set<String>();

            //Obtain Order Ids
            for(OrderChangeEvent event : orderChangeEvents){
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                Set<String> setIds = new Set<String>(header.recordIds);
                orderIds.addAll(setIds);
            }

            //Use Order Ids to query Orders - the Update CE's don't have all necessary fields.
            Map<Id, Order> IdToOrderMap = new Map<Id,Order>(OrderDAO.getOrderDetailsbyId(orderIds));
            
            //Retrieve a map of Order Change Events by Account Ids
            for(OrderChangeEvent event : orderChangeEvents){
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                for(String recordId : header.recordIds){
                    Order currentOrder = idToOrderMap.get(recordId);
                    if(accountIdToOrderCEMap.containsKey(currentOrder.AccountId)){
                        accountIdToOrderCEMap.get(currentOrder.AccountId).add(event);
                    }else{
                        List<OrderChangeEvent> newOCEList = new List<OrderChangeEvent>();
                        newOCEList.add(event);
                        accountIdToOrderCEMap.put(currentOrder.AccountId,newOCEList);
                    }
                }
            }

            //Search Open Call Tasks for those Accounts
            Set<Id> accountIds = accountIdToOrderCEMap.keySet();
            String callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
            List<Task> associatedFutureTasks = TaskDAO.getTasksByIdStatusRecordType(accountIds, 'Open', callTaskRecordTypeId);
            Set<Id> taskIds = new Set<Id>();
            //Close the tasks that are equal to the associated Order Delivery Date
            for(Task task : associatedFutureTasks){
                List<OrderChangeEvent> orderCEsToCheck = accountIdToOrderCEMap.get(task.whatId);
                for(OrderChangeEvent oce : orderCEsToCheck){
                    EventBus.ChangeEventHeader header = oce.ChangeEventHeader;
                    for (String recordId : header.recordIds) {
                        Order currentOrder = idToOrderMap.get(recordId);
                        if(currentOrder.Delivery_Date__c != null && task.ActivityDate != null){
                            if(currentOrder.Status == 'Posted to VIP' || currentOrder.Status == 'Pending - Future Order'){
                                if(currentOrder.Delivery_Date__c == task.Delivery_Date_Date__c){
                                    task.Status = 'No Call Needed';
                                    if(!taskIds.contains(task.Id)){
                                        callTasksToClose.add(task);
                                    }
                                    taskIds.add(task.Id);
                                }
                            }
                        }
                    }
                }
            }
            TaskDAO.updateTasks(callTasksToClose);
        }catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'TaskCreationHandler', 'closeScheduledCallsBasedOnOrder');
        }
    }

    //If an order is Posted to VIP, close all its associated tasks  
    //We used the normal Order Trigger here  due to dev bandwidth - ideally would be converted to a CE trigger method
    public static void closeSubmittedOrderRelatedTasks(List<Order> orderList, Map<Id, Order> oldOrderMap){
        try{
            List<String> submittedOrders = new List<String>();

           
            for(Order ord : OrderList){
                if(ord.Status == 'Posted to VIP' && oldOrderMap.get(ord.Id).Status!='Posted to VIP'){
                    submittedOrders.add(ord.Id);
                }
            }
            
            List<Task> tasksToClose = [SELECT Id, Status FROM Task WHERE Order__c IN :submittedOrders AND Status != 'Completed'];
                        
            for(Task tsk :tasksToClose){
                tsk.Status = 'Completed';
            }
            
            update tasksToClose;
            
        }catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'TaskCreationHandler', 'closeSubmittedOrderRelatedTasks');
        }
    }
    
    //If an order is Deleted, close all its associated tasks
    //We used the normal Order Trigger here  due to dev bandwidth - ideally would be converted to a CE Trigger method
    public static void closeDeletedOrderRelatedTasks(List<Order> orderList, Map<Id, Order> oldOrderMap){
        try{
                        
            List<String> deletedOrders = new List<String>();

            for(Order ord : OrderList){
                deletedOrders.add(ord.Id);
            }
            
            List<Task> tasksToClose = [SELECT Id, Status FROM Task WHERE Order__c IN :deletedOrders AND Status != 'Completed'];
                        
            for(Task tsk :tasksToClose){
                tsk.Status = 'Completed';
            }
            
            update tasksToClose;
            
        }catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'TaskCreationHandler', 'closeDeletedOrderRelatedTasks');
        }
    }
}