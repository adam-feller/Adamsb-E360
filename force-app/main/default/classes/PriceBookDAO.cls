public without sharing class PriceBookDAO {
    private static id stdPriceBookId;  // Singleton, remember when first referenced
	
    //There is only one Pricebook which is standard. its id is always the same in sandboxes as in Production.
    //We hardcode this id because this field is indexed and it is the quickest way 
    public static Id getStdPriceBookId () {
        if (stdPriceBookId == null) {
            if (Test.isRunningTest()) {
                stdPriceBookId = Test.getStandardPricebookId();
            } else {
	        	stdPriceBookId = (Id) '01s6g000005nlLfAAI';   
            }
        }
        return stdPriceBookId;    
    }   


    public static List<PriceBook2> getPriceBookByAccountIds(Set<Id> accountIds){
        return [SELECT Id 
                FROM PriceBook2 
                WHERE AccountId__c IN :accountIds];
    }

    public static List<PriceBook2> getStandardPriceBook(){
        return [SELECT Id 
                FROM Pricebook2 
                WHERE isStandard = true 
                LIMIT 1];
    }

    public static List<PriceBook2> getPriceBookByTypeAndAccountId(Id accountId, String type){
        return [SELECT Id 
                FROM Pricebook2 
                WHERE AccountId__c = :accountId 
                AND Type__c = :type];
    }

    public static List<PriceBook2> insertPriceBooks(List<PriceBook2> priceBooksToInsert){
        insert priceBooksToInsert;
        return priceBooksToInsert;
    }
}