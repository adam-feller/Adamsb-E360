/**
 * Created by nicholas.vree on 1/8/2021.
 */

public with sharing class BatchPendingOrderTasks implements Database.Batchable<sObject>  {

    public List<String> pendingOrderStatusList;
    public Date today = System.today();
    public String query;
    public String INTEGRATION_SERVICE_ACCOUNT = 'Integration Service Account';

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Order> ordersList){

        try{
            List<Task> tasksToInsert = new List<Task>();
            List<Order> ordersToDelete = new List<Order>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> orderIdSet = new set<Id>();
            
            User integrationServiceAccount = UserDAO.getUserByName(INTEGRATION_SERVICE_ACCOUNT)[0];

            //Obtain Mapped Id to Account Info to obtain corresponding Primary ISR Info
            for(Order ord: ordersList){
                accountIdSet.add(ord.accountId);
                orderIdSet.add(ord.Id);
            }

            Map<Id,Account> idToAccountMap = new Map<Id,Account>(AccountDAO.getAccountsByIds(accountIdSet));
            List<OrderItem> orderItemList = OrderItemDAO.getOrderItemByOrderIds(orderIdSet);
            

            Map<Id,List<OrderItem>> orderIdToOrderItemMap = new Map<Id, List<OrderItem>>();

            for(OrderItem oi : orderItemList){
                if(orderIdToOrderItemMap.containsKey(oi.OrderId)){
                    orderIdToOrderItemMap.get(oi.OrderId).add(oi);
                }else{
                    List<OrderItem> newOrderItemList = new List<OrderItem>();
                    newOrderItemList.add(oi);
                    orderIdToOrderItemMap.put(oi.OrderId, newOrderItemList);
                }
            }
            

            for(Order ord : ordersList){
                if(orderIdToOrderItemMap.containsKey(ord.Id)){
                    //For each Pending Order, create a new task
                    Task newTask = new Task();
                    newTask.subject = 'Order in Pending Status - ' + ord.OrderNumber + ' - ' + idToAccountMap.get(ord.AccountId).Name;
                    newTask.WhatId = ord.AccountId;
                    newTask.Order__c = ord.Id;
                    newTask.Account__c  = ord.account.Id;
                    newTask.ActivityDate = ord.Delivery_Date__c != null ? ord.Delivery_Date__c - 1 : null;
                    //Old Logic
                    //Assign to the ownerId - or - if the order created by the Integration Service Account, assign to the Account's Primary ISR
                    //newTask.ownerId = ord.createdById != integrationServiceAccount.Id ? ord.ownerId : idToAccountMap.get(ord.AccountId).Warehouse_Lookup__r.ISR_1__c;
                    //End Old Logic
                    //BSSP-872 We are changing the logic here, they always want these Pending Order tasks assigned to the Account's Primary ISR
                    newTask.ownerId = idToAccountMap.get(ord.AccountId).Warehouse_Lookup__r.ISR_1__c;
                    tasksToInsert.add(newTask);
                }else{
                    ordersToDelete.add(ord);
                }

            }
            //Insert tasks
            TaskDAO.insertTasks(tasksToInsert);

            //Delete Orders Without Order Items
            OrderDAO.deleteOrders(ordersToDelete);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'BatchPendingOrderTasks', 'execute()');
        } 

    }

    public void finish(Database.BatchableContext BC){
    }


}