public without sharing class FlowRecordRelationDAO {
    
    public static FlowRecordRelation getBESTInterviews(Id recordId) {
        FlowRecordRelation data = [ SELECT 
                    ParentId, Parent.InterviewLabel, Parent.PauseLabel, 
                    Parent.CurrentElement, Parent.CreatedDate, Parent.Owner.Name 
                FROM FlowRecordRelation 
                WHERE RelatedRecordId = :recordId
                ORDER BY Parent.CreatedDate DESC 
                LIMIT 1];
        return data;
    }

    public static List<FlowRecordRelation> getObjectiveCompletionInterviews(Set <Id> objAccIds) {
        List<FlowRecordRelation> data = [ SELECT 
                    ParentId, RelatedRecordId, Parent.InterviewLabel, Parent.PauseLabel, 
                    Parent.CurrentElement, Parent.CreatedDate, Parent.Owner.Name
                FROM FlowRecordRelation 
                WHERE RelatedRecordId IN :objAccIds];
        system.debug(data);
        return data;
    }
}