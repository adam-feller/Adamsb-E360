@isTest
private class ScheduleBatchDeleteObjSubmissionsTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2099';

    @isTest
    static void testScheduleDeleteObjectiveSubmissionsSchedule(){
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',
                                           CRON_EXP, 
                                           new ScheduleBatchDeleteObjectiveSubmissions());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, 
                                ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2099-03-15 00:00:00', 
                                String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

}