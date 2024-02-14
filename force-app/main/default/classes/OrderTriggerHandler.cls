public without sharing class OrderTriggerHandler {
	
    public static void beforeInsertHandler(List<Order> newOrders){
        stampAccountOwnerField(newOrders);

    }

    public static void beforeUpdateHandler(List<Order> newOrders, Map<Id, Order> oldOrderMap){
        stampAccountOwnerField(newOrders);
    }

    public static void beforeDeleteHandler(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        checkOrderStatusAndProfile(newOrders, oldOrderMap);
    }

    /* Populates the Account Owner to a lookup field on the Order object.
     * Required to send an Email to the Account Owner from an Order Triggered Journey
     * in Marketing Cloud.
    */
    public static void stampAccountOwnerField(List <Order> newOrders){
        for(Order o : newOrders){
            o.Account_Owner__c = o.Account_OwnerId_formula__c;
        }
    }

    public static void checkOrderStatusAndProfile(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        Boolean userAllowed = [SELECT count() 
                                FROM User 
                                WHERE Profile.Name IN ('System Administrator','Call Center Supervisor','Call Center') 
                                AND Id = :UserInfo.getUserId()] > 0;
        for (Order ord : newOrders) {
            if(!userAllowed) {
                ord.addError('You do not have permissions to delete this record!');
            }
            if(ord.Status == 'Posted to VIP') {
                ord.addError('Order in Posted to VIP Status cannot be deleted');
            }
        }
    }
}