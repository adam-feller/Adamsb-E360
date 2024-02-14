/**
 * Created by nick.vree on 1/11/21.
 */
public with sharing class OrderChangeEventTriggerHandler {

    public static void handleOrderEvent(List<OrderChangeEvent> OrderChangeEvents){
        List<OrderChangeEvent> createdOrders = new List<OrderChangeEvent>();
        List<OrderChangeEvent> updatedOrders = new List<OrderChangeEvent>();

        for (OrderChangeEvent event : OrderChangeEvents) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;

            if (header.changeType == 'CREATE') {
                createdOrders.add(event);
            }
            if (header.changeType == 'UPDATE') {
                updatedOrders.add(event);
            }
        }

        if(createdOrders.size()>0){
            TaskCreationHandler.createTaskForOrderPostingErrors(createdOrders);
            TaskCreationHandler.closeScheduledCallsBasedOnOrder(createdOrders);
            OrderSubmitHandler.submitBeerlineOrder(createdOrders);
        }

        if(updatedOrders.size()>0){
           TaskCreationHandler.createTaskForOrderPostingErrors(updatedOrders);
           TaskCreationHandler.closeScheduledCallsBasedOnOrder(updatedOrders);
        }
    }
}