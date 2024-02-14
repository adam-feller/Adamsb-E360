/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class addImageOnTaskCompletionHandler {

    @AuraEnabled
     public static TaskWrapper checkTaskStatus(String recordId) {
         try{
             TaskWrapper wrapperObj = new TaskWrapper();
             Boolean val = false;
             Task taskObj = [Select id,Subject,Status,Image_Id__c FROM Task WHERE Id =: recordId LIMIT 1];
             system.debug('taskObj::'+taskObj);  
             if(taskObj.Status != 'Completed' /*&& String.isBlank(taskObj.Image_Id__c)*/){
                 val = true;
             }
             wrapperObj.tasknameAndDate = taskObj.Subject + ' - ' + system.today().format() + ' ';
             wrapperObj.isopenModal = val;
             system.debug('wrapperObj::'+wrapperObj);  
             return wrapperObj;
         }catch(Exception e){
             system.debug('exception line>>'+e.getLineNumber() + 'msg>>'+e.getMessage());
             return null;
         }       
     }
 
     @AuraEnabled
     public static void deleteImageOnTask(List<ContentDocument> contentDocumentIds) {
         try{
            
             Set<Id> cdIds = new Set<Id>();
             for(ContentDocument cdVar : contentDocumentIds){
                 cdIds.add(cdVar.Id);
             }
            
             List<ContentDocument> contentdocumentList = new List<ContentDocument>();
             contentdocumentList = [SELECT Id FROM ContentDocument WHERE Id =: cdIds];
             system.debug('contentdocumentList::'+contentdocumentList);
             if(contentdocumentList.size() > 0){
                 delete contentdocumentList;
             }
         }catch(Exception e){
             system.debug('exception line>>'+e.getLineNumber() + 'msg>>'+e.getMessage());
         }       
     }
 
     @AuraEnabled
     public static void updateImageId(String recordId, string cvId) {
         try{
             
             List<Task> taskList = new List<Task>();
             List<Task> updatetaskList = new List<Task>();                    
                      
             taskList = [Select id,Image_Id__c,Required_Image__c FROM Task WHERE Id =: recordId LIMIT 1];
             Id cvIdVar = [Select Id from ContentVersion where ContentDocumentId =: cvId].Id;

             for(Task taskObj : taskList){          
                 taskObj.Image_Id__c = cvIdVar;
                 updatetaskList.add(taskObj);         
             }
             
             if(updatetaskList.size() > 0){
                 update updatetaskList;
             }   
             //return 'success';
         }catch(Exception e){
             system.debug('exception line>>'+e.getLineNumber() + 'msg>>'+e.getMessage());
             //return 'error';
         }       
     }
     
     public class TaskWrapper{
         @AuraEnabled
         public String tasknameAndDate{get;set;}
         @AuraEnabled
         public Boolean isopenModal{get;set;}
     }
 }