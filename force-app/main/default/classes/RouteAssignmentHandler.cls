/**
 * Created by alexander.velitsky on 8/7/20.
 */

public with sharing class RouteAssignmentHandler {

    private static Reyes_Org_Setting__c REYES_SETTING;
    //Created the complete map of all Routes assigned to active users in salesforce.
    public static Map<String, Id> ROUTE_TO_USER_ID_MAP = generateUserMap();
    public static Map<String, Id> ROUTE_TO_MANAGER_ID_MAP = generateManagerMap();
    //Contains the salesforce Id of the user used to own the routes that don't have a user in salesforce.
    //if does not exist, than accounts will be left assigned to previous owner or the one, who created it.
    public static Id DEFAULT_UNASSIGNED_USER_ID = getUnassignedUserId();

    public static Reyes_Org_Setting__c getReyesSetting() {
        return (REYES_SETTING == null) ? Reyes_Org_Setting__c.getOrgDefaults() : null;
    }

    public static Id getUnassignedUserId() {
		try {
        	return Id.valueOf(getReyesSetting()?.Unassigned_Route_Owner_id__c);
        } catch (Exception ex) {
            if (Test.isRunningTest()) {
            	return UserInfo.getUserId();
            } else {
        		return null;
            }
		}
	}

    public static List<String> getUserLisToReassignId() {
        try {
            List<Id> idList = new List<id>();
            List<String> idStringList =  getReyesSetting()?.Recalculate_Owner_for_account_with_ids__c?.deleteWhitespace()?.split(',');
            for (String stringId : idStringList){
                try {
                    idList.add(Id.ValueOf(stringId));
                } catch(Exception ex) {

                }
            }
            return idList;
        } catch (Exception ex) {
            return new List<Id>();
        }
    }

    public static Map<String, Id> generateUserMap() {
        Map<String, Id> result = new Map<String, Id>();
        for (User usr : [SELECT Id, Assigned_route__c, CompanyName, VIP_Company__c, IsManager__c FROM User WHERE Assigned_route__c != NULL AND IsManager__c = False AND IsActive = True]) {
            if (String.isNotBlank(usr.Assigned_route__c)) {
                result.put(usr.VIP_Company__c+'*'+usr.Assigned_route__c, usr.Id);
            }
        }        
        return result;
    }
    
    public static Map<String, Id> generateManagerMap() {
        Map<String, Id> result = new Map<String, Id>();
        for (User usr : [SELECT Id, Assigned_route__c, CompanyName, VIP_Company__c, IsManager__c FROM User WHERE Assigned_route__c != NULL AND IsManager__c = True AND IsActive = True]) {
            if (String.isNotBlank(usr.Assigned_route__c)) {
                result.put(usr.VIP_Company__c+'*'+usr.Assigned_route__c, usr.Id);
            }
        }        
        return result;
    }

    //checks if account Route for Account Manager 1 or 2 was changed or if the Sell Type changes
    //Actual account record and the map of old accounts (passed through from trigger) as an input
    @TestVisible
    private static Boolean isAccountRouteOrSellTypeChanged(Account acc, Map<Id, Account> oldAccounts) {
        Account oldAccount = oldAccounts.get(acc.Id);
        return acc.Account_Manager_Route__c != oldAccount.Account_Manager_Route__c
                || acc.Account_Manager_Route_2__c != oldAccount.Account_Manager_Route_2__c
                || acc.Sales_Manager_Route__c != oldAccount.Sales_Manager_Route__c
                || acc.Sales_Manager_Route_2__c != oldAccount.Sales_Manager_Route_2__c
                //BSSP-2199 --Start-- New logic added for additional account changes
                || acc.Account_Manager_Route_2__c != oldAccount.Account_Manager_Route_2__c
                || acc.Account_Manager_Route_3__c != oldAccount.Account_Manager_Route_3__c
                || acc.Account_Manager_Route_4__c != oldAccount.Account_Manager_Route_4__c
                || acc.Account_Manager_Route_5__c != oldAccount.Account_Manager_Route_5__c
                || acc.Account_Manager_Route_6__c != oldAccount.Account_Manager_Route_6__c
                || acc.Sales_Manager_Route_3__c != oldAccount.Sales_Manager_Route_3__c
                || acc.Sales_Manager_Route_4__c != oldAccount.Sales_Manager_Route_4__c
                || acc.Sales_Manager_Route_5__c != oldAccount.Sales_Manager_Route_5__c
                || acc.Sales_Manager_Route_6__c != oldAccount.Sales_Manager_Route_6__c
                //BSSP-2199 --End-- New logic added for additional account changes
                || acc.VIP_Instance__c != oldAccount.VIP_Instance__c
                || acc.Sell_Type__c != oldAccount.Sell_Type__c
                || (acc.OwnerId != oldAccount.OwnerId
            		&& getUserLisToReassignId().contains(acc.OwnerId));
    }
    /* * * * *
    *   Description: Method reassign a correct Sales users owning the route based on route assigned to them.
    *  Takes the list of new accounts or changed accounts and a map of old accounts (if they exist) from trigger
    *  as input
    * * * * */
    public static void assignUserToAccountWhenAccountRouteChanges(List<Account> changedAccounts, Map<Id, Account> oldAccounts) {
        try{
            Boolean isNew = (oldAccounts == null);
            //for every changed account
            for (Account acc : changedAccounts) {
                //if it is a new account or Route has changed
                if (isNew || isAccountRouteOrSellTypeChanged(acc, oldAccounts)) {
                    //BSSP-2199 Added to mark Accounts for scheduled job: 'ScheduleBatchBuildAccountTeams'
                    acc.ProcessAccountTeamsBuild__c = true;
                    //If Sell Type is PRESELL, Owner is User with same route as Account_Manager_Route__c
                    if (acc.Sell_Type__c == 'PRESELL'){
                        //If the Account Manager route is not blank
                        if (String.isNotBlank(acc.Account_Manager_Route__c) && String.isNotBlank(acc.VIP_Instance__c)){
                            //get the user assigned to that route from the map of users
                            if (ROUTE_TO_USER_ID_MAP.containsKey(acc.Account_Manager_Route_CompoundID__c)) {                                
                                acc.OwnerId = ROUTE_TO_USER_ID_MAP.get(acc.Account_Manager_Route_CompoundID__c);
                            } else if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.OwnerId = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        } else {
                            if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.OwnerId = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        }
                        //If the Sales Manager route is not blank
                        if (String.isNotBlank(acc.Sales_Manager_Route__c) && String.isNotBlank(acc.VIP_Instance__c)) {
                            //get the user assigned to that route from the map of users
                            if (ROUTE_TO_MANAGER_ID_MAP.containsKey(acc.Sales_Manager_Route_CompoundID__c)) {
                                acc.Sales_Manager_Id__c = ROUTE_TO_MANAGER_ID_MAP.get(acc.Sales_Manager_Route_CompoundID__c);
                            } else if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.Sales_Manager_Id__c = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        } else {
                            if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.Sales_Manager_Id__c = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        }
                    }
                    //If Sell Type is INSIDE SALES, Owner is User with same route as Account_Manager_Route2__c
                    if (acc.Sell_Type__c == 'INSIDE SALES' || acc.Sell_Type__c == 'NATIONAL ACCTS') {
                        //If the Account Manager route is not blank
                        if (String.isNotBlank(acc.Account_Manager_Route_2__c) && String.isNotBlank(acc.VIP_Instance__c)) {
                            //get the user assigned to that route from the map of users
                            if (ROUTE_TO_USER_ID_MAP.containsKey(acc.Account_Manager_Route_CompoundID__c)) {
                                acc.OwnerId = ROUTE_TO_USER_ID_MAP.get(acc.Account_Manager_Route_CompoundID__c);
                            } else if (DEFAULT_UNASSIGNED_USER_ID != null){ //or assign the default one if no user assigned
                                acc.OwnerId = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        } else {
                            //acc.Account_Manager_Route_CompoundID__c = null;
                            if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.OwnerId = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        }
                        //If the Sales Manager route is not blank
                        if (String.isNotBlank(acc.Sales_Manager_Route_2__c) && String.isNotBlank(acc.VIP_Instance__c)) {
                            //get the user assigned to that route from the map of users
                            if (ROUTE_TO_MANAGER_ID_MAP.containsKey(acc.Sales_Manager_Route_CompoundID__c)) {
                                acc.Sales_Manager_Id__c = ROUTE_TO_MANAGER_ID_MAP.get(acc.Sales_Manager_Route_CompoundID__c);
                            } else if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.Sales_Manager_Id__c = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        } else {
                            //acc.Sales_Manager_Route_CompoundID__c = null;
                            if (DEFAULT_UNASSIGNED_USER_ID != null) { //or assign the default one if no user assigned
                                acc.Sales_Manager_Id__c = DEFAULT_UNASSIGNED_USER_ID;
                            }
                        }
                    }
                }
            }
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'RouteAssignmentHandler', 'assignUserToAccountWhenAccountRouteChanges()');
        }
    }

    /* * * * *
    *   Description: Method assigns users to Account Team when Routes on Account change.
    *  Takes the list of new accounts or changed accounts and a map of old accounts (if they exist) from trigger
    *  as input
    * * * * */
    public static void assignUserToAccountTeamWhenAccountRouteChanges(List<String> accountIds, Boolean runQueueableJobs) {
        List <Account> accounts = [SELECT Id, Account_Manager_Route__c, Account_Manager_Route_2__c, Account_Manager_Route_3__c, Account_Manager_Route_4__c, Account_Manager_Route_5__c, Account_Manager_Route_6__c, OwnerId,
                                    Sales_Manager_Route__c, Sales_Manager_Route_2__c, Sales_Manager_Route_3__c, Sales_Manager_Route_4__c, Sales_Manager_Route_5__c, Sales_Manager_Route_6__c, VIP_Instance__c FROM Account WHERE Id IN :accountIds];		        
		Set<Id> accountSet = new Set<Id>();
        for (String s : accountIds) {
            accountSet.add(s);
        }        
        List<AccountTeamMember> accountTeamMembers = AccountTeamMemberDAO.getAccountTeamMembersByAccountIds(accountSet);
        Map<Id,List<AccountTeamMember>> accountTeamMap = new Map<Id,List<AccountTeamMember>>();
        List<Objective_Account__c> objectiveAccsToUpdate = new List<Objective_Account__c>();
        
        for(AccountTeamMember teamMember : accountTeamMembers){
            if(!accountTeamMap.containsKey(teamMember.AccountId)){
                List<AccountTeamMember> accountTeam = new List<AccountTeamMember>();
                accountTeam.add(teamMember);
                accountTeamMap.put(teamMember.AccountId, accountTeam);
            }else{
                List<AccountTeamMember> accountTeam = accountTeamMap.get(teamMember.AccountId);
                accountTeam.add(teamMember);
            }
        }

        List<AccountTeamMember> AccountTeamMembersToDelete =  new List<AccountTeamMember>();
        List<AccountTeamMember> AccountTeamMembersToCreate =  new List<AccountTeamMember>();

        for(Account account : accounts){
            List<AccountTeamMember> oldAccountTeam = accountTeamMap.get(account.Id);
            Set<String> accountManagerRouteSet = new Set<String>();
            Set<String> salesManagerRouteSet = new Set<String>();
            String compoundId;
            
            //Add existing AccountTeam to List to delete if needed    
            if(oldAccountTeam != null){
                AccountTeamMembersToDelete.addAll(oldAccountTeam);
            }
            //Create a new Account Team
            List<AccountTeamMember> accountTeam = new List<AccountTeamMember>();
            //Go through AccountManager fields and create new AccountTeamMembers
            if(String.isNotBlank(account.Account_Manager_Route__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Account_Manager_Route__c;
                
                if (ROUTE_TO_USER_ID_MAP.containsKey(compoundId)) {
                    accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_USER_ID_MAP.get(compoundId), 'Sales Rep', '1'));
                }
                accountManagerRouteSet.add(account.Account_Manager_Route__c);
            }
            if(String.isNotBlank(account.Account_Manager_Route_2__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Account_Manager_Route_2__c;
                    
                if (ROUTE_TO_USER_ID_MAP.containsKey(compoundId) ) {
                    if(!accountManagerRouteSet.contains(account.Account_Manager_Route_2__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_USER_ID_MAP.get(compoundId), 'FSR', '2'));
                        accountManagerRouteSet.add(account.Account_Manager_Route_2__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_USER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';2';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Account_Manager_Route_3__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Account_Manager_Route_3__c;
                    
                if (ROUTE_TO_USER_ID_MAP.containsKey(compoundId) ) {
                    if(!accountManagerRouteSet.contains(account.Account_Manager_Route_3__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_USER_ID_MAP.get(compoundId), 'Wine/Liquor Rep', '3'));
                        accountManagerRouteSet.add(account.Account_Manager_Route_3__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_USER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';3';
                            }
                        }
                    }
                }
            }    
            if(String.isNotBlank(account.Account_Manager_Route_4__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Account_Manager_Route_4__c;
                    
                if (ROUTE_TO_USER_ID_MAP.containsKey(compoundId) ) {
                    if(!accountManagerRouteSet.contains(account.Account_Manager_Route_4__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_USER_ID_MAP.get(compoundId), 'Sales Rep', '4'));
                        accountManagerRouteSet.add(account.Account_Manager_Route_4__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                        if(teamMember.UserId == ROUTE_TO_USER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';4';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Account_Manager_Route_5__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Account_Manager_Route_5__c;
                    
                if (ROUTE_TO_USER_ID_MAP.containsKey(compoundId) ) {
                    if(!accountManagerRouteSet.contains(account.Account_Manager_Route_5__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_USER_ID_MAP.get(compoundId), 'Sales Rep', '5'));
                        accountManagerRouteSet.add(account.Account_Manager_Route_5__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_USER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';5';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Account_Manager_Route_6__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Account_Manager_Route_6__c;
                
                if (ROUTE_TO_USER_ID_MAP.containsKey(compoundId) ) {
                    if(!accountManagerRouteSet.contains(account.Account_Manager_Route_6__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_USER_ID_MAP.get(compoundId), 'Sales Rep', '6'));
                        accountManagerRouteSet.add(account.Account_Manager_Route_6__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_USER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';6';
                            }
                        }
                    }
                }
            }
            
            //Go through Sales Manager fields and create new AccountTeamMembers
            if(String.isNotBlank(account.Sales_Manager_Route__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Sales_Manager_Route__c;
                
                if (ROUTE_TO_MANAGER_ID_MAP.containsKey(compoundId)) {
                    accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_MANAGER_ID_MAP.get(compoundId), 'Sales Manager', '1'));
                }
                salesManagerRouteSet.add(account.Sales_Manager_Route__c);
            }
            if(String.isNotBlank(account.Sales_Manager_Route_2__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Sales_Manager_Route_2__c;
                    
                if (ROUTE_TO_MANAGER_ID_MAP.containsKey(compoundId) ) {
                    if(!salesManagerRouteSet.contains(account.Sales_Manager_Route_2__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_MANAGER_ID_MAP.get(compoundId), 'FSR Manager', '2'));
                        salesManagerRouteSet.add(account.Sales_Manager_Route_2__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_MANAGER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';2';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Sales_Manager_Route_3__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Sales_Manager_Route_3__c;
                    
                if (ROUTE_TO_MANAGER_ID_MAP.containsKey(compoundId) ) {
                    if(!salesManagerRouteSet.contains(account.Sales_Manager_Route_3__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_MANAGER_ID_MAP.get(compoundId), 'Wine/Liquor Manager', '3'));
                        salesManagerRouteSet.add(account.Sales_Manager_Route_3__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_MANAGER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';3';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Sales_Manager_Route_4__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Sales_Manager_Route_4__c;
                    
                if (ROUTE_TO_MANAGER_ID_MAP.containsKey(compoundId) ) {
                    if(!salesManagerRouteSet.contains(account.Sales_Manager_Route_4__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_MANAGER_ID_MAP.get(compoundId), 'Sales Manager', '4'));
                        salesManagerRouteSet.add(account.Sales_Manager_Route_4__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                        if(teamMember.UserId == ROUTE_TO_MANAGER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';4';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Sales_Manager_Route_5__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Sales_Manager_Route_5__c;
                    
                if (ROUTE_TO_MANAGER_ID_MAP.containsKey(compoundId) ) {
                    if(!salesManagerRouteSet.contains(account.Sales_Manager_Route_5__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_MANAGER_ID_MAP.get(compoundId), 'Sales Manager', '5'));
                        salesManagerRouteSet.add(account.Sales_Manager_Route_5__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                        if(teamMember.UserId == ROUTE_TO_MANAGER_ID_MAP.get(compoundId)){
                                teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';5';
                            }
                        }
                    }
                }
            }
            if(String.isNotBlank(account.Sales_Manager_Route_6__c)){
                compoundId = account.VIP_Instance__c + '*' + account.Sales_Manager_Route_6__c;
                    
                if (ROUTE_TO_MANAGER_ID_MAP.containsKey(compoundId) ) {
                    if(!salesManagerRouteSet.contains(account.Sales_Manager_Route_6__c)){
                        accountTeam.add(createNewTeamMember(account.Id, ROUTE_TO_MANAGER_ID_MAP.get(compoundId), 'Sales Manager', '6'));
                        salesManagerRouteSet.add(account.Sales_Manager_Route_6__c);
                    }else{
                        for(AccountTeamMember teamMember : accountTeam){
                            if(teamMember.UserId == ROUTE_TO_MANAGER_ID_MAP.get(compoundId)){
                                    teamMember.Sales_Pointer__c = teamMember.Sales_Pointer__c + ';6';
                                }
                        }
                    }
                }
            }
            AccountTeamMembersToCreate.addAll(accountTeam);
        }

        if(runQueueableJobs){
            if(!Test.isRunningTest()){
                BatchDeleteAccountTeamsList batchDeleteAccountTeam = new BatchDeleteAccountTeamsList();
                batchDeleteAccountTeam.accountTeamMembersToDelete = AccountTeamMembersToDelete;
                batchDeleteAccountTeam.accountTeamMembersToInsert = AccountTeamMembersToCreate;
                batchDeleteAccountTeam.accountIds = new Set<Id>((List<Id>)accountIds);
                Database.executeBatch(batchDeleteAccountTeam, 2000);
            }
        } else {
            AccountTeamMemberDAO.deleteAccountTeamMembers(AccountTeamMembersToDelete);
            AccountTeamMemberDAO.insertAccountTeamMembers(AccountTeamMembersToCreate);
            objectiveAccsToUpdate = RouteAssignmentHandler.reassignObjectiveAccountOwners(new Set<Id>((List<Id>)accountIds));

            if(!objectiveAccsToUpdate.isEmpty()){
                ObjectiveAccountDAO.updateObjectiveAccounts(objectiveAccsToUpdate);
            }
        }
    }

    private static AccountTeamMember createNewTeamMember(Id accountId, Id userId, String teamRole, String salesPointer){
        AccountTeamMember newTeamMember = new AccountTeamMember();
        newTeamMember.AccountAccessLevel = 'Read';
        newTeamMember.CaseAccessLevel = 'Edit';
        newTeamMember.OpportunityAccessLevel = 'Edit';
        newTeamMember.AccountId = accountId;
        newTeamMember.UserId = userId;
        newTeamMember.TeamMemberRole = teamRole;
        newTeamMember.Sales_Pointer__c = salesPointer;
        return newTeamMember;
    }

    /* * * * *
    *  Description: Method reassign a correct Sales users owning the route based on route assigned to them.
    *  Takes the list of new users or changed users and a map of old users (if they exist) from trigger
    *  as input and updates accounts based on that info.
    *  Handles number of situations:
    *  1. Assigns user account corresponding to his new route
    *  2. Assigns users old accounts to other user with corresponding route if that user exists
    * * * * */

    public static void assignAccountsToUsersWhenUserRouteChanges(List<User> changedUsers, Map<Id, User> oldUsers) {
        try{
            Boolean isNew = (oldUsers == null);
			Map<String, Id> routeToNewUserIdMap = new Map<String, Id>();
            Map<String, Id> routeToNewManagerIdMap = new Map<String, Id>();
            Set<String> orphanedRoutesUser = new Set<String>();
            Set<String> orphanedRoutesManager = new Set<String>();
            User oldUser;
            Map<String,List<String>> vipRouteMatchesMap = new  Map<String,List<String>>();

            //For every modified user
            for (User usr : changedUsers) {
                //if the assigned route has changed
                if (!isNew) oldUser = oldUsers.get(usr.Id);
                if (isNew || usr.Assigned_route__c != oldUser.Assigned_route__c || usr.VIP_Company__c !=oldUser.VIP_Company__c) {
                    //if new Route is not Blank put that new route in route-to-owner map
                    if (String.isNotBlank(usr.Assigned_route__c) && String.isNotBlank(usr.VIP_Company__c)) {
                        if (usr.IsManager__c) {
                        	routeToNewManagerIdMap.put(usr.VIP_Company__c+'*'+usr.Assigned_route__c, usr.Id);
                        } else {
                            routeToNewUserIdMap.put(usr.VIP_Company__c+'*'+usr.Assigned_route__c, usr.Id);
                        }
                        if (!vipRouteMatchesMap.containsKey(usr.VIP_Company__c)) {
                            List<String> routeList = new List<String>();
                            routeList.add(usr.Assigned_route__c);
                            vipRouteMatchesMap.put(usr.VIP_Company__c, routeList);
                        } else if (!vipRouteMatchesMap.get(usr.VIP_Company__c).contains(usr.Assigned_route__c)) {
                            vipRouteMatchesMap.get(usr.VIP_Company__c).add(usr.Assigned_route__c);
                        }
                    }
                    //If old Route is not blank, remember it as potential "orphan"
                    if (!isNew && String.isNotBlank(oldUser.Assigned_route__c) && String.isNotBlank(oldUser.VIP_Company__c)) {
                        if (oldUser.IsManager__c) {
                        	orphanedRoutesManager.add(oldUser.VIP_Company__c+'*'+oldUser.Assigned_route__c);                        
                        } else {
                            orphanedRoutesUser.add(oldUser.VIP_Company__c+'*'+oldUser.Assigned_route__c);                        
                        }
                        if (!vipRouteMatchesMap.containsKey(oldUser.VIP_Company__c)) {
                            List<String> routeList = new List<String>();
                            routeList.add(oldUser.Assigned_route__c);
                            vipRouteMatchesMap.put(oldUser.VIP_Company__c,routeList);
                        } else if (!vipRouteMatchesMap.get(oldUser.VIP_Company__c).contains(oldUser.Assigned_route__c)) {
                            vipRouteMatchesMap.get(oldUser.VIP_Company__c).add(oldUser.Assigned_route__c);
                        }
                    }
                }
            }
            //Go through the list of all the orphans
            ////Users
            for(String orphan : orphanedRoutesUser){
                //and check if there is a new user that going to own it
                if (!routeToNewUserIdMap.containsKey(orphan)) {
                    //if there is no new user, check the map if existing users has it
                    if (ROUTE_TO_USER_ID_MAP.containsKey(orphan)) {
                        routeToNewUserIdMap.put(orphan,ROUTE_TO_USER_ID_MAP.get(orphan));
                    } else if (DEFAULT_UNASSIGNED_USER_ID != null) {
                        //or assign the default one if no user assigned
                        routeToNewUserIdMap.put(orphan,DEFAULT_UNASSIGNED_USER_ID);
                    }
                }
            }
            //Managers
            for(String orphan : orphanedRoutesManager){
                //and check if there is a new user that going to own it
                if (!routeToNewManagerIdMap.containsKey(orphan)) {
                    //if there is no new user, check the map if existing users has it
                    if (ROUTE_TO_MANAGER_ID_MAP.containsKey(orphan)) {
                        routeToNewManagerIdMap.put(orphan,ROUTE_TO_MANAGER_ID_MAP.get(orphan));
                    } else if (DEFAULT_UNASSIGNED_USER_ID != null) {
                        //or assign the default one if no user assigned
                        routeToNewManagerIdMap.put(orphan,DEFAULT_UNASSIGNED_USER_ID);
                    }
                }
            }


            //SELECT all the accounts which are subject to new route changes by route
            List<Account> accUpdate = [
                    SELECT Id, Account_Manager_Route__c,Account_Manager_Route_CompoundID__c, Sales_Manager_Route_CompoundID__c, Sales_Manager_Route__c, VIP_Company__c,
                    AccountSource
                    FROM Account
                    WHERE Account_Manager_Route_CompoundID__c IN :routeToNewUserIdMap.keySet()
                    OR Sales_Manager_Route_CompoundID__c IN :routeToNewManagerIdMap.keySet() FOR UPDATE
            ];

            //for each of those accounts
            for (Account acc : accUpdate) {
                //BSSP-2199 Added to mark Accounts for scheduled job: 'ScheduleBatchBuildAccountTeams'
                acc.ProcessAccountTeamsBuild__c = true;
                //Modify owner if Account_Manager_Route__c corresponds to a map value
                if (String.isNotBlank(acc.Account_Manager_Route_CompoundID__c) && routeToNewUserIdMap.containsKey(acc.Account_Manager_Route_CompoundID__c)) {
                    acc.OwnerId = routeToNewUserIdMap.get(acc.Account_Manager_Route_CompoundID__c);
                }
                //Modify Sales_Manager_id__c if Account_Manager_Route__c corresponds to a map value
                if (String.isNotBlank(acc.Sales_Manager_Route_CompoundID__c) && routeToNewManagerIdMap.containsKey(acc.Sales_Manager_Route_CompoundID__c)) {
                    acc.Sales_Manager_Id__c = routeToNewManagerIdMap.get(acc.Sales_Manager_Route_CompoundID__c);
                }
                //Flip standard field value so AccountChangeEventTriggerHandler does not rerun accounteam insert logic
                //Only standard fields are found in the changed fields attribute for the change event
                if(acc.AccountSource == 'Customer Event'){
                    acc.AccountSource = 'Advertisement';
                } else {
                    acc.AccountSource = 'Customer Event';
                }
            }

            AccountDAO.updateAccounts(accUpdate);

            //Find accounts that need Account Teams rebuilt
            List<String> accountIdsNeedAccTeamChange = new List<String>();
            for(String vipCompany : vipRouteMatchesMap.keySet()){
                List<String> routeList = vipRouteMatchesMap.get(vipCompany);
                List<Account> accounts = [SELECT Id FROM Account WHERE VIP_Instance__c = :vipCompany AND (Account_Manager_Route__c IN :routeList OR Account_Manager_Route_2__c IN :routeList OR
                                                                                                    Account_Manager_Route_3__c IN :routeList OR Account_Manager_Route_4__c IN :routeList OR
                                                                                                    Account_Manager_Route_5__c IN :routeList OR Account_Manager_Route_6__c IN :routeList OR 
                                                                                                    Sales_Manager_Route__c IN :routeList OR  Sales_Manager_Route_2__c IN :routeList OR
                                                                                                    Sales_Manager_Route_3__c IN :routeList OR  Sales_Manager_Route_4__c IN :routeList OR
                                                                                                    Sales_Manager_Route_5__c IN :routeList OR  Sales_Manager_Route_6__c IN :routeList)];
                for(Account account : accounts){
                    accountIdsNeedAccTeamChange.add(account.Id);
                    //BSSP-2199 Added to mark Accounts for scheduled job: 'ScheduleBatchBuildAccountTeams'
                    account.ProcessAccountTeamsBuild__c = true;
                }
            }
            //Moved to Scheduled Job 'ScheduleBatchBuildAccountTeams'
            //assignUserToAccountTeamWhenAccountRouteChanges(accountIdsNeedAccTeamChange, true);
        } catch(Exception ex){
            ErrorLog.insertErrorLog(ex.getMessage(), String.valueOf(ex.getLineNumber()), 'RouteAssignmentHandler', 'assignAccountsToUsersWhenUserRouteChanges()');
        }
    }

    /* * * * *
    *  Description: Method reassigns Objective Account Owners after changes are made to 
    *  to an Account Team. If the Account is in CBS it checks if there is a new match for 
    *  the Objective Account Owner on the Account Team. If the account is non CBS it checks
    *  if the Account Owner matches the Objective Account Owner.
    * * * * */

    public static List<Objective_Account__c> reassignObjectiveAccountOwners(Set<Id> AccountIdSet) {
        List<Objective_Account__c> objAccountList = ObjectiveAccountDAO.getObjectiveAccountsByAccountId(AccountIdSet);
        List<AccountTeamMember> accountTeamMemberList = AccountTeamMemberDAO.getAccountTeamMembersByAccountIdsAndRole(AccountIdSet, new List<String>{'Sales Rep','FSR','Wine/Liquor Rep'});
        Map<Id, List<AccountTeamMember>> accTeamMap = new Map<Id, List<AccountTeamMember>>();
        List<AccountTeamMember> accTeamList;

        for (AccountTeamMember teamMember : accountTeamMemberList) {
            if (!accTeamMap.containsKey(teamMember.AccountId)) {
                accTeamList = new List<AccountTeamMember>();
                accTeamList.add(teamMember);
                accTeamMap.put(teamMember.AccountId, accTeamList);
            } else {
                accTeamList = accTeamMap.get(teamMember.AccountId);
                accTeamList.add(teamMember);
            }
        }

        List<Objective_Account__c> objAccsToUpdate = new List<Objective_Account__c>();
        for (Objective_Account__c objAcc : objAccountList){   
            if (objAcc.Account__r.VIP_Instance__c == 'CBS') {
                Boolean match = false;
                accTeamList = accTeamMap.get(objAcc.Account__c);
                if (accTeamList != null && objAcc.Objective__r.CBS_WCD_Pointers__c != null) {
                    Set<String> objPointers = new Set<String>(objAcc.Objective__r.CBS_WCD_Pointers__c.split(';'));
                    for (AccountTeamMember teamMember : accTeamList) {
                        Set<String> userPointers = new Set<String>(teamMember.Sales_Pointer__c.split(';'));
                        if (userPointers.containsAll(objPointers)) {
                            match = true;
                            if(objAcc.OwnerId != teamMember.UserId){
                                objAcc.OwnerId = teamMember.UserId; 
                            }
                            break;
                        }
                    }
                    if (match == false) {
                        objAcc.OwnerId = DEFAULT_UNASSIGNED_USER_ID;
                    } 
                } else {
                    objAcc.OwnerId = objAcc.Account__r.OwnerId;
                }
                objAccsToUpdate.add(objAcc);
            } else {
                if (objAcc.OwnerId != objAcc.Account__r.OwnerId) {
                    objAcc.OwnerId = objAcc.Account__r.OwnerId;
                    objAccsToUpdate.add(objAcc);
                }
            }
        }
        return objAccsToUpdate;
    }
}