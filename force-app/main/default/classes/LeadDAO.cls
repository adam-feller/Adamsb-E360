public without sharing class LeadDAO {
    
    @AuraEnabled(cacheable=true)
    public static List<Lead> getConvertedNCRList() {
        return [SELECT Id, Business_Unit__c, Requested_For__c, Company, Licensee_Name__c, Street, City, State, PostalCode, County__c, FirstName, LastName, 
                Name, Phone, Fax, License_1__c, License_Expiration_Date__c, License_Type__c, License_Status__c, Tax_ID_Seller_Permit__c, Beer_Salesman_1__c, Beer_Salesman_2__c,
                Beer_Salesman_3__c, Beer_Salesman_5__c, Beer_Salesman_6__c, Supervisor__c, Supervisor_2__c, Supervisor_3__c, Package_Type__c, Draft_Status__c, Seasonal_Close_Month__c, Seasonal_Open_Month__c,
                Displayable__c, POS_Materials__c, Special_Instructions_Short__c, Class__c, Subclass__c, Sell_Type__c, Chain__c, Chain__r.Chain_Id__c, Chain_Independent__c, Beer_Industry_Volume__c,
                Civilian_Military__c, Ethnic_Patron__c, Lifestyle__c, Occupation_Code__c, Patron_Age_Code__c, Residence__c, Company__c, Warehouse__c, PDA_Print_UPC_Barcode__c,
                UPC_Print__c, Barcoded_Invoice__c, Print_UCS_Code_Labels__c, Print_Separate_Empty_Invoice__c, Terms__c, Premise__c, Requested_Delivery_Days__c, Store_Number__c,
                Email, Special_Instructions_Long__c, Delivery_Open_Time_1__c, Delivery_Close_Time_1__c, Delivery_Open_Time_2__c, Delivery_Close_Time_2__c, Comments_for_MDM_Team__c, 
                ResponseJSON__c, Status, NCRGUID__c, ConvertedDate, ConvertedAccountId, taxJurisdiction__c
                FROM Lead
                WHERE isConverted = true AND My_Request__c = true ORDER BY ConvertedDate DESC];
    }

    public static Lead getLeadById(Id leadId) {       
        return [SELECT Id, Business_Unit__c,OwnerId, Requested_For__c, requested_for__r.FederationIdentifier, Company, Licensee_Name__c, Street, City, State, PostalCode, County__c, FirstName, LastName, 
                Name, Phone, Fax, License_1__c, License_Expiration_Date__c, License_Type__c, License_Status__c, Tax_ID_Seller_Permit__c, Beer_Salesman_1__c, Beer_Salesman_2__c,
                Beer_Salesman_3__c, Beer_Salesman_5__c, Beer_Salesman_6__c, Supervisor__c, Supervisor_2__c, Supervisor_3__c, Package_Type__c, Draft_Status__c, Seasonal_Close_Month__c, Seasonal_Open_Month__c,
                Displayable__c, POS_Materials__c, Special_Instructions_Short__c, Class__c, Subclass__c, Sell_Type__c, Chain__c, Chain__r.Chain_Id__c, Chain_Independent__c, Beer_Industry_Volume__c,
                Civilian_Military__c, Ethnic_Patron__c, Lifestyle__c, Occupation_Code__c, Patron_Age_Code__c, Residence__c, Company__c, Warehouse__c, PDA_Print_UPC_Barcode__c,
                UPC_Print__c, Barcoded_Invoice__c, Print_UCS_Code_Labels__c, Print_Separate_Empty_Invoice__c, Terms__c, Premise__c, Requested_Delivery_Days__c, Store_Number__c,
                Email, Special_Instructions_Long__c, Delivery_Open_Time_1__c, Delivery_Close_Time_1__c, Delivery_Open_Time_2__c, Delivery_Close_Time_2__c, Comments_for_MDM_Team__c, 
                ResponseJSON__c, Status, NCRGUID__c, Callout_Retry_Attempts__c, taxJurisdiction__c
                FROM Lead
                WHERE Id = :leadId];
    }

    public static List<Lead> updateLeads(List<Lead> leadsToUpdate) {
        update leadsToUpdate;
        return leadsToUpdate;
    }
}