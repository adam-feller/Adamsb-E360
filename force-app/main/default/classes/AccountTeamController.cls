public without sharing class AccountTeamController {
    @AuraEnabled
    public static List<TeamMemberData> getAccountTeamData(String recordId) { 
        
        List<TeamMemberData> accountTeamData = new List<TeamMemberData>();
        Account account = [SELECT Id, Name, Sell_Type__c, VIP_Instance__c FROM Account WHERE Id = :recordId];
        List<AccountTeamMember> accountTeamList = [SELECT Id, PhotoUrl, Sales_Pointer__c, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId = :account.Id];
        
        Set<Id> userIdSet = new Set<Id>();
        for(AccountTeamMember accTeamMember : accountTeamList) {
            userIdSet.add(accTeamMember.UserId);
        }
        
        Map<Id,User> accountTeamUserMap = new Map<Id,User>([SELECT Id, Assigned_Route__c, Merch_Route__c, Name, Phone FROM User WHERE Id IN :userIdSet]);
        
        //Looping through 2 times so that Merchandisers are loaded at the bottom
        for(AccountTeamMember accTeamMember : accountTeamList){
            if(accountTeamUserMap.containsKey(accTeamMember.UserId) && !accTeamMember.TeamMemberRole.contains('Merchandiser')) {
                User user = accountTeamUserMap.get(accTeamMember.UserId);
                TeamMemberData teamMemberData = new TeamMemberData();
                teamMemberData.userName = user.Name;
                teamMemberData.role = accTeamMember.TeamMemberRole;
                teamMemberData.pointer = accTeamMember.Sales_Pointer__c;
                teamMemberData.route = user.Assigned_Route__c;
                teamMemberData.phone = user.Phone;
                accountTeamData.add(teamMemberData);
            }
        }
        for(AccountTeamMember accTeamMember : accountTeamList){
            if(accountTeamUserMap.containsKey(accTeamMember.UserId) && accTeamMember.TeamMemberRole.contains('Merchandiser')) {
                User user = accountTeamUserMap.get(accTeamMember.UserId);
                TeamMemberData teamMemberData = new TeamMemberData();
                teamMemberData.userName = user.Name;
                teamMemberData.role = accTeamMember.TeamMemberRole;
                teamMemberData.pointer = accTeamMember.Sales_Pointer__c;
               	teamMemberData.route = user.Merch_Route__c;
                teamMemberData.phone = user.Phone;
                accountTeamData.add(teamMemberData);
            }
        }
        return accountTeamData;
    }

    public class TeamMemberData{
        @AuraEnabled public String userName;
        @AuraEnabled public String role;
        @AuraEnabled public String pointer;
        @AuraEnabled public String route;
        @AuraEnabled public String phone;
    }
}