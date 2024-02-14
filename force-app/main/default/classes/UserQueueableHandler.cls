public without sharing class UserQueueableHandler implements Queueable {
    List<User> newUsers = new List<User>();
    Map<Id,User> oldUserMap = new Map<Id,User>();
    Boolean isMerch = false;

    public UserQueueableHandler(List<User> newUsers, Map<Id, User> oldUserMap, Boolean isMerch){
        this.newUsers = newUsers;
        this.oldUserMap = oldUserMap;
        this.isMerch = isMerch;
    }

    public void execute(QueueableContext context) {
        if (isMerch) {
        	MerchRouteAssignmentHandler.assignAccountsToMerchandisersWhenUserRouteChanges(newUsers, oldUserMap);
        } else {
            RouteAssignmentHandler.assignAccountsToUsersWhenUserRouteChanges(newUsers, oldUserMap);
        }
    }
}