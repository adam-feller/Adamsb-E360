public class BeerboardController {
    @AuraEnabled
    public static List<draftProductsParser> getBeerboardDraftInfo(String recordId) {
        List<Account> acctList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        String accountExternalId = acctList[0].VIP_Account_Number__c; 
		List<draftProductsParser> productParser;       
            if (accountExternalId != null){
                    HttpResponse beerBoardDraftResponse = BeerboardUtility.BeerboardCallout('Draft Products', accountExternalId);
                    if (beerBoardDraftResponse.getStatusCode() == 200){
                        productParser = (List<draftProductsParser>) JSON.deserialize(beerBoardDraftResponse.getBody(), List<draftProductsParser>.class);
                    }    
            } else{
                system.debug('NO RESPONSE from Get Draft Produts API');
            }
        return productParser;
    }
    
    @AuraEnabled
    public static List<notSoldAfterPurchaseParser> getBeerboardNotSoldAfterPurchase(String recordId) {
        List<Account> acctList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        String accountExternalId = acctList[0].VIP_Account_Number__c; 
		List<notSoldAfterPurchaseParser> productParser;       
            if (accountExternalId != null){
                    HttpResponse beerBoardNSAPResponse = BeerboardUtility.BeerboardCallout('Not Sold After Purchase', accountExternalId);
                    if (beerBoardNSAPResponse.getStatusCode() == 200){
                        productParser = (List<notSoldAfterPurchaseParser>) JSON.deserialize(beerBoardNSAPResponse.getBody(), List<notSoldAfterPurchaseParser>.class);
                    }    
            } else{
                system.debug('NO RESPONSE from Not Sold After Purchase API');
            }
        return productParser;
    }
    
    @AuraEnabled
    public static List<outOfCodeProductsParser> getBeerboardOutOfCodeProducts(String recordId) {
        List<Account> acctList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        String accountExternalId = acctList[0].VIP_Account_Number__c; 
		List<outOfCodeProductsParser> productParser;       
            if (accountExternalId != null){
                    HttpResponse beerBoardOOCResponse = BeerboardUtility.BeerboardCallout('Out Of Code Products', accountExternalId);
                    if (beerBoardOOCResponse.getStatusCode() == 200){
                        productParser = (List<outOfCodeProductsParser>) JSON.deserialize(beerBoardOOCResponse.getBody(), List<outOfCodeProductsParser>.class);
                    }    
            } else{
                system.debug('NO RESPONSE from Out Of Code Products API');
            }
        return productParser;
    }
    
        @AuraEnabled
    public static List<mandateComplianceParser> getBeerboardMandateCompliance(String recordId) {
        List<Account> acctList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        String accountExternalId = acctList[0].VIP_Account_Number__c; 
		List<mandateComplianceParser> productParser;       
            if (accountExternalId != null){
                    HttpResponse beerBoardMCResponse = BeerboardUtility.BeerboardCallout('Mandate Compliance', accountExternalId);
                    if (beerBoardMCResponse.getStatusCode() == 200){
                        productParser = (List<mandateComplianceParser>) JSON.deserialize(beerBoardMCResponse.getBody(), List<mandateComplianceParser>.class);
                    }    
            } else{
                system.debug('NO RESPONSE from Mandate Compliance API');
            }
        return productParser;
    }
    
    
    @AuraEnabled
    public static String getAccountExternalId(String recordId) {
        List<Account> acctList = AccountDAO.getAccountsByIds(new Set<Id>{recordId});
        String accountExternalId = acctList[0].VIP_Account_Number__c; 

        return accountExternalId;
    }
    
    public class draftProductsParser {     
        @AuraEnabled
        public String VIPNumber;
        @AuraEnabled
        public String Customer;
        @AuraEnabled
        public String ChainStoreNumber;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String Distributor;
        @AuraEnabled
        public String Brewery;
        @AuraEnabled
        public String Product;
        @AuraEnabled
        public String Style;
        @AuraEnabled
        public String ProductSKU;

    }

    public class notSoldAfterPurchaseParser {     
        @AuraEnabled
        public String VIPNumber;
        @AuraEnabled
        public String Customer;
        @AuraEnabled
        public String ChainStoreNumber;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String Distributor;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String Product;
        @AuraEnabled
        public String ProductSKU;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public String Size;
        @AuraEnabled
        public String PurchaseDate;

    }
    
        public class outOfCodeProductsParser {     
        @AuraEnabled
        public String VIPNumber;
        @AuraEnabled
        public String Customer;
        @AuraEnabled
        public String ChainStoreNumber;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String Distributor;
        @AuraEnabled
        public String purchasedate;
        @AuraEnabled
        public String Product;
        @AuraEnabled
        public String supplierProductSKU;
        @AuraEnabled
        public String dayDiff;

    }
    
        public class mandateComplianceParser {     
        @AuraEnabled
        public String VIPNumber;
        @AuraEnabled
        public String Customer;
        @AuraEnabled
        public String ChainStoreNumber;
        @AuraEnabled
        public String Location;
        @AuraEnabled
        public String Distributor;
        @AuraEnabled
        public String Product;
        @AuraEnabled
        public String supplierProductSKU;
        @AuraEnabled
        public String BeerType;

    }
}