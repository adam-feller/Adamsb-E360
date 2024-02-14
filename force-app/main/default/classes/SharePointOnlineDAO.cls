public without sharing class SharePointOnlineDAO {

    public static List<items_SharePointOnline__x> getSharePointDocumentByDocumentTypeChainBUOrStoreNumber(List<String> documentTypes, String chain, String vipInstance,
                                                                                                        String compositeKey, String warehouse, String premise, 
                                                                                                        String controllable, String salesOrg) {                                              
                                                                                                           
        return [SELECT Id, Name__c, Store_Number__c, LicenseType__c, DownloadUrl__c, Tags__c, BU__c, ExternalId,
                Expiration_Date__c, Premise__c, Document_Type__c, Warehouse__c, Controllable__c,Salesorg__c, Expiration_Date_New__c
                FROM items_SharePointOnline__x 
                WHERE IsFolder__c = false 
                AND Document_Type__c IN :documentTypes
                AND (                                                                                                          
                        (
                            (Tags__c LIKE :chain
                            AND BU__c LIKE :vipInstance)
                        
                            OR (Tags__c LIKE :chain
                            AND Warehouse__c LIKE :warehouse)
                        
                            OR (Premise__c LIKE :premise
                            AND BU__c LIKE :vipInstance)
                        
                            OR (Premise__c LIKE :premise
                            AND Warehouse__c LIKE :warehouse)
                        
               	            OR (Premise__c LIKE :premise
                            AND Tags__c LIKE :chain)
                        
                            OR (Tags__c LIKE :chain)
                        
                            OR (Warehouse__c LIKE :warehouse)
                
                            // MJ Changes below: BSSP 1214  
                            OR (Controllable__c LIKE :controllable
						    AND Warehouse__c LIKE :warehouse
						    AND Premise__c LIKE :premise
					        AND Salesorg__c LIKE :salesOrg)
 				
                            OR (Controllable__c LIKE :controllable
						    AND Warehouse__c LIKE :warehouse
						    AND Premise__c LIKE :premise)
 				
                            OR (Salesorg__c LIKE :salesOrg
						    AND Premise__c LIKE :premise)
				            // MJ changes above: BSSP 1214
                        )
                        OR Store_Number__c LIKE :compositeKey
                    ) ];
    }

    public static List<items_SharePointOnline__x> getSharePointDocumentByLicenseType(List<String> documentTypes, String salesOrg, String licenseType) {                                              
        // AZ changes below: BSSP 1998                                                                                        
        return [SELECT Id, Name__c, Store_Number__c, LicenseType__c, DownloadUrl__c, Tags__c, BU__c, ExternalId,
                Expiration_Date__c, Premise__c, Document_Type__c, Warehouse__c, Controllable__c,Salesorg__c, Expiration_Date_New__c
                FROM items_SharePointOnline__x 
                WHERE IsFolder__c = false 
                AND Document_Type__c IN :documentTypes
                AND (
                        (Salesorg__c LIKE :salesOrg
                        AND LicenseType__c LIKE :licenseType)
                    )
                ];
        // AZ change above: BSSP 1998
    }
}