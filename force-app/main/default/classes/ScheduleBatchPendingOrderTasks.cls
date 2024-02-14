/**
 * Created by nicholas.vree on 1/8/2021.
 */

public with sharing class ScheduleBatchPendingOrderTasks implements Schedulable {

    public void execute(SchedulableContext sc) {
        List<String> pendingOrderStatusList = getPendingOrderStatusList();

        BatchPendingOrderTasks BatchPendingOrderTasks = new BatchPendingOrderTasks();
        BatchPendingOrderTasks.pendingOrderStatusList = pendingOrderStatusList;
        batchPendingOrderTasks.query = 'SELECT Id, OrderNumber, PoNumber, Delivery_Date__c, AccountId, Status, Account.ExternalId__c, CreatedDate, CreatedBy.Name, OwnerId' + 
                                        ' FROM Order' + 
                                        ' WHERE CreatedDate = TODAY' +
                                        ' AND Status =  \'Pending Draft\'';

        Database.executebatch(batchPendingOrderTasks);
    }

    public List<String> getPendingOrderStatusList(){
        List<String> pendingOrderStatusList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            String pickListStringVal = (String)pickListVal.getValue();
            if(pickListStringVal.containsIgnoreCase('Pending')){
                pendingOrderStatusList.add(pickListVal.getLabel());
            }
        }
      return pendingOrderStatusList;
    }
}