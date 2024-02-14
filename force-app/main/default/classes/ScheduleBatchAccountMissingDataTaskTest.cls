@isTest
public class ScheduleBatchAccountMissingDataTaskTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2099';

    @isTest
    static void testScheduleBatchAccountMissingDataTask(){
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP, new ScheduleBatchAccountMissingDataTask());
            CronTrigger ct = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger 
                WHERE id = :jobId
                ];
            System.assertEquals(CRON_EXP, ct.CronExpression, 'incorrect CRON Expression returned');
            System.assertEquals(0, ct.TimesTriggered, 'incorrect number trigger');
            System.assertEquals('2099-03-15 00:00:00', String.valueOf(ct.NextFireTime), 'incorrect next fire date');
        Test.stopTest();
    }
}