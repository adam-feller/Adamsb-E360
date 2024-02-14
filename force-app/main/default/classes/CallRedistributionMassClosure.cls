global with sharing class CallRedistributionMassClosure {

    @InvocableMethod
    public static void massClose(List<MassClosureInputs> inputs){
        Boolean selectCities = inputs[0].selectCities;
        Date originalDate = inputs[0].callDate;
        String warehouses = inputs[0].warehouses;
        String frequencies = inputs[0].frequencies;
        String sellTypes = inputs[0].sellTypes;
        String premises = inputs[0].premises;

        List<String> citiesList = inputs[0].cities;


        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        
        String query;

        if (selectCities == true) {
            query = 'SELECT Id, Account__r.Warehouse__c, ActivityDate, Status' +
                                ' FROM Task' +
                                ' WHERE ActivityDate = :originalDate' +
                                ' AND Account__r.Warehouse__c IN :warehouseList' +
                                ' AND Status =  \'Open\'' +
                                ' AND RecordTypeId = :callTaskRecordTypeId' +
                                ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                				' AND Account__r.Sell_Type__c IN :sellTypeList' +
                				' AND Account__r.Premise__c IN :premiseList' +
                         		' AND Account__r.BillingCity IN :citiesList';
        } else {
            query = 'SELECT Id, Account__r.Warehouse__c, ActivityDate, Status' +
                            ' FROM Task' +
                            ' WHERE ActivityDate = :originalDate' +
                            ' AND Account__r.Warehouse__c IN :warehouseList' +
                            ' AND RecordTypeId = :callTaskRecordTypeId' +
                            ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
              				' AND Account__r.Sell_Type__c IN :sellTypeList' +
                			' AND Account__r.Premise__c IN :premiseList' +
              				' AND Status =  \'Open\'';
        }

        BatchHolidayPlanningMassClosure batchHPMC = new BatchHolidayPlanningMassClosure();
        batchHPMC.originalDate = originalDate;
        batchHPMC.warehouses = warehouses;
        batchHPMC.frequencies = frequencies;
        batchHPMC.sellTypes = sellTypes;
        batchHPMC.premises = premises;
        batchHPMC.citiesList = citiesList;
        batchHPMC.userEmail = userEmail;
        batchHPMC.query = query;
        database.executeBatch(batchHPMC, 2000);
    }

    global class MassClosureInputs{
        @InvocableVariable
        global Boolean summaryOnly;

        @InvocableVariable
        global Boolean selectCities;

        @InvocableVariable
        global List<String> cities;
        
        @InvocableVariable
        global Date callDate;
        
        @InvocableVariable
        global String warehouses;

        @InvocableVariable 
        global String frequencies;
        
        @InvocableVariable
        global String sellTypes;
        
        @InvocableVariable
        global String premises;        
    }

}