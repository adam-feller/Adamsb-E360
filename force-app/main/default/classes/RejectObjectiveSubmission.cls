public without sharing class RejectObjectiveSubmission {

    @InvocableMethod(label='Reject Objective Submission')
    public static void callObjectiveRejectProcess(List<FlowInput> input){       
        if(input[0].recordIdToReject != null){          
            Objective_Submission__c objectiveSubmission = [SELECT Id FROM Objective_Submission__c WHERE Id = :input[0].recordIdToReject];
                
            //Unlock the Record if it is locked - these should always be locked because they are in an "Approved" status
            if (Approval.isLocked(objectiveSubmission.Id)) {
                Approval.unlock(objectiveSubmission);
            }
            
            //Set the Status and Retracted Field
            objectiveSubmission.Status__c = 'Rejected';
            objectiveSubmission.Retracted__c = true;
            update objectiveSubmission;
        }
    }

    public class FlowInput{
        @InvocableVariable(required=true)
        public Id recordIdToReject;
    }

}