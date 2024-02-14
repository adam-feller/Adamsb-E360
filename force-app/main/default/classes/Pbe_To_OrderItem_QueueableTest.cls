@IsTest
public with sharing class Pbe_To_OrderItem_QueueableTest {
    
        @IsTest
        public static void testCopy(){
            PriceBookEntry_To_OrderItem_Queueable.copyPricebookEntries(new List<PriceBookEntry>{
                new PriceBookEntry(Invoice__r = new Invoice__c(External_Id__c = '123')),
                new PriceBookEntry(Invoice__r = new Invoice__c(External_Id__c = '123'))
            });
        }
    
        @IsTest
        public  static void testQuery(){
            Date td = System.today();
            PriceBookEntry_To_OrderItem_Queueable.queryPricebookEntries(null,td.addDays(-90),td, 1);
        }
        
    
        @IsTest
        public  static void testExecuteNow(){
            PriceBookEntry_To_OrderItem_Queueable.executeNow();
        }
    }