public without sharing class StoreVisitTriggerHandler {
    public static void formulaToFieldStamp(List <CVS_Store_Visit__c> storeVisitList){
        for(CVS_Store_Visit__c sv: storeVisitList){
            sv.Assigned_Route__c = sv.Assigned_User_Assigned_Route__c;
            sv.FederationIdentifier__c = sv.Assigned_User_FederationIdentifier__c;
            sv.ExternalId__c = sv.Account_ExternalId__c;
            sv.Name__c = sv.Account_Name__c;
            sv.Class__c = sv.Account_Class__c;
            sv.BillingStreet__c = sv.Account_BillingStreet__c;
            sv.BillingCity__c = sv.Account_BillingCity__c;
            sv.BillingState__c = sv.Account_BillingState__c;
            sv.BillingPostalCode__c = sv.Account_BillingPostalCode__c;
            sv.BillingLatitude__c = sv.Account_BillingLatitude__c;
            sv.BillingLongitude__c = sv.Account_BillingLongitude__c;
            sv.Phone__c = sv.Account_Phone__c;
            sv.Requested_Delivery_Days__c = sv.Account_Requested_Delivery_Days__c;
            sv.Time_1__c = sv.Account_Time_1__c;
            sv.Close_Time_1__c = sv.Account_Close_Time_1__c;
            sv.Time_2__c = sv.Account_Time_2__c;
            sv.Close_Time_2__c = sv.Account_Close_Time_2__c;
        }
    }
}