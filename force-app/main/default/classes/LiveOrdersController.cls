public with sharing class LiveOrdersController {

    @AuraEnabled
    public static User getUserDetails(){
        return UserDAO.getUser(UserInfo.getUserId())[0];
    }
}