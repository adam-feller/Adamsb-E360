public with sharing class CallRedistributionController {

    @AuraEnabled
    public static List<List<String>> getUniqueCityList(String warehouseString, String frequencyString, Date selectedDate, Id planId, String callOrDelivery) {
        System.debug('warehouseString' + warehouseString);
        System.debug('frequencyString' + frequencyString);
        System.debug('selectedDate' + selectedDate);
        System.debug('planId' + planId);
        System.debug('callOrDelivery' + callOrDelivery);

        List<String> warehouseList = new List<String>();
        
        if(!String.isBlank(warehouseString)){
            warehouseList = warehouseString.split('; ');
        }

        List<String> frequencyList =  new List<String>();
        if(!String.isBlank(frequencyString)){
            frequencyList = frequencyString.split('; ');
        } 

        List<AggregateResult> deliveryDateAggr = new List<AggregateResult>();
        
        if(callOrDelivery == 'delivery' && planID != null){
            deliveryDateAggr = [SELECT Count(id), Account__r.BillingCity 
                                FROM Delivery_Date__c 
                                WHERE Account__r.Warehouse__c IN :warehouseList 
                                AND Account__r.Delivery_Frequency_Type__c IN :frequencyList 
                                AND Delivery_Date__c = :selectedDate 
                                AND Plan__c = :planId
                                GROUP BY Account__r.BillingCity ] ;
        }else if(callOrDelivery == 'delivery' && planID == null){
            deliveryDateAggr = [SELECT Count(id), Account__r.BillingCity 
                                FROM Delivery_Date__c 
                                WHERE Account__r.Warehouse__c IN :warehouseList 
                                AND Account__r.Delivery_Frequency_Type__c IN :frequencyList 
                                AND Delivery_Date__c = :selectedDate 
                                GROUP BY Account__r.BillingCity ] ;
        }else{
                System.debug('Here');
                deliveryDateAggr = [SELECT Count(id), Account__r.BillingCity 
                                    FROM Task 
                                    WHERE Account__r.Warehouse__c IN :warehouseList 
                                    AND Account__r.Delivery_Frequency_Type__c IN :frequencyList 
                                    AND ActivityDate = :selectedDate 
                                    GROUP BY Account__r.BillingCity ] ;
        }


        System.debug('deliveryDateAggr' + deliveryDateAggr);
        List<String> cityLabelList = new List<String>();
        List<String> cityValueList = new List<String>();


        for(AggregateResult dda : deliveryDateAggr){
            cityLabelList.add((String)dda.get('BillingCity') +' (' + (Integer)dda.get('expr0') + ')');
            cityValueList.add((String)dda.get('BillingCity'));
        }

        List<List<String>> cityList = new List<List<String>>{cityLabelList, cityValueList};

        return cityList;

   }

}