/**
 * Created by alexander.velitsky on 8/7/20.
 * Updated on 2/22/2022 by Christy Braaten to add Merchandiser Route updates (BSSP-1274)
 * Updated on 6/5/2022 by Christy Braaten to add updating of IsManager flag when Manager changes on a User Record (BSSP-1818)
 */
public without sharing class UserTriggerHandler {

	public static void beforeInsertHandler(List<User> newUsers) {
        Set<Id> mgrIds = new Set<Id>();
        for (User user: newUsers) {
            if (user.ManagerId <> null) {
            	mgrIds.add(user.ManagerId);
            }
        }
        if (mgrIds.size() > 0) {
        	Map<Id, User> mgrMap = new Map<Id, User>([SELECT Id, IsManager__c FROM User WHERE Id IN :mgrIds]);
        	Map<Id, User> updateManagers = new Map<Id, User>();
            for (User user: newUsers) {            
	            if (user.ManagerId != null) {
	                try {
	                	//Check to see if we need to update the Manager Flag on the new Manager
	                	User mgr = mgrMap.get(user.ManagerId);
	                	if (mgr <> null && mgr.IsManager__c == false) {
		                    mgr.IsManager__c = true;
	                        updateManagers.put(mgr.Id, mgr);
			            }
	                } catch (Exception e) {
	                    System.debug('Error updating Manager flag');
	                }
	            }
	        }
    	    if (updateManagers.size() > 0) {
	            update updateManagers.values();
        	}
        }
    }
    
    public static void beforeUpdateHandler(List<User> users, Map<Id, User> oldUserMap) {
        User oldUser;
		Set<Id> mgrIds = new Set<Id>();
        for (User user: users) {
            oldUser = oldUserMap.get(user.Id);
            if (user.ManagerId != oldUser.ManagerId) {
                //Add both the old and new manager to the Map
            	mgrIds.add(user.ManagerId);
                mgrIds.add(oldUser.ManagerId);
            }
        }
        if (mgrIds.size() > 0) {
	        Map<Id, User> mgrMap = new Map<Id, User>([SELECT Id, IsManager__c FROM User WHERE Id IN :mgrIds]);
	        List<User> allUsers = [SELECT Id, ManagerId FROM User WHERE IsActive = True];
	        Map<Id,User> updateManagers = new Map<Id,User>();
			for (User user: users) {
				oldUser = oldUserMap.get(user.Id);
	        	Boolean mgrHasOtherReports = false;
	        	for (User u : allUsers) {
	                if (oldUser.ManagerId == u.ManagerId && user.Id <> u.Id) {
		           		mgrHasOtherReports = true;
	                }
		        }
	            if (user.ManagerId != oldUser.ManagerId) {
	                //Check to see if we need to update the Manager Flag, on the old/new Manager
	                try {
	                	//Check to see if we need to update the Manager Flag on the new Manager
	                	User mgr = mgrMap.get(user.ManagerId);
	                	if (mgr <> null && mgr.IsManager__c == false) {
		                    mgr.IsManager__c = true;
	                        updateManagers.put(mgr.Id, mgr);
		                }
	                	//Check to see if we need to update the Manager Flag on the old Manager
	                    if (oldUser.ManagerId <> null) {
	                		mgr = mgrMap.get(oldUser.ManagerId);                    	
	                		if (mgr <> null && mgr.IsManager__c == true && !mgrHasOtherReports) {
			                    mgr.IsManager__c = false;
		                        updateManagers.put(mgr.Id, mgr);
			                }                    
	                    }
	                } catch (Exception e) {
	                    System.debug('Error updating Manager flag');
	                }                
	            }
	        }
    	    if (updateManagers.size() > 0) {
	            update updateManagers.values();
	        }
        }
    }
    
    public static void afterInsertHandler(List<User> newUsers) {
        List<User> salesUsers = new List<User>();
        List<User> merchUsers = new List<User>();
        for (User u : newUsers) {
            if (u.Assigned_route__c <> null) {
                salesUsers.add(u);
            }
            if (u.Merch_Route__c <> null) {
                merchUsers.add(u);
            }
        }
        if (salesUsers.size() > 0) {
        	System.enqueueJob(new UserQueueableHandler(salesUsers, null, false));
        }
        if (merchUsers.size() > 0) {
        	System.enqueueJob(new UserQueueableHandler(merchUsers, null, true));
        }
    }

    public static void afterUpdateHandler(List<User> newUsers, Map<Id, User> oldUserMap) {
        List<User> newUserRoutes = new List<User>();
        List<User> newMerchUserRoutes = new List<User>();
        Map<Id,User> oldUserRoutesMap = new Map<Id,User>();
        Map<Id,User> oldMerchUserRoutesMap = new Map<Id,User>();
        User oldUser;
        for(User user: newUsers){
            oldUser = oldUserMap.get(user.Id);
            if (user.Assigned_route__c != oldUser.Assigned_route__c || user.VIP_Company__c !=oldUser.VIP_Company__c) {
                newUserRoutes.add(user);
                oldUserRoutesMap.put(oldUser.Id, oldUser);
            }
			if (user.Merch_Route__c != oldUser.Merch_Route__c || user.VIP_Company__c !=oldUser.VIP_Company__c || user.ManagerId !=oldUser.ManagerId) {
                newMerchUserRoutes.add(user);
                oldMerchUserRoutesMap.put(oldUser.Id, oldUser);
            }
        }
        if (!newUserRoutes.isEmpty() && !oldUserRoutesMap.isEmpty()){
            System.enqueueJob(new UserQueueableHandler(newUserRoutes, oldUserRoutesMap, false));
        }
        if (!newMerchUserRoutes.isEmpty() && !oldMerchUserRoutesMap.isEmpty()){
            System.enqueueJob(new UserQueueableHandler(newMerchUserRoutes, oldMerchUserRoutesMap, true));
        }
    }
    
}