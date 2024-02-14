@IsTest
public class GreenmileAPIHelperTest {
    static testMethod void ObjectiveDisplayPdfControllerTestMethod(){
        GreenmileAPIHelper.AndCondition ac = new GreenmileAPIHelper.AndCondition();
        ac.add(New GreenmileAPIHelper.AttrCondition('driverAssignments.driver.login','userLogin'));
        ac.add(New GreenmileAPIHelper.AttrCondition('date','todayDate'));
        GreenmileAPIHelper.OrCondition oc = New GreenmileAPIHelper.OrCondition();
        oc.add(New GreenmileAPIHelper.AttrCondition('organization.key','GBX04SLS'));
        oc.add(New GreenmileAPIHelper.AttrCondition('organization.key','GBX06SLS'));
        ac.add(oc);
        oc.toJSON();
    }
}