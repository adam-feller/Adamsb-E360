@isTest
public class CaseActionTest {

   
     @isTest
    static void TestCaseAction(){
        List<List<id> > actionlist = caseAction.getCaseQueueListfromApex();
        Assert.isTrue(actionlist.size() > 0);
    }
}