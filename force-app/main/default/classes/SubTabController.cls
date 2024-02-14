public without sharing class SubTabController {

    @AuraEnabled
    public static Order insertOrder(String accountId) {
        List<Account> accountRecord = AccountDAO.getAccountsByIds(new Set<Id>{accountId});
        Order newOrder = new Order();
        newOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        newOrder.AccountId = accountId;
        newOrder.EffectiveDate = System.today();
        newOrder.Status = 'Pending Draft';
        OrderDAO.insertOrders(new List<Order>{newOrder});
        List<Order> returnedOrder = OrderDAO.getOrderDetailsbyId(newOrder.Id);
        return returnedOrder[0];
    }

    @AuraEnabled
    public static Order getAccountInfo(String orderId) {
        List<Order> returnedOrder = OrderDAO.getOrderDetailsbyId(orderId);
        return returnedOrder[0];
    }
}