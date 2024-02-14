global with sharing class DeliveryDateMassClosure {

    @InvocableMethod
    public static void massClose(List<MassClosureInputs> inputs){
        Boolean selectCities = inputs[0].selectCities;
        List<Date> originalDates = inputs[0].deliveryDates;
        String warehouses = inputs[0].warehouses;
        String frequencies = inputs[0].frequencies;
        String sellTypes = inputs[0].sellTypes;
        String premises = inputs[0].premises;
        List<String> citiesList = inputs[0].cities;
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        String query;

        if(selectCities == true){
            query = 'SELECT Id, Account__r.Warehouse__c, Delivery_Date__c, Status__c' +
                                ' FROM Delivery_Date__c' +
                                ' WHERE Delivery_Date__c IN :originalDates' +
                                ' AND Account__r.Warehouse__c IN :warehouseList' +
                                ' AND Status__c =  \'Active\'' +
                                ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                				' AND Account__r.Sell_Type__c IN :sellTypeList' +
                				' AND Account__r.Premise__c IN :premiseList' +
                                'AND Account__r.BillingCity IN :citiesList';
        }else{
            query = 'SELECT Id, Account__r.Warehouse__c, Delivery_Date__c, Status__c' +
                            ' FROM Delivery_Date__c' +
                            ' WHERE Delivery_Date__c IN :originalDates' +
                            ' AND Account__r.Warehouse__c IN :warehouseList' +
                            ' AND Account__r.Delivery_Frequency_Type__c IN :frequencyList' +
                			' AND Account__r.Sell_Type__c IN :sellTypeList' +
                			' AND Account__r.Premise__c IN :premiseList' +
                            ' AND Status__c =  \'Active\'';

        }

        BatchHolidayPlanningMassDeliveryClosure batchHPMC = new BatchHolidayPlanningMassDeliveryClosure();
        batchHPMC.originalDates = originalDates;
        batchHPMC.warehouses = warehouses;
        batchHPMC.frequencies = frequencies;
        batchHPMC.citiesList = citiesList;
        batchHPMC.sellTypes = sellTypes;
        batchHPMC.premises = premises;
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
        global List<Date> deliveryDates;
        
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