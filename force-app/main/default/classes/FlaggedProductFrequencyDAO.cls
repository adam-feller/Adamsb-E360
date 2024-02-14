public without sharing class FlaggedProductFrequencyDAO {
    public static List<Flagged_Product_Frequency__mdt> getFlaggedProductFrequencyByCategory(String frequencyCategory){
        return [SELECT MasterLabel, Num_Of_Days__c 
                FROM Flagged_Product_Frequency__mdt 
                WHERE MasterLabel = :frequencyCategory];
    }
}