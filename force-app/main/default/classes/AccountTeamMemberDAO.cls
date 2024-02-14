public without sharing class AccountTeamMemberDAO {
    public static List<AccountTeamMember> getAccountTeamMembersByAccountIds(Set<Id> accountIds){
        return [SELECT Id, AccountAccessLevel, CaseAccessLevel, AccountId, OpportunityAccessLevel, Sales_Pointer__c, TeamMemberRole, UserId, User.Name, User.Assigned_route__c
                FROM AccountTeamMember 
                WHERE TeamMemberRole != 'Merchandiser' AND TeamMemberRole != 'Merchandiser Manager'
                AND AccountId IN :accountIds];
    }

    public static List<AccountTeamMember> getAccountTeamMembersByAccountIdsAndRole(Set<Id> accountIds, List<String> roles){
        return [SELECT Id, AccountAccessLevel, CaseAccessLevel, AccountId, OpportunityAccessLevel, Sales_Pointer__c, TeamMemberRole, UserId, User.Name, User.Assigned_route__c
                FROM AccountTeamMember 
                WHERE AccountId IN :accountIds
                AND TeamMemberRole IN :roles];
    }

    public static List<AccountTeamMember> getAccountTeamMembersByAccountIdsAndUserIds(Set<Id> accountIds, Set<Id> userIds){
        return [SELECT Id, AccountAccessLevel, CaseAccessLevel, AccountId, OpportunityAccessLevel, Sales_Pointer__c, TeamMemberRole, UserId, User.Name, User.Assigned_route__c  
                FROM AccountTeamMember 
                WHERE AccountId IN :accountIds
                AND UserId IN :userIds];
    }
    
    public static List<AccountTeamMember> getAccountTeamMembersByUserIds(Set<Id> userIds){
        return [SELECT Id, AccountAccessLevel, CaseAccessLevel, AccountId, OpportunityAccessLevel, Sales_Pointer__c, TeamMemberRole, UserId, User.Name, User.Assigned_route__c  
                FROM AccountTeamMember 
                WHERE UserId IN :userIds];
    }

    public static List<AccountTeamMember> insertAccountTeamMembers(List<AccountTeamMember> accountTeamMembersToInsert){
        insert accountTeamMembersToInsert;
        return accountTeamMembersToInsert;
    }
    
    public static List<AccountTeamMember> updateAccountTeamMembers(List<AccountTeamMember> accountTeamMembersToUpdate){
        update accountTeamMembersToUpdate;
        return accountTeamMembersToUpdate;
    }
    
    public static List<AccountTeamMember> deleteAccountTeamMembers(List<AccountTeamMember> accountTeamMembersToDelete){
        delete accountTeamMembersToDelete;
        return accountTeamMembersToDelete;
    }
}