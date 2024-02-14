@isTest
public class ChatbotCutoffCheck_Test {    
       
      @testSetup static void setup() {
          
       // Central
       // Warehouse
       Time myTimeCNT = Time.newInstance(18, 00, 00, 00);
        Warehouse__c testWarehouseCnt    = new Warehouse__c();
        testWarehouseCnt.Name            = 'PDC Warehouse';
        testWarehouseCnt.Warehouse_ID__c = 'PDC';
        testWarehouseCnt.OrderCutoff__c  = myTimeCNT;
        testWarehouseCnt.TimeZone__c     = 'Central Standard Time';
        insert testWarehouseCnt;
       // Account
       Account testAccountCnt = TestFactory.createAccount('Test Account Central', null, null, 'PDC Warehouse', null, null);
        // Contact 
        Contact testContactCnt = new Contact();
        testContactCnt.AccountId = testAccountCnt.Id;
        testContactCnt.Primary_Contact__c = false;
        testContactCnt.FirstName = 'Test2';
        testContactCnt.LastName = 'User2';
        testContactCnt.Email = 'test2@gmail.com';
        testContactCnt.Phone = '5852088501';
        insert testContactCnt;
       // TTO Auth
       TTO_Authorization__c ttoAuthCentral = new TTO_Authorization__c();
        ttoAuthCentral.Account__c = testAccountCnt.Id;
        ttoAuthCentral.Contact__c = testContactCnt.Id;
        insert ttoAuthCentral;
         
      } 
    
    
    public static string createDefaultTZData(integer ttoAuth) {
        if(ttoAuth == 1){
            //Create and retrieve the User for Messaging
            MessagingEndUser meu = new MessagingEndUser();
            meu.Name = '+15852588501';
            meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
            meu.MessageType = 'Text';
            meu.MessagingPlatformKey = '123';
            insert meu;

        	MessagingEndUser createdMEU = [SELECT Id FROM MessagingEndUser WHERE Name = '+15852588501' LIMIT 1];
            
            //Create and retrieve the Test Message
            MessagingSession ms = new MessagingSession();
            ms.MessagingEndUserId = createdMEU.Id;
            ms.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
            ms.Status = 'Waiting';
            insert ms;
    
            return createdMEU.Id;
        }
        //Create and retrieve the User for Messaging
            MessagingEndUser meu = new MessagingEndUser();
            meu.Name = '+15852088501';
            meu.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
            meu.MessageType = 'Text';
            meu.MessagingPlatformKey = '123';
            insert meu;

        	MessagingEndUser createdMEU = [SELECT Id FROM MessagingEndUser WHERE Name = '+15852088501' LIMIT 1];
            
            //Create and retrieve the Test Message
            MessagingSession ms = new MessagingSession();
            ms.MessagingEndUserId = createdMEU.Id;
            ms.MessagingChannelId = [SELECT ID FROM MessagingChannel LIMIT 1].Id;
            ms.Status = 'Waiting';
            insert ms;
    
            return createdMEU.Id;
          
    }
    
    static testMethod void defaultTimeZone() {
        
        string meuId = createDefaultTZData(0);
        List<ChatbotCutoffCheck.ResponseInput> riList = new List<ChatbotCutoffCheck.ResponseInput>();
        ChatbotCutoffCheck.ResponseInput ri = new ChatbotCutoffCheck.ResponseInput();
        ri.EndUserId = meuId;
        riList.add(ri);
        

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotCutoffCheck.ResponseOutput> roList = ChatbotCutoffCheck.performCutoffCheck(riList);
        Test.stopTest();

        ChatbotCutoffCheck.ResponseOutput ro = roList[0];
      
    }
    

   

        
    static testMethod void testNoTTOAuth() {
 
        string meuId = createDefaultTZData(1);
        List<ChatbotCutoffCheck.ResponseInput> riList = new List<ChatbotCutoffCheck.ResponseInput>();
        ChatbotCutoffCheck.ResponseInput ri = new ChatbotCutoffCheck.ResponseInput();
        ri.EndUserId = meuId;
        riList.add(ri);
        

        //Get Auth records from the End User
        Test.startTest();
        List<ChatbotCutoffCheck.ResponseOutput> roList = ChatbotCutoffCheck.performCutoffCheck(riList);
        Test.stopTest();

        ChatbotCutoffCheck.ResponseOutput ro = roList[0]; 
    }
       
    
    static testMethod void testNearCutOff() {
            Boolean IsNearCutoff  = false;
            Boolean IsAfterCutoff = false;
            Boolean IsBeforeOpen  = false;
            
               List<TTO_Authorization__c> ttoAuth = [SELECT Name,Contact__r.Phone,Account__c,Id,LastReferencedDate,
                                                   Account__r.WarehouseCutoffTime__c,Account__r.Warehouse_Lookup__r.TimeZone__c,Account__r.Warehouse_Lookup__r.Name
                                                  FROM TTO_Authorization__c 
                                                  WHERE Contact__r.Phone = '5852088501'
                                                  LIMIT 1];
                Time cutoffTime          = ttoAuth[0].Account__r.WarehouseCutoffTime__c;
                // Get Hour
                Integer myHourPacific    = 18;
                Integer cutoffTimeHour   = 19;
                // Get Minute
                Integer myMinutePacific  = 55;
                Integer cutoffTimeMinute = 00;
                // Call helper method
                Test.startTest();
                String cutOffMessage     = ChatbotCutoffCheck.cutOffTimeCheck(cutoffTimeMinute, cutoffTimeHour, myMinutePacific , myHourPacific);
        		Test.stopTest();
                if(cutOffMessage == 'CUTOFF CLOSE'){
                     IsNearCutoff  = true;
                     IsAfterCutoff = false;
                     IsBeforeOpen  = false;
                    System.assertEquals(isNearCutoff, true);
                }
        }
    
