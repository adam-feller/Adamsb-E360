global class TTOAuthorizationCleanup implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT Id 
                FROM TTO_Authorization__c 
                WHERE Account__c NOT IN 
                    (
                        SELECT AccountId 
                        FROM Order 
                        WHERE CreatedDate = LAST_N_MONTHS:6
                    ) 
                AND CreatedDate < LAST_N_MONTHS:6     
            ]
        );
    }

    global void execute(Database.BatchableContext bc, List<TTO_Authorization__c> ttoAuthList) {
        Database.delete(ttoAuthList);
    }

    global void finish(Database.BatchableContext bc) {
        //Do nothing
    }
}