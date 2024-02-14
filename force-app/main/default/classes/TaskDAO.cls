public without sharing class TaskDAO {

    public static List<Task> getTasksByIdAndStatus(Set<Id> recordIds, String status) {
        return getTasksByIdAndStatus(recordIds, status, true);
    }

    public static List<Task> getTasksByIdAndStatus(Set<Id> recordIds, String status, boolean includePastDue) {
        if (includePastDue) {
            return [SELECT Id, Subject, Description, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE WhatId IN :recordIds
                AND Status = :Status
                ];

        } else {
            return [SELECT Id, Subject, Description, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE WhatId IN :recordIds
                AND Status = :status
                AND ActivityDate >= TODAY
            ];
        }
    }

    public static List<Task> getTasksByIdAndStatusForCM(Set<Id> recordIds, String status, boolean includePastDue) {
        List<Task> tasksToReturn = new List<Task>();
        String callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId();
        String merchTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId();
        if (includePastDue) {
            tasksToReturn = [SELECT Id, Subject, Description, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE WhatId IN :recordIds
                AND Status = :status
                AND recordTypeId != :callTaskRecordTypeId
                AND recordTypeId != :merchTaskRecordTypeId
                AND IsRecurrence = false
                ];
            tasksToReturn.addAll([SELECT Id, Subject, Description, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE WhatId IN :recordIds
                AND Status = :status
                AND recordTypeId = :callTaskRecordTypeId
                AND recordTypeId != :merchTaskRecordTypeId
                AND IsRecurrence = false                                                                    
                ORDER BY ActivityDate
                LIMIT 1]);

        } else {
            tasksToReturn = [SELECT Id, Subject, Description, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE WhatId IN :recordIds
                AND Status = :status
                AND recordTypeId != :callTaskRecordTypeId
                AND recordTypeId != :merchTaskRecordTypeId
                AND ActivityDate >= TODAY
                AND IsRecurrence = false                             
            ];
            tasksToReturn.addAll([SELECT Id, Subject, Description, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE WhatId IN :recordIds
                AND Status = :status
                AND recordTypeId = :callTaskRecordTypeId
                AND recordTypeId != :merchTaskRecordTypeId
                AND IsRecurrence = false                                  
                ORDER BY ActivityDate                                  
                LIMIT 1]);
        }
        return tasksToReturn;
    }

    public static List<Task> getTasksByUserIdAndStatusForCM(Set<Id> userIds, String status) {
        List<Task> tasksToReturn = new List<Task>();
        Id generalTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('General_Task').getRecordTypeId();
            tasksToReturn = [SELECT Id, Display_Product__r.No_Display_Reason_Code__c, Subject, Description, WhatId, Account__r.Name, ActivityDate, Priority, Priority_Abbreviated__c, Display_Product__c, Owner.Name
                FROM Task
                WHERE OwnerId IN :userIds
                AND Status = :status
                AND recordTypeId = :generalTaskRecordTypeId
                AND IsRecurrence = false
                AND ActivityDate >= Today
                AND Display_Product__c != null
                ];

        return tasksToReturn;
    }

    public static List<Task> getTasksByIdAndStatusToday(Set<Id> recordIds, String status) {
        return [SELECT Id, Subject, Description, ActivityDate, Priority
                FROM Task 
                WHERE WhatId IN :recordIds 
                AND Status = :status
                AND LastModifiedDate = Today];
    }

    public static List<Task> getTasksByIdStatusRecordType(Set<Id> recordIds, String status, String recordTypeId) {
        return [SELECT Id, Subject, Description, ActivityDate, Priority, WhatId, Delivery_Date_Date__c
                FROM Task 
                WHERE WhatId IN :recordIds 
                AND Status = :status
                AND RecordTypeId = :recordTypeId];
    }

    public static List<Task> getTasksByWarehouseActivityDateStatusRecordType(Set<String> warehouses,Date activityDate, String status, String recordTypeId) {
        return [SELECT Id, Subject, Description, ActivityDate, Account.Warehouse_Lookup__r.Name,Warehouse__c, Priority, WhatId
                FROM Task 
                WHERE Warehouse__c IN :warehouses 
                AND ActivityDate = :activityDate
                AND Status = :status
                AND RecordTypeId = :recordTypeId];
    }

    public static list<Task> getTasksByDeliveryIds(List<Id> deliveryDateIds) {
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
        return [SELECT Id, Subject, ActivityDate, Delivery_Date__c, Delivery_Date_Date__c, Warehouse__c, Account__r.Warehouse__c
                FROM Task
                WHERE Delivery_Date__c IN :deliveryDateIds
                AND RecordTypeId = :callTaskRecordTypeId
               ];
    }
    
    public static list<Task> getTasksByDeliveryIds(Set<Id> deliveryDateIds) {
        Id callTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
        return [SELECT Id, Subject, ActivityDate, Delivery_Date__c, Delivery_Date_Date__c, Warehouse__c, Account__r.Warehouse__c, Status, IsClosed
                FROM Task
                WHERE Delivery_Date__c IN :deliveryDateIds
                AND RecordTypeId = :callTaskRecordTypeId
               ];
    }
    
    public static List<Task> getMerchTasksByAccountIds(Set<Id> accountIds) {
        Id merchTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId(); 
        return [SELECT Id, Subject, Task_Details__c, ActivityDate, Account__c, WhatId, Status, Description, IsClosed, Owner.Name, OwnerId,
                Product__r.Name, Location__c
                FROM Task
                WHERE WhatId IN :accountIds
                AND RecordTypeId = :merchTaskRecordTypeId
                AND Merch_Checklist__c = ''
                ORDER BY ActivityDate DESC
               ];        
    }
    
    public static List<Task> getMerchTasksByMerchChecklistIds(Set<Id> merchChecklistIds) {
        Id merchTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Merch Task').getRecordTypeId(); 
        return [SELECT Id, Subject, Task_Details__c, ActivityDate, Account__c, WhatId, Status, Description, IsClosed, Owner.Name, OwnerId,
                Product__r.Name, Location__c
                FROM Task
                WHERE Merch_Checklist__c IN :merchChecklistIds
                AND RecordTypeId = :merchTaskRecordTypeId
                AND Status != 'Cancelled' 
                ORDER BY CreatedDate ASC
               ];   
    }

    public static List<Task> updateTasks(List<Task> tasksToUpdate) {
        update tasksToUpdate;
        return tasksToUpdate;
    }

    public static List<Task> insertTasks(List<Task> tasksToInsert) {
        insert tasksToInsert;
        return tasksToInsert;
    }
}