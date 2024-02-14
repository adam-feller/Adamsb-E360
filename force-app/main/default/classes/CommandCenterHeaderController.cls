/**
 * Created by alexander.velitsky on 10/8/20.
 */

public without sharing class CommandCenterHeaderController {

    public class InitResults {
         @AuraEnabled
         public List<String> buOptions;
         @AuraEnabled
         public List<DynamicAppButton__mdt> customButtons;
         @AuraEnabled
         public User user;
    }
    
    @AuraEnabled
    public static InitResults initData() {
        User usr = UserDAO.getUser(UserInfo.getUserId())[0];

        if (usr.Greenmile_Date_Override__c == null || usr.Greenmile_Date_Override__c < Date.today()){
            usr.Greenmile_Route_Override__c = null;
            usr.Greenmile_Date_Override__c = null;
            usr.Greenmile_BU_Override__c = null;
        }
        InitResults results = new InitResults();
        results.user = usr;

        List<BU_Division__mdt> buDivisions = [SELECT Id, MasterLabel, Division__c FROM BU_Division__mdt];
        List<String> buOptions = new List<String>();
        for(BU_Division__mdt buObj : buDivisions){
            buOptions.add(buObj.MasterLabel);
        }
        results.buOptions = buOptions;

        String searchString = '%'+usr.VIP_Company__c+'%';
        List<DynamicAppButton__mdt> tempCustomButtons = [SELECT Order__c, 
                                                            MasterLabel, 
                                                            BU_filter__c, 
                                                            Button_Type__c, 
                                                            Button_value__c, 
                                                            Page_Name__c,
                                                            isAllowedForDesktop__c, 
                                                            isAllowedForMobile__c,
                                                         	isForMerch__c,
                                                            Profiles__c     
                                                    FROM DynamicAppButton__mdt 
                                                    WHERE BU_filter__c = NULL OR BU_filter__c =''
                                                    ORDER BY Order__C 
                                                    ASC NULLS LAST];

        //final button list
        List<DynamicAppButton__mdt> customButtons = New List<DynamicAppButton__mdt>();
        for(DynamicAppButton__mdt btn : tempCustomButtons){
            if(btn.Profiles__c.contains(',')){
                List<String> profiles = btn.Profiles__c.split(', ');
                if(profiles.contains(usr.Profile.Name)){
        	        customButtons.add(btn);
                }
            } else {
                if(!(btn.Profiles__c.contains(','))){
                    if(btn.Profiles__c == 'All'){
                        customButtons.add(btn);
                    }
                }
            }
        }

        customButtons.addAll([SELECT Order__c, 
                                     MasterLabel, 
                                     BU_filter__c, 
                                     Button_Type__c, 
                                     Button_value__c, 
                                     Page_Name__c,
                                     isAllowedForDesktop__c, 
                              	     isForMerch__c,
                                     isAllowedForMobile__c
                             FROM DynamicAppButton__mdt 
                             WHERE BU_filter__c LIKE :searchString 
                             ORDER BY Order__C 
                             ASC NULLS LAST]);
                             
        results.customButtons=customButtons;
        return results;
    }

    @AuraEnabled
    public static User getUserData() {
        User usr = UserDAO.getUser(UserInfo.getUserId())[0];
            if (usr.Greenmile_Date_Override__c == null || usr.Greenmile_Date_Override__c < Date.today()){
            usr.Greenmile_Route_Override__c = null;
            usr.Greenmile_Date_Override__c = null;
            usr.Greenmile_BU_Override__c = null;
        }
        return usr;
    }

    @AuraEnabled
    public static User overrideUserRoute(String routeNumber, String buValue) {
        List <User> userList = UserDAO.getUser(UserInfo.getUserId());
        String userEmployeeId = userList[0].FederationIdentifier;
        String userVIPCompany = userList[0].VIP_Company__c;

        if(buValue == null){
            buValue = userVIPCompany;
        }

        User updatedUser = new User();
        updatedUser.Id = userList[0].Id;
        updatedUser.FederationIdentifier = userEmployeeId;
        updatedUser.Greenmile_Route_Override__c = routeNumber;
        updatedUser.Greenmile_BU_Override__c = buValue;
        updatedUser.Greenmile_Date_Override__c = System.today();

        if(updatedUser.Id != null){
            update updatedUser;
        }
        return updatedUser;
    }
    
    @AuraEnabled( cacheable=true )  
    public static List<Beerline_Home_Links__mdt > getBevLineHomeLinks() {        
        List <Beerline_Home_Links__mdt> homeLinks = [SELECT Id, MasterLabel, URL__c, Order__c, New_Browser_Tab__c FROM Beerline_Home_Links__mdt ORDER BY Order__c];
       	return homeLinks;
    }
    
}