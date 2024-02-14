/**
 * Created by alexander.velitsky on 12/14/20.
 */

public without sharing class AccountChangeEventTriggerHandler {
    static Id RETAIL_RECORDTYPEID = getRetailRecordType();

    private static Id getRetailRecordType(){
        return [SELECT Id FROM RecordType WHERE DeveloperName = 'Retail_Store' AND SobjectType = 'Account' LIMIT 1].Id;
    }

    public static void handleEvent(List<AccountChangeEvent> events) {
        List<Pricebook2> prbList = new List<Pricebook2>();
        Map<Id, Pricebook2> pbMap= new Map<Id, Pricebook2>();
        for (AccountChangeEvent event : events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if (header.changeType == 'CREATE') {
                if (event.RecordTypeId == RETAIL_RECORDTYPEID && event.isActive__c) {
                    for (ID accountID : header.recordIds){
                        Pricebook2 prb = new Pricebook2 (
                            AccountId__c = accountID,
                            Name = event.ExternalId__c,
                            IsActive = true
                        );
                        prbList.add(prb);
                    }
                }
                //Moved to Scheduled Job 'ScheduleBatchBuildAccountTeams'
                //RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(header.recordIds, false);
            } else if (header.changeType == 'UPDATE') {
                for (String field : header.getChangedFields()) {
                    if (field.toLowerCase() == 'isactive__c' && (Boolean) event.get(field) ){
                        for (ID accountID : header.recordIds){
                            pbMap.put(header.recordIds[0],new Pricebook2 (
                                AccountId__c = accountID,
                                IsActive = true
                        	));
                        }
                    }
                }
                //Moved to Scheduled Job 'ScheduleBatchBuildAccountTeams'
                /*if(header.getChangedFields().contains('Account_Manager_Route__c') || header.getChangedFields().contains('Account_Manager_Route_2__c') || header.getChangedFields().contains('Account_Manager_Route_3__c')
                    || header.getChangedFields().contains('Account_Manager_Route_4__c') || header.getChangedFields().contains('Account_Manager_Route_5__c') || header.getChangedFields().contains('Account_Manager_Route_6__c')
                    || header.getChangedFields().contains('Sales_Manager_Route__c') || header.getChangedFields().contains('Sales_Manager_Route_2__c') || header.getChangedFields().contains('Sales_Manager_Route_3__c')
                    || header.getChangedFields().contains('Sales_Manager_Route_4__c') || header.getChangedFields().contains('Sales_Manager_Route_5__c') || header.getChangedFields().contains('Sales_Manager_Route_6__c')
                    || header.getChangedFields().contains('VIP_Instance__c') || header.getChangedFields().contains('OwnerId')){
                    if(!header.getChangedFields().contains('AccountSource')){
                        RouteAssignmentHandler.assignUserToAccountTeamWhenAccountRouteChanges(header.recordIds, false);
                    }
                }*/
            }
        }
        for (Pricebook2 pbiter : [SELECT Id, AccountId__c FROM Pricebook2 WHERE AccountId__c IN :pbMap.keySet()]){
            pbMap.remove(pbiter.AccountId__c);
        }
        for (Account acc: [SELECT Id, ExternalId__c FROM Account WHERE Id IN :pbMap.keySet() ]){
            pbMap.put(acc.Id, new Pricebook2 (
                    AccountId__c = acc.Id,
                    Name = acc.ExternalId__c,
                    IsActive = true
            ));
        }

        prbList.addAll(pbmap.values());
        insert prbList;
    }
}