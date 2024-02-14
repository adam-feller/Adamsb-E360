/**
 * @description       : Access the Objective_Filter__mdt (custom metadata)
 * @author            : cbraaten@reyesholdings.com
 * @last modified on  : 11-29-2022
 * @last modified by  : cbraaten@reyesholdings.com
**/
public with sharing class ObjectiveFilterDAO {

    public static List<Objective_Filter__mdt> getObjectiveAccountFilters() {
        return [SELECT Id, MasterLabel, Order__c, API_Field_Name__c, Field_Type__c, Filter_Options_API_Field_Name__c,
                Query_Filter_Condition__c, Filter_Options_API_Object__c, Filter_Help_Text__c
                FROM Objective_Filter__mdt
                WHERE Filter_Options_API_Object__c = 'Account' OR Filter_Options_API_Object__c = 'Chain__c'
                ORDER BY Order__c];
    }

    public static List<Objective_Filter__mdt> getObjectiveProductFilters() {
        return [SELECT Id, MasterLabel, Order__c, API_Field_Name__c, Field_Type__c, Filter_Options_API_Field_Name__c,
                Query_Filter_Condition__c, Filter_Options_API_Object__c, Filter_Help_Text__c, RecordTypeId__c
                FROM Objective_Filter__mdt
                WHERE Filter_Options_API_Object__c = 'Product2'
                ORDER BY Order__c];
    }

}