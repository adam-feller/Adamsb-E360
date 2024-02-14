/**
* @description Apex controller used for custom filtered lookup component, customLookupCmp 
* retrieves list of sobjects, or predetermined sobject. without sharing to be utilized in portal context
* to allow for record creation with lookups users do not have visibility to
*/
public without sharing class CustomLookupController {
    /**
     * @description Queries objects and returns them.
     * @param searchKey the search term input by the user
     * @param sObjectApiName API name of the sobject to query
     * @param filter SOSL filter string to query records
     * @param numberResults number to limit soql query to. defaults to 5
     * @return List of sObjects
     */
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, string filter, Integer numberResults) {    
         List < sObject > results = new List < sObject > ();
         if(String.isBlank(sObjectAPIName) || String.isBlank(searchKey)){
            return results;
        }
        SObjectType objType = Schema.getGlobalDescribe().get(sObjectAPIName);
        if(objType == null){
            return results;
        }
         String whereClause = '';
         if (!String.isEmpty(filter)){
             whereClause = filter;
         }
         Integer limitNumber = 5;
         if(numberResults != null){
             limitNumber = numberResults;
         }
         String sanitizedSearchString = String.escapeSingleQuotes(searchKey);
         String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectApiName);
     
         String searchQuery  = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ';

         String nameField = getSobjectNameField(objType);

         searchQuery += sanitizedSObjectAPIName + '(id, ' + nameField + ' ' + whereClause + ') Limit '+ limitNumber;
         system.debug('searchquery: '+searchQuery);
         List<List<SObject>> searchList = search.query(searchQuery);
         for (sObject obj:searchList[0] ) {
             results.add(obj);
         }
         return results;
     }
     
    /**
     * @description Queries object by record ID and returns.
     * @param recordId the lookup recordId
     * @param sObjectApiName API name of the sobject to query
     * @return singular sObject
     */     
    @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = String.escapeSingleQuotes(recordId);    
         String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectApiName);
         string sQuery = 'Select Id,Name From ' + sanitizedsObjectApiName + ' Where Id = : sRecId LIMIT 1';
         
         List<SObject> searchList = Database.query(sQuery);
         for (sObject obj:searchList) {
            return obj;
         }
         return null;
     }
 
    /**
     * @description Gets the 'Name' field for an sObject, for display in lookup cmp.
     
     * @param sobjType API name of the sobject to get the Name
     * @return string of the Name field
     */ 
      @TestVisible
      private static String getSobjectNameField(SobjectType sobjType){
  
          //describes lookup obj and gets its name field
          String nameField = 'Name';
          Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
          for(schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
              Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
              if(fieldDescObj.isNameField() ){
                  nameField = fieldDescObj.getName();
                  break;
              }
          }
          return nameField;
      }
 }