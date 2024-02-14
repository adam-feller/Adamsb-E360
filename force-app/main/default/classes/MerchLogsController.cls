public with sharing class MerchLogsController {

    @AuraEnabled
    public static List<String> getMerchChecklistsForAccount(Id recordId) {
        List<Merch_Checklist__c> checklists = MerchChecklistDAO.getMerchChecklistsByAccountIds(new Set<Id>{recordId});  
        List<String> merchList = new List<String>();
        for (Merch_Checklist__c m : checklists) {
            merchList.add(m.Name + ' - ' + m.Requested_Completion_Date__c.format() + '~' + m.Id);
        }
        return merchList;
    }  
    
    @AuraEnabled
    public static List<Task> getMiscMerchTasksForAccount(Id recordId) {  
        List<Task> merchTasks = TaskDAO.getMerchTasksByAccountIds(new Set<Id>{recordId});
        return merchTasks;
    }

    @AuraEnabled
    public static Merch_Checklist__c getMerchDetailsByMerchId(Id recordId) {
        Merch_Checklist__c checklist = MerchChecklistDAO.getMerchChecklistById(recordId);
        return checklist;
    }
    
    @AuraEnabled
    public static String getMerchTasksByMerchId(Id recordId, Integer pageSize) {
        List<MerchTasksViewWrapper> results = new List<MerchTasksViewWrapper>();       
        List<Task> tasks = TaskDAO.getMerchTasksByMerchChecklistIds(new Set<Id>{recordId});
        Integer totRec = 0;
        Integer totComp = 0;
        for (Task t : tasks) {
            MerchTasksViewWrapper task = new MerchTasksViewWrapper();
            task.subject = t.Subject;
            task.taskdetails = t.Task_Details__c;
            task.activitydate = t.ActivityDate.format();            
            task.id = t.Id;
            task.product = t.Product__r.Name;
            task.location = t.Location__c;
            task.comments = t.Description;
            task.status = t.Status;
            if (task.status == 'Open') {
                task.statusIcon = 'action:remove';
                task.statusVariant = 'brand-outline';
                totRec += 1;
            } else if (task.status == 'Completed' || task.status == 'Could Not Complete') {
                task.statusIcon = 'action:approval';
                task.statusVariant = 'success';
                totRec += 1;
                totComp += 1;
            } else {
                task.statusIcon = 'action:close';
                task.statusVariant = 'destructive';                
            }
            task.owner = t.Owner.Name;
            results.add(task);
        }
        
        MerchTaskSummaryWrapper summaryResult = new MerchTaskSummaryWrapper();
        summaryResult.pageSize = pageSize;
        summaryResult.totalRecord = totRec;
        summaryResult.totalCompleted = totComp;
        summaryResult.recordList = results;

        return JSON.serialize(summaryResult);
    }
    
    @AuraEnabled
    public static String getMerchTasksByAccountId(Id recordId, Integer pageSize) {
        List<MerchTasksViewWrapper> results = new List<MerchTasksViewWrapper>();       
        List<Task> tasks = TaskDAO.getMerchTasksByAccountIds(new Set<Id>{recordId});
        Integer totRec = 0;
        Integer totComp = 0;
        for (Task t : tasks) {
            MerchTasksViewWrapper task = new MerchTasksViewWrapper();
            task.subject = t.Subject;
            task.taskdetails = t.Task_Details__c;
            task.activitydate = t.ActivityDate.format();            
            task.id = t.Id;
            task.comments = t.Description;
            task.status = t.Status;
            if (task.status == 'Open') {
                task.statusIcon = 'action:remove';
                task.statusVariant = 'brand-outline';
                totRec += 1;
            } else if (task.status == 'Completed' || task.status == 'Could Not Complete') {
                task.statusIcon = 'action:approval';
                task.statusVariant = 'success';
                totRec += 1;
                totComp += 1;
            } else {
                task.statusIcon = 'action:close';
                task.statusVariant = 'destructive';                
            }
            task.owner = t.Owner.Name;
            results.add(task);
        }
        
        MerchTaskSummaryWrapper summaryResult = new MerchTaskSummaryWrapper();
        summaryResult.pageSize = pageSize;
        summaryResult.totalRecord = totRec;
        summaryResult.totalCompleted = totComp;
        summaryResult.recordList = results;

        return JSON.serialize(summaryResult);
    }
    
    public class MerchTaskSummaryWrapper {
        @AuraEnabled
        public Integer totalRecord {get; set;}

        @AuraEnabled
        public Integer totalCompleted {get; set;}
        
        @AuraEnabled
        public Integer pageSize {get; set;}
        
        @AuraEnabled
        public List<MerchTasksViewWrapper> recordList {get; set;}
    }
        
    public class MerchTasksViewWrapper {
        @AuraEnabled
        public String id {get; set;}
        
        @AuraEnabled
        public String subject {get; set;}

        @AuraEnabled
        public String taskdetails {get; set;}
        
        @AuraEnabled
        public String activitydate {get; set;}
                
        @AuraEnabled
        public String comments {get; set;}
        
        @AuraEnabled
        public String product {get; set;}

        @AuraEnabled
        public String location {get; set;}

        @AuraEnabled
        public String status {get; set;}

        @AuraEnabled
        public String statusIcon {get; set;}

        @AuraEnabled
        public String statusVariant {get; set;}
        
        @AuraEnabled
        public String owner {get; set;}
    }

}