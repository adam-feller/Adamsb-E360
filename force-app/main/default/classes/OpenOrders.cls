public with sharing class OpenOrders {
    
    @AuraEnabled(cacheable=true)
    public static Boolean getPermissionSet(){
        Boolean user_has_permission = false;
        List<PermissionSetAssignment> lstcurrentUserPerSet = [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId() ];
    	Id profileId = userInfo.getProfileId();
        String profileName = [SELECT Id, Name from Profile WHERE Id=:profileId].Name;
        for( PermissionSetAssignment psa : lstcurrentUserPerSet){
            if(psa.PermissionSet.Name.equals('Account_Manager') ||  profileName.equals('System Administrator')){
                user_has_permission = true;
            }
        }
        System.debug('Do i have permission?'+ user_has_permission);
        return user_has_permission;
    }
}