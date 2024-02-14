public class ScheduleBatchConvertNewCustomerRequests implements Schedulable {

    public void execute(SchedulableContext sc) {
        BatchConvertNewCustomerRequests batchConvertNCRs = new BatchConvertNewCustomerRequests();
        batchConvertNCRs.query = 'SELECT Id,Company,State, VIP_Account_Number__c, NCRGUID__c, FirstName, LastName, Requested_For__r.Email,' + 
            					 ' Requested_For__r.FederationIdentifier, Owner.Email, DMO_Comment__c' +
                                 ' FROM Lead' +
                                 ' WHERE NCRGUID__c != null AND isConverted=false AND (Status = \'Submitted to DMO\' OR Status = \'Confirmed by DMO\' OR status = \'Created in VIP\')';

        Database.executebatch(batchConvertNCRs, 5);   //Small batch size to avoid limits
    }
}