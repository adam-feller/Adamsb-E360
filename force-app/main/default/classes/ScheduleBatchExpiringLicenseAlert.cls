public class ScheduleBatchExpiringLicenseAlert implements Schedulable{

    public void execute(SchedulableContext sc) {
        BatchExpiringLicenseAlert batchExpiringLicenseAlert = new BatchExpiringLicenseAlert();
        Date todayPlus35 = System.today().addDays(35);
        batchExpiringLicenseAlert.todayPlus35 = todayPlus35;
        batchExpiringLicenseAlert.query = 'SELECT Id, LicenseExpirationDate__c ' + 
                                            ' FROM Account' + 
                                            ' WHERE LicenseExpirationDate__c = :todayPlus35';

        Database.executebatch(batchExpiringLicenseAlert);
    }
}