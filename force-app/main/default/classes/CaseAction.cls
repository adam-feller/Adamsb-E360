public class CaseAction {

    @InvocableMethod(label='getCaseQueueListFromApex' description='get all case queue records' category='getcaseQueueRecsFromApex')
    public static List<List<Id>> getCaseQueueListfromApex(){
        List<Id> caseQueueIdList = new List<Id>();
        List<List<Id>> caseQueueListIds = new List< List<Id>>(); 
        List<Group> caseQueueGrpList = new List<Group>();
        List<Group> queueList = [select id, name from group where type='Queue'];
        List<QueueSobject> caseQueueList =[SELECT QueueId, Queue.Name, SobjectType FROM QueueSobject WHERE SobjectType = 'case' ];
        //create a Map sobjectQueueIdMap
        Map<String,String> sobjectQueueIdMap = new Map<String,String>();
        for(QueueSobject qSobject : caseQueueList){
            sobjectQueueIdMap.put( qsobject.queueid,qSobject.id);
        }
        for(Group grp: queueList){
            String grpId = grp.id;
            if(sobjectQueueIdMap.get(grpId) != null) {
                //caseQueueIdList = new List<Id>();
                caseQueueIdList.add(grp.Id);
                 //caseQueueListIds.add(caseQueueIdList);
                //caseQueueGrpList.add(grp);
            }
        }
        caseQueueListIds.add(caseQueueIdList);
        
        return caseQueueListIds;
    }
}