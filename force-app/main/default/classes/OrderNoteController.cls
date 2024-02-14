public without sharing class OrderNoteController {

    @AuraEnabled
    public static Order getOrder(String orderId) {
        List<Order> orderList = OrderDAO.getOrderDetailsbyId(orderId);        
        return orderList[0];
    }

	@AuraEnabled
    public static Account getAccount(String accountId) {
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{accountId});        
        return accountList[0];
    }
    
    @AuraEnabled
    public static Account getAccountByOrderId(String orderId) {
		List<Order> orderList = OrderDAO.getOrderDetailsbyId(orderId);        
        List<Account> accountList = AccountDAO.getAccountsByIds(new Set<Id>{orderList[0].AccountId});        
        return accountList[0];
    }
    
    @AuraEnabled
    public static Boolean createNote(String orderId, String accountId, String title, Blob noteVal) {
        try {                              
			ContentNote note = new ContentNote();
        	note.Content = noteVal;
        	note.Title = title;
        	insert note;
        
        	//Link to the Order 
			ContentDocumentLink orderCntDocLink = new ContentDocumentLink();
			orderCntDocLink.LinkedEntityId = orderId; // Specify your parent Id 
			orderCntDocLink.ContentDocumentId = note.Id;  //Content Note Id
			orderCntDocLink.shareType = 'V'; // Specify your sharing type 
			insert orderCntDocLink;
            
            //Link to the Account
			ContentDocumentLink accCntDocLink = new ContentDocumentLink();
			accCntDocLink.LinkedEntityId = accountId; // Specify your parent Id 
			accCntDocLink.ContentDocumentId = note.Id;  //Content Note Id
			accCntDocLink.shareType = 'V'; // Specify your sharing type 
			insert accCntDocLink;
    		return true;    
        } catch(Exception e) {
            return false;
        }
	}
    
}