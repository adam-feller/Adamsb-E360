public without sharing class AccountTriggerHandler {
    public static void beforeInsertHandler(List<Account> newAccounts) {
        InactiveAccountHandler.processInactiveAccounts(newAccounts, null);
        RouteAssignmentHandler.assignUserToAccountWhenAccountRouteChanges(newAccounts, null);
        MerchRouteAssignmentHandler.assignMerchandiserToAccountWhenAccountRouteChanges(newAccounts, null);
        WarehouseSyncHandler.syncTextWarehouseWithLookupWarehouseOnAccount(newAccounts, null);
        VisitFrequencyHandler.calculateVisitFrequency(newAccounts, new Map <Id, Account>());
    }

    public static void beforeUpdateHandler(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        InactiveAccountHandler.processInactiveAccounts(newAccounts, oldAccountMap);
        RouteAssignmentHandler.assignUserToAccountWhenAccountRouteChanges(newAccounts, oldAccountMap);
        MerchRouteAssignmentHandler.assignMerchandiserToAccountWhenAccountRouteChanges(newAccounts, oldAccountMap);
        WarehouseSyncHandler.syncTextWarehouseWithLookupWarehouseOnAccount(newAccounts, oldAccountMap);
        VisitFrequencyHandler.calculateVisitFrequency(newAccounts, oldAccountMap);
    }

    public static void afterInsertHandler(List<Account> newAccounts) {
        TaskCreationHandler.createTaskForNewlyAssignedFSR(newAccounts, null);
        CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(newAccounts, null);
    }

    public static void afterUpdateHandler(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        CallScheduleHandler.checkForUpdatedCallScheduleDeliveryDay(newAccounts, oldAccountMap);
        CallScheduleHandler.checkForUpdatedSellType(newAccounts, oldAccountMap);
        CallScheduleHandler.cancelCallsAndDeleteDeliveryDayForIorOAccounts(newAccounts, oldAccountMap);
        TaskCreationHandler.createTaskForNewlyAssignedFSR(newAccounts, oldAccountMap);
        AlertCreationHandler.createOrCloseTermRelatedAlerts(newAccounts, oldAccountMap);
        TaskCloseHandler.closeAccountMissingDataTasks(newAccounts, oldAccountMap);
    }
}