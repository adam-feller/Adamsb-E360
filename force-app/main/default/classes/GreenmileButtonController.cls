/**
 * Created by alexander.velitsky on 9/10/20.
 */

public without sharing class GreenmileButtonController {
    @AuraEnabled
    public static User  getUserData(){
        User usr = UserDAO.getUser(UserInfo.getUserId())[0];
        if (usr.Greenmile_Date_Override__c == null || usr.Greenmile_Date_Override__c < Date.today()){
            usr.Greenmile_Route_Override__c = null;
            usr.Greenmile_Date_Override__c = null;
        }
        return usr;
    }

    @AuraEnabled
    public static String getUIThemeDescription() {
        String theme = UserInfo.getUiThemeDisplayed();
        return theme;
    }

}