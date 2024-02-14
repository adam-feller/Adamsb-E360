/*
  @File Name          : RelatedListController.cls
  @Description        : This file containes the code needed for getting the related list records, label names, 
                        and user permissions to edit, create, and delete on related record list.
  @Author             : Slalom run:CRM
  @Group              : run:CRM
  @Last Modified By   : marshall.lanners@slalom.com
  @Last Modified On   : 6/18/2020, 10:00:00 AM
*/

public class RelatedListController {
    
    // this wrapper class is used to make an easy return type used for accessing values in the LWC component.
    public class Wrapper {

        @AuraEnabled public List<SObject> recordList;
        @AuraEnabled public String objectName;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public Map<String, Map<String,String>> labelNames;
        @AuraEnabled public Boolean canCreate;
        @AuraEnabled public Boolean canDelete;
        @AuraEnabled public String parentRecordField;
        @AuraEnabled public String RecordTypeId;
        @AuraEnabled public List<String> createFields;

        public Wrapper(List<SObject> recordList, String objectName, String objectLabel, Map<String, Map<String,String>> labelNames, Boolean canCreate, Boolean canDelete, String parentRecordField, String RecordTypeId, List<String> createFields){
            this.recordList = recordList;
            this.objectName = objectName;
            this.objectLabel = objectLabel;
            this.labelNames = labelNames;
            this.canCreate = canCreate;
            this.canDelete = canDelete;
            this.parentRecordField = parentRecordField;
            this.RecordTypeId = RecordTypeId;
            this.createFields = createFields;
        }
    }
    
    public static RelatedList__mdt createMetadataRecord(){
        RelatedList__mdt customMetadata = new RelatedList__mdt();
        customMetadata.Display_Fields__c = 'Name,StageName,Amount';
        customMetadata.Name__c = 'test record';                                         
        customMetadata.Parent_Record_Field__c = 'AccountId';
        customMetadata.SObject__c = 'Opportunity';
        customMetadata.Where_Clause__c = 'Stagename = ' + '\''+ 'Prospecting' + '\'';
        return customMetadata;
    }

    // gets record Id. Only used if RecordType_Name__c field was filled out in metadata record.
    public static String getRecordTypeId(String recordTypeName){
        return [SELECT Id FROM RecordType WHERE Name = :recordTypeName LIMIT 1].Id;
    }

    // gets the boolean value of whether or not the current user can create new objects in the related list.
    public static Boolean canCreate(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }

    // gets the boolean value of whether or not the current user can delete objects in the related list.
    public static Boolean canDelete(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }

    // gets label of the object
    public static String getLabel(String objectName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(objectName);
        return schemaType.getDescribe().getLabel();
    }

    // returns the related list, access variables, and object name based on metadata record in a new instance of the wrapper class.
    @AuraEnabled(cacheable=true)
    public static Wrapper getRelatedList(String customMetadataName, String id, Boolean baseCreate){
        
        RelatedList__mdt customMetadata;
        
        if (baseCreate == true){
            customMetadata = RelatedListController.createMetadataRecord();
        } else {
            customMetadata = [SELECT Create_Fields__c, Display_Fields__c, SObject__c, Parent_Record_Field__c, Where_Clause__c, RecordType_Name__c  FROM RelatedList__mdt WHERE Name__c = :customMetadataName Limit 1];
        }

        // fields needed for query on related records
        String objectName = customMetadata.get('SObject__c').toString();
        String fields = customMetadata.get('Display_Fields__c').toString();
        String parentRecordField = customMetadata.get('Parent_Record_Field__c').toString();
        String RecordTypeId;

        // base query string needed for getting related records
        String objectQuery = 'SELECT ' + fields + ' FROM ' + objectName + ' WHERE ' + parentRecordField + ' = ' + '\''+ id + '\'';

        // in case filtering is needed for record type
        if (customMetadata.get('RecordType_Name__c') != null) {
            String recordTypeName = customMetadata.get('RecordType_Name__c').toString();
            RecordTypeId = getRecordTypeId(recordTypeName);
            objectQuery += ' AND RecordTypeId = ' + '\''+ RecordTypeId + '\''; 
        }

        // in case filtering is needed for where clause 
        if (customMetadata.get('Where_Clause__c') != null) {
            String whereClause = customMetadata.get('Where_Clause__c').toString();
            objectQuery += ' AND ' + whereClause;
        }

        List<SObject> recordList = Database.query(objectQuery);

        Map<String, Map<String,String>> labelnames = getRelatedLabels(customMetadataName, id, baseCreate);
        String objectLabel = getLabel(objectName);
        Boolean canCreate = canCreate(objectName);
        Boolean canDelete = canDelete(objectName);
        List<String> createFields;

        if (customMetadata.get('Create_Fields__c') != null) {
            String formFields = customMetadata.get('Create_Fields__c').toString();
            createFields = formFields.split(',');
        }

        Wrapper wrapper = new Wrapper(recordList, objectName, objectLabel, labelnames, canCreate, canDelete, parentRecordField, RecordTypeId, createFields);
    
        return wrapper;
    }
   
    // This function brings the labels of the fields on the master Sobject. Used in making the columns with datatable in the lwc component.
    public static Map<String, Map<String,String>> getRelatedLabels(String customMetadataName, String id, Boolean baseCreate){
    
        RelatedList__mdt customMetadata;
        
        if (baseCreate == true){
            customMetadata = RelatedListController.createMetadataRecord();
        } else {
            customMetadata = [SELECT Create_Fields__c, Display_Fields__c, SObject__c, Parent_Record_Field__c, Where_Clause__c, RecordType_Name__c  FROM RelatedList__mdt WHERE Name__c = :customMetadataName Limit 1];
        }
        
        String type = String.valueOf(customMetadata.get('SObject__c'));
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, Map<String,String>> fieldMapLabels =  new Map<String, Map<String,String>>() ;
        
        String labelFromMap;
        String apiNameFromMap;
        String typeFromMap;
      
        for (String fieldName: fieldMap.keySet()) {
        // list of all field API name
         //It provides to get the object fields label.
         apiNameFromMap = String.valueOf(fieldMap.get(fieldName));
         labelFromMap = fieldMap.get(fieldName).getDescribe().getLabel();
         typeFromMap = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
        
         Map<String, String> fieldMapInfo =  new Map<String, String>() ;
         fieldMapInfo.put('label',labelFromMap);
         fieldMapInfo.put('type',typeFromMap);
         
         fieldMapLabels.put(apiNameFromMap,fieldMapInfo);
        }
        
        return fieldMapLabels;
    }

}