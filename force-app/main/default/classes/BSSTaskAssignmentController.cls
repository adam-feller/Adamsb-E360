public without sharing class BSSTaskAssignmentController {
    @AuraEnabled
    public static AcctTeamSelectionWrapper getAccountTeam(String accId){
        Id currentUserId = UserInfo.getUserId();
        AcctTeamSelectionWrapper data = new AcctTeamSelectionWrapper();
        Set<Id> acctIds = new Set<Id>();
        acctIds.add(accId);
        data.accountTeamMembers = AccountTeamMemberDAO.getAccountTeamMembersByAccountIds(acctIds);
        
        for(AccountTeamMember teamMember : data.accountTeamMembers){
            if(teamMember.UserId == currentUserId && !teamMember.TeamMemberRole.contains('Manager')) {
                data.selectedUser = teamMember.UserId;
            } else if (teamMember.UserId == currentUserId && teamMember.TeamMemberRole.contains('Manager')) {
                Set<String> managerPointers = new Set<String>(teamMember.Sales_Pointer__c.split(';'));
                for(AccountTeamMember teamMatch : data.accountTeamMembers){
                    Set<String> pointers = new Set<String>(teamMatch.Sales_Pointer__c.split(';'));
                    if(!teamMatch.TeamMemberRole.contains('Manager') && pointers.containsAll(managerPointers)){
                        data.selectedUser = teamMatch.UserId;
                    }
                }
            }
        }
        return data;
    }

    public class AcctTeamSelectionWrapper{
        @AuraEnabled public List<AccountTeamMember> accountTeamMembers;
        @AuraEnabled public String selectedUser;
    }
}