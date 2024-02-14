public class sendOrderEmailAlertInvocable {

	@InvocableMethod(label='Send Order Confirm Email' 
                     description='Sends order email alerts when an order is posted to VIP' 
                     category='Order')
    
  	public static void sendOrderEmail(List<String> listOrderIds) {
        List<Order> orders = [SELECT Id, Order_Placed_By__r.Email, 
                              Account.Owner.Email, 
                              Account.Owner.Manager.Email, 
                              Account.Primary_POC_email__c,
                              Account.Primary_POC__c,
                              Account.Primary_POC__r.EmailOrderConfirmation__c, 
                              Account.OwnerId,
                              AccountId,
                              Account.Owner.ManagerId,
                              Order_Placed_By__c,
                              Order_Placed_By__r.EmailOrderConfirmation__c 
                              FROM Order
                              WHERE Id IN :listOrderIds];

        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate orderConfirm = [SELECT Id FROM EmailTemplate WHERE Name = 'VF Order Submission Confirmation' LIMIT 1];

        if(orderConfirm != null){
            for(Order o : orders){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(orderConfirm.Id, null, o.Id);
                List<String> toAddresses = new List<String>();
                if(o.AccountId != null){
                    if(o.Account.OwnerId != null){
                        if(o.Account.Owner.Email != null){
                            email.setTargetObjectId(o.Account.OwnerId);
                        }
                    }
                }

                if(o.Order_Placed_By__c != null){
                    if(o.Order_Placed_By__r.Email != null && o.Order_Placed_By__r.EmailOrderConfirmation__c == true){
                        toAddresses.add(o.Order_Placed_By__r.Email);
                    }
                }

                if(!toAddresses.isEmpty()){
                    email.setToAddresses(toAddresses);
                }

                if(!toAddresses.isEmpty() || o.Account.Owner.Email != null){
                    email.setSaveAsActivity(false);
                    masterListMails.add(email);
                }
            }

            try{
                Messaging.sendEmail(masterListMails);
            }catch(Exception e){
                ErrorLog.insertErrorLog(e.getMessage(), String.valueOf(e.getLineNumber()), 'sendOrderEmailAlertInvocable', 'sendOrderEmail');
            }
        } 
    }
}