        static testMethod void testAfterCutOff() {
            Boolean IsNearCutoff  = false;
            Boolean IsAfterCutoff = false;
            Boolean IsBeforeOpen  = false;
            
               List<TTO_Authorization__c> ttoAuth = [SELECT Name,Contact__r.Phone,Account__c,Id,LastReferencedDate,
                                                   Account__r.WarehouseCutoffTime__c,Account__r.Warehouse_Lookup__r.TimeZone__c,Account__r.Warehouse_Lookup__r.Name
                                                  FROM TTO_Authorization__c 
                                                  WHERE Contact__r.Phone = '5852088501'
                                                  LIMIT 1];
                Time cutoffTime          = ttoAuth[0].Account__r.WarehouseCutoffTime__c;
                // Get Hour
                Integer myHourPacific    = 19;
                Integer cutoffTimeHour   = 19;
                // Get Minute
                Integer myMinutePacific  = 56;
                Integer cutoffTimeMinute = 00;
                Test.startTest();
                String cutOffMessage     = ChatbotCutoffCheck.cutOffTimeCheck(cutoffTimeMinute, cutoffTimeHour, myMinutePacific , myHourPacific);
        		Test.stopTest();
               if(cutOffMessage == 'After Cutoff') {
                     IsNearCutoff  = false;
                     IsAfterCutoff = true;
                     IsBeforeOpen  = false;
                    System.assertEquals(isAfterCutoff, true);
                }
        } 
    
        static testMethod void testHalfHourCutoff() {
            Boolean IsNearCutoff  = false;
            Boolean IsAfterCutoff = false;
            Boolean IsBeforeOpen  = false;
                // Get Hour
                Integer myHourPacific    = 18;
                Integer cutoffTimeHour   = 18;
                // Get Minute
                Integer myMinutePacific  = 25;
                Integer cutoffTimeMinute = 30;
                Test.startTest();
                String cutOffMessage     = ChatbotCutoffCheck.cutOffTimeCheck(cutoffTimeMinute, cutoffTimeHour, myMinutePacific , myHourPacific);
        		Test.stopTest();
            
              if(cutOffMessage == 'CUTOFF CLOSE'){
                 IsNearCutoff  = true;
                 IsAfterCutoff = false;
                 IsBeforeOpen  = false;
                 System.assertEquals(isNearCutoff, true);
            } 
        }
            
    static testMethod void testFullHourCloseCutoff() {
            Boolean IsNearCutoff  = false;
            Boolean IsAfterCutoff = false;
            Boolean IsBeforeOpen  = false;
                // Get Hour
                Integer myHourPacific    = 17;
                Integer cutoffTimeHour   = 18;
                // Get Minute
                Integer myMinutePacific  = 55;
                Integer cutoffTimeMinute = 00;
                Test.startTest();
                String cutOffMessage     = ChatbotCutoffCheck.cutOffTimeCheck(cutoffTimeMinute, cutoffTimeHour, myMinutePacific , myHourPacific);
        		Test.stopTest();
            
              if(cutOffMessage == 'CUTOFF CLOSE'){
                 IsNearCutoff  = true;
                 IsAfterCutoff = false;
                 IsBeforeOpen  = false;
                 System.assertEquals(isNearCutoff, true);
            } 
        } 
    
        static testMethod void testNoTTO() {
            Boolean IsNearCutoff  = false;
            Boolean IsAfterCutoff = false;
            Boolean IsBeforeOpen  = false;
                // Get Hour
                Integer myHourPacific    = 99;
                Integer cutoffTimeHour   = 99;
                // Get Minute
                Integer myMinutePacific  = 99;
                Integer cutoffTimeMinute = 99;
                Test.startTest();
                String cutOffMessage     = ChatbotCutoffCheck.cutOffTimeCheck(cutoffTimeMinute, cutoffTimeHour, myMinutePacific , myHourPacific);
        		Test.stopTest();

        } 
    
        

    
            
    static testMethod void earlyWarehousePacific() {
            Boolean IsNearCutoff  = false;
            Boolean IsAfterCutoff = false;
            Boolean IsBeforeOpen  = false;
            
               List<Warehouse__c> ttoAuth = [SELECT Id, OrderCutoff__c
                                                  FROM Warehouse__c
                                                  WHERE Name = 'PDC Warehouse'
                                                  LIMIT 1];
                Time cutoffTime          = ttoAuth[0].OrderCutoff__c;
          		Time myTime = Time.newInstance(08, 00, 00, 00);
        	    ttoAuth[0].OrderCutoff__c = myTime;
        		update ttoAuth;
        
            string meuId = createDefaultTZData(0);
            List<ChatbotCutoffCheck.ResponseInput> riList = new List<ChatbotCutoffCheck.ResponseInput>();
            ChatbotCutoffCheck.ResponseInput ri = new ChatbotCutoffCheck.ResponseInput();
            ri.EndUserId = meuId;
            riList.add(ri);
            
    
            //Get Auth records from the End User
            Test.startTest();
            List<ChatbotCutoffCheck.ResponseOutput> roList = ChatbotCutoffCheck.performCutoffCheck(riList);
            Test.stopTest();
    
            ChatbotCutoffCheck.ResponseOutput ro = roList[0];
        }
     
    
    
 // END OF CLASS
}