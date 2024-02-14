@isTest
public class MerchStoreSurveyCalculatorTest {
        static testMethod void MerchStoreSurveytest(){
        Id recordTypeIdEast = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('East Coast').getRecordTypeId();
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyEast = new Generic_Survey__c();
            	genSurveyEast.Question_1_drop_down_values__c  = '0';
            	genSurveyEast.Question_2_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_3_drop_down_values__c  = '0';
                genSurveyEast.Question_4_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_5_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_6_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_7_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_8_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_9_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_10_drop_down_values__c = 'Yes';
            	genSurveyEast.RecordTypeId = recordTypeIdEast;
         insert genSurveyEast;
            
         recId.add(genSurveyEast.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
    
            
    static testMethod void MerchStoreSurveytestEast(){
        Id recordTypeIdEast = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('East Coast').getRecordTypeId();
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyEast = new Generic_Survey__c();
            	genSurveyEast.Question_1_drop_down_values__c  = '5';
            	genSurveyEast.Question_2_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_3_drop_down_values__c  = '5';
                genSurveyEast.Question_4_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_5_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_6_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_7_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_8_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_9_drop_down_values__c  = 'Yes';
                genSurveyEast.Question_10_drop_down_values__c = 'Yes';
            	genSurveyEast.RecordTypeId = recordTypeIdEast;
         insert genSurveyEast;
            
         recId.add(genSurveyEast.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
    
    static testMethod void MerchStoreSurveyTestWest(){
        Id recordTypeIdWest = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('West Coast').getRecordTypeId();
        
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyWest = new Generic_Survey__c();
            	genSurveyWest.Q1_drop_down_values_West_Coast__c    = '0';
            	genSurveyWest.Q2_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q3_drop_down_values_West_Coast__c    = '0';
                genSurveyWest.Q4_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q5_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q6_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q7_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q8_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q9_drop_down_values_West_Coast_c__c  = 'Yes';
            	genSurveyWest.RecordTypeId = recordTypeIdWest;
        insert genSurveyWest;
            
         recId.add(genSurveyWest.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
    
        static testMethod void MerchStoreSurveyTestWestMostMissed(){
        Id recordTypeIdWest = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('West Coast').getRecordTypeId();
        
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyWest = new Generic_Survey__c();
            	genSurveyWest.Q1_drop_down_values_West_Coast__c    = '8';
            	genSurveyWest.Q2_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q3_drop_down_values_West_Coast__c    = '6';
                genSurveyWest.Q4_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q5_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q6_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q7_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q8_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q9_drop_down_values_West_Coast_c__c  = 'Yes';
            	genSurveyWest.RecordTypeId = recordTypeIdWest;
        insert genSurveyWest;
            
         recId.add(genSurveyWest.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
    
     static testMethod void MerchStoreSurveyTestWest2ndMostMissed(){
        Id recordTypeIdWest = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('West Coast').getRecordTypeId();
        
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyWest = new Generic_Survey__c();
            	genSurveyWest.Q1_drop_down_values_West_Coast__c    = '6';
            	genSurveyWest.Q2_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q3_drop_down_values_West_Coast__c    = '4';
                genSurveyWest.Q4_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q5_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q6_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q7_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q8_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q9_drop_down_values_West_Coast_c__c  = 'Yes';
            	genSurveyWest.RecordTypeId = recordTypeIdWest;
        insert genSurveyWest;
            
         recId.add(genSurveyWest.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
    
    static testMethod void MerchStoreSurveyTestWest3rdMostMissed(){
        Id recordTypeIdWest = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('West Coast').getRecordTypeId();
        
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyWest = new Generic_Survey__c();
            	genSurveyWest.Q1_drop_down_values_West_Coast__c    = '3';
            	genSurveyWest.Q2_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q3_drop_down_values_West_Coast__c    = '2';
                genSurveyWest.Q4_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q5_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q6_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q7_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q8_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q9_drop_down_values_West_Coast_c__c  = 'Yes';
            	genSurveyWest.RecordTypeId = recordTypeIdWest;
        insert genSurveyWest;
            
         recId.add(genSurveyWest.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
    
        
    static testMethod void MerchStoreSurveyTestWest4thMostMissed(){
        Id recordTypeIdWest = Schema.SObjectType.Generic_Survey__c.getRecordTypeInfosByName().get('West Coast').getRecordTypeId();
        
        //Create a Merch Checklist
        List<String> recId = new List<String>();
           
        Generic_Survey__c genSurveyWest = new Generic_Survey__c();
            	genSurveyWest.Q1_drop_down_values_West_Coast__c    = '1';
            	genSurveyWest.Q2_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q3_drop_down_values_West_Coast__c    = '1';
                genSurveyWest.Q4_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q5_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q6_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q7_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q8_drop_down_values_West_Coast_c__c  = 'Yes';
                genSurveyWest.Q9_drop_down_values_West_Coast_c__c  = 'Yes';
            	genSurveyWest.RecordTypeId = recordTypeIdWest;
        insert genSurveyWest;
            
         recId.add(genSurveyWest.Id);
                
        
        Test.StartTest(); 
        	MerchStoreSurveyCalculator.createTotal(recId);
        Test.StopTest();
    }
}