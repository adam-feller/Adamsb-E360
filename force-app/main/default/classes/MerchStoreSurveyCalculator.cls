public class MerchStoreSurveyCalculator {
    private static boolean RUN = true;
    
    @InvocableMethod(label='Get Total')
    public static List<String> createTotal(List<String> recId){
        
       List<Generic_Survey__c> getRecordType = [Select RecordTypeId From Generic_Survey__c Where Id = :recId[0] Limit 1];
        system.debug('getRecordType[0].RecordTypeId: '+ getRecordType[0].RecordTypeId);
        Id recordTypeIdWest = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('West Coast').getRecordTypeId();
        Id recordTypeIdEast = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('East Coast').getRecordTypeId();
        
      if(RUN){
        // Set to false to prevent infinite loop from trigger
        RUN = false;
        
        if(getRecordType[0].RecordTypeId == recordTypeIdWest){ 
           List<Generic_Survey__c> genSurWest = [Select Q1_drop_down_values_West_Coast__c, Q2_drop_down_values_West_Coast_c__c,
                                                     Q3_drop_down_values_West_Coast__c, Q4_drop_down_values_West_Coast_c__c,
                                                     Q5_drop_down_values_West_Coast_c__c, Q6_drop_down_values_West_Coast_c__c,
                                                     Q7_drop_down_values_West_Coast_c__c,Q8_drop_down_values_West_Coast_c__c,
                                                     Q9_drop_down_values_West_Coast_c__c
                                              From Generic_Survey__c
                                              Where Id = :recId[0]
                                              Limit 1
                                             ];
            integer finalTotal = 0;
            String q1 = genSurWest[0].Q1_drop_down_values_West_Coast__c;
            Integer q1Int = Integer.valueOf(q1);
            Integer q1Start = 30;
            if(q1Int > 0){
                if(q1Int >= 8){
                    finalTotal += 0;
                }else if(q1Int >= 5 && q1Int <= 7){
                    q1Start -= 25;
                    finalTotal += q1Start;
                } else if(q1Int >= 2 && q1Int <= 4){
                    q1Start -= 10;
                    finalTotal += q1Start;
                } else if(q1Int == 1){
                    q1Start -= 5;
                    finalTotal += q1Start;
                }
            }else{
                finalTotal += q1Start;
            }
            String q2 = genSurWest[0].Q2_drop_down_values_West_Coast_c__c;
            if(q2 == 'Yes'){
                finalTotal += 10;
            }
            String q3 = genSurWest[0].Q3_drop_down_values_West_Coast__c;
            Integer q3Int = Integer.valueOf(q3);
            Integer q3Start = 20;
            if(q3Int > 0){
                if(q3Int >= 6){
                    finalTotal += 0;
                }else if(q3Int >= 3 && q3Int <= 5){
                    q3Start -= 10;
                    finalTotal += q3Start;
                } else if(q3Int >= 1 && q3Int <= 2){
                    q3Start -= 5;
                    finalTotal += q3Start;
                } 
            }else{
                finalTotal += q3Start;
            }
            String q4 = genSurWest[0].Q4_drop_down_values_West_Coast_c__c;
            if(q4 == 'Yes'){
                finalTotal += 10;
            }
            String q5 = genSurWest[0].Q5_drop_down_values_West_Coast_c__c;
            if(q5 == 'Yes'){
                finalTotal += 5;
            }
            String q6 = genSurWest[0].Q6_drop_down_values_West_Coast_c__c;   
            if(q6 == 'Yes'){
                finalTotal += 5;
            }
            String q7 = genSurWest[0].Q7_drop_down_values_West_Coast_c__c;    
            if(q7 == 'No'){
                finalTotal += 5;
            }
            String q8 = genSurWest[0].Q8_drop_down_values_West_Coast_c__c;  
            if(q8 == 'Yes'){
                finalTotal += 10;
            }
            String q9 = genSurWest[0].Q9_drop_down_values_West_Coast_c__c;        
            if(q9 == 'Yes'){
                finalTotal += 5;
            }
             
            
            Generic_Survey__c genSurvey = new Generic_Survey__c();
            genSurvey.Id = recId[0];
            genSurvey.Survey_Total__c = finalTotal;
            update genSurvey;
                return recId;
       }
       if(getRecordType[0].RecordTypeId == recordTypeIdEast){ 
            List<Generic_Survey__c> genSur = [Select Question_1_drop_down_values__c, Question_2_drop_down_values__c,
                                                     Question_3_drop_down_values__c, Question_4_drop_down_values__c,
                                                     Question_5_drop_down_values__c, Question_6_drop_down_values__c,
                                                     Question_7_drop_down_values__c,Question_8_drop_down_values__c,
                                                     Question_9_drop_down_values__c, Question_10_drop_down_values__c
                                              From Generic_Survey__c
                                              Where Id = :recId[0]
                                              Limit 1
                                             ];
            integer finalTotal = 0;
           
            String q1 = genSur[0].Question_1_drop_down_values__c;
            Integer q1Int = Integer.valueOf(q1);
            Integer q1Start = 10;
            if(q1Int > 0){
                q1Start -= q1Int;
                finalTotal += q1Start;
            }else{
                finalTotal += q1Start;
            }
            String q2 = genSur[0].Question_2_drop_down_values__c;
            if(q2 == 'Yes'){
                finalTotal += 5;
            }
            String q3 = genSur[0].Question_3_drop_down_values__c;
            Integer q3Int = Integer.valueOf(q3);
            Integer q3Start = 10;
            if(q3Int > 0){
                q3Start -= q3Int;
                finalTotal += q3Start;
            }else{
                finalTotal += q3Start;
            }
            String q4 = genSur[0].Question_4_drop_down_values__c;
            if(q4 == 'Yes'){
                finalTotal += 5;
            }
            String q5 = genSur[0].Question_5_drop_down_values__c;
            if(q5 == 'Yes'){
                finalTotal += 5;
            }
            String q6 = genSur[0].Question_6_drop_down_values__c;   
            if(q6 == 'Yes'){
                finalTotal += 5;
            }
            String q7 = genSur[0].Question_7_drop_down_values__c;    
            if(q7 == 'Yes'){
                finalTotal += 5;
            }
            String q8 = genSur[0].Question_8_drop_down_values__c;  
            if(q8 == 'Yes'){
                finalTotal += 5;
            }
            String q9 = genSur[0].Question_9_drop_down_values__c;        
            if(q9 == 'Yes'){
                finalTotal += 5;
            }
            String q10 = genSur[0].Question_10_drop_down_values__c;        
            if(q10 == 'Yes'){
                finalTotal += 5;
            }
                         
            Generic_Survey__c genSurvey = new Generic_Survey__c();
            genSurvey.Id = recId[0];
            genSurvey.Survey_Total__c = finalTotal;
            update genSurvey;
           
            return recId;
     }
            
        }
        
         return recId;
  } 
    
}