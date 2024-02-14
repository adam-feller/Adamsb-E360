@isTest
private class ScheduleBatchProductsCreatePBETest {

    @isTest
    static void testScheduleBatchProductsCreatePBE(){
        Test.startTest();
        	String CRON_EXP = '0 0 23 * * ?';
            String jobId = System.schedule('ScheduleBatchPBETest123', CRON_EXP, new ScheduleBatchProductsCreatePBE());
        Test.stopTest();
    }
}