@isTest
public class MenuSurveyAnswersControllerTest {
    static Id MENU_SURVEY_RECORDTYPEID = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Menu_Survey').getRecordTypeId();
    static Id BRAND_RECORDTYPEID = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();

    @TestSetup
    private static void setup() {
        
        //Create new Survey
        Account testAccount = TestFactory.createAccount('Test Account', '201', 'PVA', 'PDVA-CHANTILLY', null, '2345');
        Survey__c testSurvey = new Survey__c(Account__c=testAccount.Id, Survey_Type__c='Menu', RecordTypeId=MENU_SURVEY_RECORDTYPEID);
        insert testSurvey;
        //Create Survey Questions
        Survey__c survey = [SELECT Id FROM Survey__c LIMIT 1];
        List<Survey_Answer__c> insertList = new List<Survey_Answer__c>();
        Survey_Answer__c sa1 = new Survey_Answer__c (survey__c= survey.Id, Order__c= 2, Question__c= 'What are the cocktails?');
        insertList.add(sa1);
        Survey_Answer__c sa2 = new Survey_Answer__c (survey__c= survey.Id, Order__c= 3, Question__c= 'What are the cocktails?');
        insertList.add(sa2);
        Survey_Answer__c sa3 = new Survey_Answer__c (survey__c= survey.Id, Order__c= 4, Question__c= 'What are the well brands?');
        insertList.add(sa3);
        insert insertList;

    }
    @isTest
    static void testGetSurveyQuestions() {  
        //Get the Survey 
        Survey__c survey = [SELECT Id FROM Survey__c];
        
        Test.startTest();
        List<Survey_Answer__c> returned = MenuSurveyAnswersController.getSurveyQuestions(survey.Id);
        Test.stopTest();

        System.assertEquals(2, returned.size(), 'Incorrect number of answers returned');
    }

    @isTest
    static void testGetWellSurveyQuestions() {  
        //Get the Survey 
        Survey__c survey = [SELECT Id FROM Survey__c];
        
        Test.startTest();
        List<Survey_Answer__c> returned = MenuSurveyAnswersController.getSurveyWellQuestions(survey.Id);
        Test.stopTest();

        System.assertEquals(1, returned.size(), 'Incorrect number of answers returned');
    }
    @isTest
    static void testInsertSurveyAnswer() {  
        //Get the Survey 
        Survey__c survey = [SELECT Id FROM Survey__c];
        Integer questionNumber = 4;        
        Test.startTest();
        MenuSurveyAnswersController.insertSurveyAnswer(questionNumber, survey.Id);
        Test.stopTest();
        List<Survey_Answer__c> answers = [SELECT Id FROM Survey_Answer__c];

        System.assertEquals(4, answers.size(), 'Incorrect number of answers returned');
    }
    @isTest
    static void testDeleteSurveyAnswer() {  
        //Get the Survey 
        Survey_Answer__c surveyAnswer = [SELECT Id FROM Survey_Answer__c WHERE Order__c = 2];
          
        Test.startTest();
        MenuSurveyAnswersController.deleteSurveyAnswer(surveyAnswer.Id);
        Test.stopTest();

        List<Survey_Answer__c> returned = [SELECT Id FROM Survey_Answer__c WHERE Order__c = 2 AND IsDeleted = True ALL ROWS];
        System.assertEquals(1, returned.size(), 'Incorrect number of answers returned');
    }
    @isTest
    static void testSetProductId() {  
        //Get the Survey 
        Survey_Answer__c surveyAnswer = [SELECT Id FROM Survey_Answer__c WHERE Order__c = 2];
        //create Products
        Product2 p = TestFactory.createProduct('ProductName','123','BrandName','externalId');
        p.RecordTypeId = BRAND_RECORDTYPEID;
        update p;

        Test.startTest();
        MenuSurveyAnswersController.setProductId(surveyAnswer.Id, p.Id);
        Test.stopTest();

        Survey_Answer__c returned = [SELECT Id, Product__c FROM Survey_Answer__c WHERE Order__c = 2];
        System.assertEquals(p.Id, returned.Product__c, 'Incorrect product value');
    }
    @isTest
    static void testSetCheckboxValue() {  
        //Get the Survey 
        Id surveyAnswerId = [SELECT Id FROM Survey_Answer__c WHERE Order__c = 2].Id;
           
        
        Test.startTest();
        MenuSurveyAnswersController.setCheckboxValue(surveyAnswerId, true);
        Test.stopTest();

        Survey_Answer__c returned = [SELECT Id, Is_Reyes_Product__c FROM Survey_Answer__c WHERE Id = :surveyAnswerId];
        System.assertEquals(true, returned.Is_Reyes_Product__c, 'Incorrect boolean value');
    }
    @isTest
    static void testSetWellCheckboxValue() {  
        //Get the Survey 
        Id surveyAnswerId = [SELECT Id FROM Survey_Answer__c WHERE Order__c = 4].Id;
           
        
        Test.startTest();
        MenuSurveyAnswersController.setWellCheckboxValue(surveyAnswerId, true);
        Test.stopTest();

        Survey_Answer__c returned = [SELECT Id, Is_Reyes_Product__c FROM Survey_Answer__c WHERE Id = :surveyAnswerId];
        System.assertEquals(true, returned.Is_Reyes_Product__c, 'Incorrect boolean value');
    }
    @isTest
    static void testSetPicklistValues() {  
        //Get the Survey 
        Id surveyAnswerId = [SELECT Id FROM Survey_Answer__c WHERE Order__c = 2].Id;
           
        
        Test.startTest();
        MenuSurveyAnswersController.setPicklistAnswer(surveyAnswerId, 'Vodka', 'Other');
        Test.stopTest();

        Survey_Answer__c returned = [SELECT Id, Liquor_Type__c, Liquor_Brand__c FROM Survey_Answer__c WHERE Id = :surveyAnswerId];
        System.assertEquals('Vodka', returned.Liquor_Type__c, 'Incorrect picklist value');
        System.assertEquals('Other', returned.Liquor_Brand__c, 'Incorrect picklist value');
    }
}