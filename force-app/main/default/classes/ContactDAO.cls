public without sharing class ContactDAO {
    public static List<Contact> getContactsByAccountId(Id accountId){
        return [SELECT Id, Name 
                FROM Contact 
                WHERE AccountId = :accountId];
    }
}