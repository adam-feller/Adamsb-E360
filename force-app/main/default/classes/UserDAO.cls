public with sharing class UserDAO {

    public static List<User> getUser(Id userId){
        return  [SELECT Id, UserRole.Name, FederationIdentifier, Name, VIP_Company__c,
                Warehouse__c, Greenmile_Route_Override__c, Greenmile_Date_Override__c,
                Supervisor__c, Email, Greenmile_BU_Override__c, Profile.Name,
                Assigned_route__c,GM_Org_Key__c,Merch_Route__c
                FROM User
                WHERE Id = :userId];
    }

    public static List<User> getUserByName(String name){
        return  [SELECT Id, UserRole.Name, FederationIdentifier, Name, VIP_Company__c,
                Warehouse__c, Greenmile_Route_Override__c, Greenmile_Date_Override__c,
                Supervisor__c, Email, Greenmile_BU_Override__c,
                Assigned_route__c
                FROM User
                WHERE name = :name];
    }

    public static List<User> getUsersByRole(String managerId){
        return [SELECT Id, Name, Goal_Amount__c, VIP_Company__c
        FROM User
        WHERE ManagerId = :managerId
        AND IsActive = True];
    }

    public static List<User> getUsersByRole(String role, String managerId){
        return [SELECT Id, Name, Goal_Amount__c, VIP_Company__c
                FROM User
                WHERE UserRole.Name = :role
                AND ManagerId = :managerId];
    }

    public static Map<String, String> getUserRole(Set<String> FederationId) {
        List<User> userlist = [ SELECT FederationIdentifier, UserRole.Name
                                FROM User
                                WHERE FederationIdentifier IN :FederationId
        ];
        Map<String, String> userRole = new Map<String,String>();
        if(!userlist.isEmpty()) {
            for(User usr : userlist){
                userRole.put(usr.FederationIdentifier, usr.UserRole.Name);
            }
        }
        return userRole;
    }

    public static List<User> getUsers(){
        return [SELECT Id, Name, Goal_Amount__c, VIP_Company__c 
                FROM User];
    }

    public static List<User> getUsersByVIPCompany(String vipCompany){
        return [SELECT Id, Name, Goal_Amount__c, VIP_Company__c, Assigned_route__c 
                FROM User 
                WHERE VIP_Company__c = :vipCompany];
    }

    public static List<User> getUsersByVIPCompanyObjective(List<String> vipCompany){
        return [SELECT Id, Name, Goal_Amount__c, VIP_Company__c, Assigned_route__c, Manager_Name__c
                FROM User 
                WHERE VIP_Company__c IN :vipCompany
                AND IsActive = true
                AND UserRole.Name like '%Account Manager%'
                AND Assigned_route__c <> ''];
    }
}