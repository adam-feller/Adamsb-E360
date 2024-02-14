/**
 * Created by Christy Braaten on 2/22/2022 (BSSP-1274)
 */

public with sharing class MerchRouteAssignmentHandler {

    private static Reyes_Org_Setting__c REYES_SETTING;
    //Created the complete map of all Routes assigned to active users in salesforce.
    public static Map<String, Id> ROUTE_TO_USER_ID_MAP;
    public static Map<Id, Id> USER_ID_TO_MANAGER_ID_MAP;
    //Contains the salesforce Id of the user used to own the routes that don't have a user in salesforce.
    //if does not exist, than accounts will be left assigned to previous owner or the one, who created it.
    public static Id DEFAULT_UNASSIGNED_USER_ID = getUnassignedUserId();

    public static Reyes_Org_Setting__c getReyesSetting() {
        return (REYES_SETTING == null) ? Reyes_Org_Setting__c.getOrgDefaults() : null;
    }

    public static Id getUnassignedUserId() {
    	try {
        	return Id.valueOf(getReyesSetting()?.Unassigned_Merch_Route_Owner_Id__c);
        } catch (Exception ex){
        	return null;
    	}
	}
    
    public static void generateUserMaps() {        
        ROUTE_TO_USER_ID_MAP = new Map<String, Id>();
        USER_ID_TO_MANAGER_ID_MAP = new Map<Id, Id>();
        for (User usr : [SELECT Id, VIP_Company__c, Merch_Route__c, ManagerId FROM User WHERE Merch_Route__c != NULL AND VIP_Company__c != NULL AND IsActive = :TRUE]) {
            if (String.isNotBlank(usr.Merch_Route__c) && String.isNotBlank(usr.VIP_Company__c)) {
                ROUTE_TO_USER_ID_MAP.put(usr.VIP_Company__c+'*'+usr.Merch_Route__c, usr.Id);
                USER_ID_TO_MANAGER_ID_MAP.put(usr.Id, usr.ManagerId);
            }
        }
    }

    /* * * * *
    *  Description: Method to reassign a correct Merchandiser user and update Account Team
    *  Takes the list of new accounts or changed accounts and a map of old accounts (if they exist) from trigger
    *  as input
    * * * * */
    public static void assignMerchandiserToAccountWhenAccountRouteChanges(List<Account> changedAccounts, Map<Id, Account> oldAccounts) {
        //First prepare the User maps that are needed
        generateUserMaps();
        try{
            Boolean isNew = (oldAccounts == null);
            Map<Id,Id> changedAccountMap = new Map<Id,Id>();
            //for every changed account
            for (Account acc : changedAccounts) {
                //if it is a new account or Merchandiser Route has changed
                if (isNew || isMerchRouteChanged(acc, oldAccounts)) {
                   //If the Merchandiser route is not blank
                   if (String.isNotBlank(acc.Merch_Route__c) && String.isNotBlank(acc.VIP_Instance__c)) {
                       //get the user assigned to that route from the map of users
                       if (ROUTE_TO_USER_ID_MAP.containsKey(acc.VIP_Instance__c+'*'+acc.Merch_Route__c)) {
                           acc.Merchandiser__c = ROUTE_TO_USER_ID_MAP.get(acc.VIP_Instance__c+'*'+acc.Merch_Route__c);
                           changedAccountMap.put(acc.Id, acc.Merchandiser__c);
                       } else if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                           acc.Merchandiser__c = DEFAULT_UNASSIGNED_USER_ID;                           
                           changedAccountMap.put(acc.Id, null);
                       }
                   } else {
                       if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                           acc.Merchandiser__c = DEFAULT_UNASSIGNED_USER_ID;
                           changedAccountMap.put(acc.Id, null);
                       }
                   }                   
                }                
            }
            
            //Get the Merchandiser Account Team Members for all Changed Accounts
            Map<Id, AccountTeamMember> merchATMMap = new Map<Id, AccountTeamMember>();
            Map<Id, AccountTeamMember> merchMgrATMMap = new Map<Id, AccountTeamMember>();
            for (AccountTeamMember atm : [SELECT Id, AccountId FROM AccountTeamMember WHERE TeamMemberRole = 'Merchandiser' AND AccountId IN :changedAccountMap.keyset()]) {
                merchATMMap.put(atm.AccountId, atm);
            }
            for (AccountTeamMember atmMgr : [SELECT Id, AccountId FROM AccountTeamMember WHERE TeamMemberRole = 'Merchandiser Supervisor' AND AccountId IN :changedAccountMap.keyset()]) {
                merchMgrATMMap.put(atmMgr.AccountId, atmMgr);
            }
            List<AccountTeamMember> merchListToDelete = new List<AccountTeamMember>();
            List<AccountTeamMember> merchListToInsert = new List<AccountTeamMember>();
            
            //Find updates and deletes for Merchandiser
            for (Id atmId : merchATMMap.keyset()) {      
                Id newId = changedAccountMap.get(atmId);
                AccountTeamMember atm = merchATMMap.get(atmId);
                AccountTeamMember atmMgr = merchMgrATMMap.get(atmId);
                if (newId == null) {
                    if (atm != null) {
                    	merchListToDelete.add(atm);
                    }
                    if (atmMgr !=  null) {
                    	merchListToDelete.add(atmMgr);
                    }
                } else {
                    //First delete the existing Account Team Members (Note: you cannot update the UserId field of an AccountTeamMember)
                    if (atm != null) {
                    	merchListToDelete.add(atm);
                    }
                    if (atmMgr !=  null) {
                    	merchListToDelete.add(atmMgr);
                    }
                    //Then create the new Account Team Members
                    Id merchId = changedAccountMap.get(atm.AccountId);
                    merchListToInsert.add(createNewTeamMember(atm.AccountId, merchId, 'Merchandiser'));
                    Id merchMgrId = USER_ID_TO_MANAGER_ID_MAP.get(merchId);
                    if (merchMgrId != null) {
                    	merchListToInsert.add(createNewTeamMember(atm.AccountId, merchMgrId, 'Merchandiser Supervisor'));
                    }
                }
            }
			//Find any inserts for Merchandiser
            for (Id accId : changedAccountMap.keyset()) {
                if (changedAccountMap.get(accId) != null && merchATMMap.get(accId) == null) {
 					Id merchId = changedAccountMap.get(accId);
                    merchListToInsert.add(createNewTeamMember(accId, merchId, 'Merchandiser'));
                    Id merchMgrId = USER_ID_TO_MANAGER_ID_MAP.get(merchId);
                    if (merchMgrId != null) {
                    	merchListToInsert.add(createNewTeamMember(accId, merchMgrId, 'Merchandiser Supervisor'));
                    }                    
                }
            }
            if (merchListToDelete.size() > 0) {
                AccountTeamMemberDAO.deleteAccountTeamMembers(merchListToDelete);
            }
            if (merchListToInsert.size() > 0) {
                AccountTeamMemberDAO.insertAccountTeamMembers(merchListToInsert);
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'MerchRouteAssignmentHandler', 'assignMerchandiserToAccountWhenAccountRouteChanges()');
        }
    }

    //checks if account Route for Merchandiser was changed
    //Actual account record and the map of old accounts (passed through from trigger) as an input
    @TestVisible
    private static Boolean isMerchRouteChanged(Account acc, Map<Id, Account> oldAccounts) {
        Account oldAccount = oldAccounts.get(acc.Id);
        return acc.Merch_Route__c != oldAccount.Merch_Route__c;
    }   

	private static AccountTeamMember createNewTeamMember(Id accountId, Id userId, String teamRole){
        AccountTeamMember newTeamMember = new AccountTeamMember();
        newTeamMember.AccountAccessLevel = 'Read';
        newTeamMember.CaseAccessLevel = 'Edit';
        newTeamMember.OpportunityAccessLevel = 'Edit';
        newTeamMember.AccountId = accountId;
        newTeamMember.UserId = userId;
        newTeamMember.TeamMemberRole = teamRole;
        return newTeamMember;
    }

    /* * * * *
    *  Description: Method reassign a correct Merchandiser owning the route based on route assigned to them.
    *  Takes the list of new users or changed users and a map of old users (if they exist) from trigger
    *  as input and updates accounts based on that info.
    *  Handles number of situations:
    *  1. Updates Merchandiser__c field
    *  2. Updates Merchandiser Account Team Member or creates it
    *  2. Assigns Merchandiser old accounts to other user with corresponding route if that user exists
    * * * * */

    public static void assignAccountsToMerchandisersWhenUserRouteChanges(List<User> changedUsers, Map<Id, User> oldUsers) {
		//First prepare the User maps that are needed
        generateUserMaps();
        try{
            Boolean isNew = (oldUsers == null);
            Map<String, Id> routeToNewMerchandiserIdMap = new Map<String, Id>();
            Set<String> orphanedRoutes = new Set<String>();            
			Set<Id> userIds = new Set<Id>();
            User oldUser;

            //For every modified user
            for (User usr : changedUsers) {
                userIds.add(usr.Id);
                //if the Merchandiser Route, VIP Company or Manager has changed
                if (!isNew) oldUser = oldUsers.get(usr.Id);
                if (isNew || usr.Merch_Route__c != oldUser.Merch_Route__c || usr.VIP_Company__c != oldUser.VIP_Company__c || usr.ManagerId != oldUser.ManagerId) {
                    //if new Route is not Blank put that new route in route-to-owner map
                    if (String.isNotBlank(usr.VIP_Company__c) && String.isNotBlank(usr.Merch_Route__c)) {
                        routeToNewMerchandiserIdMap.put(usr.VIP_Company__c+'*'+usr.Merch_Route__c, usr.Id);
                    }
                    //If old Route is not blank, remember it as potential "orphan"
                    if (!isNew && String.isNotBlank(oldUser.VIP_Company__c) && String.isNotBlank(oldUser.Merch_Route__c)) {
                        orphanedRoutes.add(oldUser.VIP_Company__c+'*'+oldUser.Merch_Route__c);
                    }
                }
            }
            //Go through the list of all the orphans
            for(String orphan : orphanedRoutes){
                //and check if there is a new user that going to own it
                if (!routeToNewMerchandiserIdMap.containsKey(orphan)){
                    //if there is no new user, check the map of existing users has it
                    if (ROUTE_TO_USER_ID_MAP.containsKey(orphan) && !userIds.contains(ROUTE_TO_USER_ID_MAP.get(orphan))) {             
                        routeToNewMerchandiserIdMap.put(orphan,ROUTE_TO_USER_ID_MAP.get(orphan));
                    } else if (DEFAULT_UNASSIGNED_USER_ID != null) {
                        //or assign the default one if no user assigned
                        routeToNewMerchandiserIdMap.put(orphan,DEFAULT_UNASSIGNED_USER_ID);
                    }
                }
            }

            //SELECT all the accounts which are subject to new route changes for Merchandiser
            List<Account> accUpdate = [SELECT Id, Merch_Route__c, VIP_Instance__c, (SELECT Id FROM AccountTeamMembers WHERE TeamMemberRole LIKE 'Merchandiser%') 
                    FROM Account
                    WHERE Merch_Route_Compound_ID__c IN :routeToNewMerchandiserIdMap.keySet()
                	FOR UPDATE
            ];            

            List<AccountTeamMember> merchListToDelete = new List<AccountTeamMember>();
            List<AccountTeamMember> merchListToInsert = new List<AccountTeamMember>();   
            //Update Merchandiser for each of those accounts
            for (Account acc : accUpdate) {
                //Modify Merchandiser if Merch_Route__c corresponds to a map value
                if (String.isNotBlank(acc.VIP_Instance__c) && String.isNotBlank(acc.Merch_Route__c) && routeToNewMerchandiserIdMap.containsKey(acc.VIP_Instance__c+'*'+acc.Merch_Route__c)) {
                    acc.Merchandiser__c = routeToNewMerchandiserIdMap.get(acc.VIP_Instance__c+'*'+acc.Merch_Route__c);
                    //Update or Create Account Team Member
                    if (acc.AccountTeamMembers == null || acc.AccountTeamMembers.isEmpty()) {
                        if (acc.Merchandiser__c != DEFAULT_UNASSIGNED_USER_ID) {
                        	merchListToInsert.add(createNewTeamMember(acc.Id, acc.Merchandiser__c, 'Merchandiser'));
							Id merchMgrId = USER_ID_TO_MANAGER_ID_MAP.get(acc.Merchandiser__c);
                    		if (merchMgrId != null) {
                    			merchListToInsert.add(createNewTeamMember(acc.Id, merchMgrId, 'Merchandiser Supervisor'));
                    		}                               
                        }
                    } else {
                        //First delete the existing Account Team Member  (Note: you cannot update the UserId field of an AccountTeamMember)
                        for (AccountTeamMember accTeamMember : acc.AccountTeamMembers) {
                        	merchListToDelete.add(accTeamMember);  //Delete both the Merchandiser and Merchandiser Supervisor if there is one    
                        }                    	
                    	//Then create the new Account Team Member
                    	if (acc.Merchandiser__c != DEFAULT_UNASSIGNED_USER_ID) {
                    		merchListToInsert.add(createNewTeamMember(acc.Id, acc.Merchandiser__c, 'Merchandiser'));
		                    Id merchMgrId = USER_ID_TO_MANAGER_ID_MAP.get(acc.Merchandiser__c);
                    		if (merchMgrId != null) {
                    			merchListToInsert.add(createNewTeamMember(acc.Id, merchMgrId, 'Merchandiser Supervisor'));
                    		}   
                        }
                    }                    
                }
            }
            AccountDAO.updateAccounts(accUpdate);
           	if (merchListToDelete.size() > 0) {
                AccountTeamMemberDAO.deleteAccountTeamMembers(merchListToDelete);
            }
            if (merchListToInsert.size() > 0) {
                AccountTeamMemberDAO.insertAccountTeamMembers(merchListToInsert);
            }                              
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'MerchRouteAssignmentHandler', 'assignAccountsToMerchandisersWhenUserRouteChanges()');
        }
    }

}