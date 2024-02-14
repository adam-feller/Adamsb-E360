public without sharing class ObjectiveCompletionApprovalCall {

    @InvocableMethod(label='Call Objective Approval Process')
    public static void callObjectiveApprovalProcess(List<FlowInput> input){
        
        if(input[0].recordIdToApprove != null && input[0].submitterId != null){
            //Get Submitter and Account related to record needing approval
            User submitter = [SELECT Id, ManagerId FROM User WHERE Id = :input[0].submitterId];
            Account account;
            Objective_Account__c objectiveAccount;
            Objective_Submission__c objectiveSubmission;
            objectiveSubmission = [SELECT Id, Objective_Account__c, Type__c FROM Objective_Submission__c WHERE Id = :input[0].recordIdToApprove];
            objectiveAccount = [SELECT Id, Account__c, CreatedById, Objective_Type__c FROM Objective_Account__c WHERE Id = :objectiveSubmission.Objective_Account__c];
            account = [SELECT Id, Sell_Type__c, Sales_Manager_Id__c, VIP_Instance__c FROM Account WHERE Id = :objectiveAccount.Account__c];
            
            //*************************************************
            //Determine who to set as next approver
            //*************************************************
            //If FSR submitted set approver to user's manager
            if (account.Sell_Type__c == 'INSIDE SALES' || account.Sell_Type__c == 'NATIONAL ACCTS') {
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitted for approval.');
                approvalRequest.setObjectId(objectiveSubmission.Id);
                approvalRequest.setSubmitterId(submitter.Id);
                if(submitter.ManagerId != null){
                    approvalRequest.setNextApproverIds(new Id[] {submitter.ManagerId});
                }else{
                    approvalRequest.setNextApproverIds(new Id[] {objectiveAccount.CreatedById});
                }
				if (objectiveSubmission.Type__c == 'Display') {
                   	approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Display');
            	} else if (objectiveSubmission.Type__c == 'Price Feature') {
                	approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Price_Feature');
            	} else if (objectiveSubmission.Type__c == 'Reset') {
                    approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Reset');
                }
                Approval.ProcessResult result = Approval.process(approvalRequest);
            //If CBS account find approver based on AccountTeam info
            } else if (account.VIP_Instance__c == 'CBS') {
                    Id approverId;
                    List<String> salesPointers = new List<String>();
                    List<AccountTeamMember> accountTeam = [SELECT Id, Sales_Pointer__c, TeamMemberRole, UserId FROM AccountTeamMember WHERE AccountId = :account.Id];
                    for(AccountTeamMember teamMember : accountTeam){
                        if(teamMember.UserId == submitter.Id){
                            salesPointers = teamMember.Sales_Pointer__c.split(';');
                            break;
                        }
                    }
                	if (salesPointers.size() > 0) {
                		for(AccountTeamMember teamMember : accountTeam){
	                        if(teamMember.TeamMemberRole.contains('Manager') && teamMember.Sales_Pointer__c.contains(salesPointers[0])){
	                            approverId = teamMember.UserId;
	                        }
	                    }
                    }
                    if(approverId == null){
                        approverId = objectiveAccount.CreatedById;
                    }
                    
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitted for approval.');
                    approvalRequest.setObjectId(objectiveSubmission.Id);
                    approvalRequest.setSubmitterId(submitter.Id);
                    approvalRequest.setNextApproverIds(new Id[] {approverId});
                    if (objectiveSubmission.Type__c == 'Display') {
                    	approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Display');
            		} else if (objectiveSubmission.Type__c == 'Price Feature') {
                		approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Price_Feature');
            		} else if (objectiveSubmission.Type__c == 'Reset') {
                        approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Reset');
                    }
                    Approval.ProcessResult result = Approval.process(approvalRequest);                    
            //All other scenarios approver is Sales Manager field on Account
            } else {
                Reyes_Org_Setting__c orgSetting = Reyes_Org_Setting__c.getOrgDefaults();
                Set<Id> defaultUserIds = new Set<Id>();
                if (orgSetting?.Unassigned_Route_Owner_id__c != null) defaultUserIds.add(Id.valueOf(orgSetting.Unassigned_Route_Owner_id__c));
                
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitted for approval.');
                approvalRequest.setObjectId(objectiveSubmission.Id);
                approvalRequest.setSubmitterId(submitter.Id);
                if(!defaultUserIds.contains(account.Sales_Manager_Id__c) && account.Sales_Manager_Id__c != null){
                    approvalRequest.setNextApproverIds(new Id[] {account.Sales_Manager_Id__c});
                }else if(submitter.ManagerId != null){
                    approvalRequest.setNextApproverIds(new Id[] {submitter.ManagerId});
                }else{
                    approvalRequest.setNextApproverIds(new Id[] {objectiveAccount.CreatedById});
                }
				if (objectiveSubmission.Type__c == 'Display') {
                   	approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Display');
            	} else if (objectiveSubmission.Type__c == 'Price Feature') {
                	approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Price_Feature');
            	} else if (objectiveSubmission.Type__c == 'Reset') {
                    approvalRequest.setProcessDefinitionNameOrId('Objective_Submission_Reset');
                }
                Approval.ProcessResult result = Approval.process(approvalRequest);
            }
        	//Call an update here so that the Number of Photos and Qualifier Notes is populated
            update objectiveSubmission;
        }
    }

    public class FlowInput{
        @InvocableVariable(required=true)
        public Id recordIdToApprove;

        @InvocableVariable(required=true)
        public Id submitterId;
    }

}