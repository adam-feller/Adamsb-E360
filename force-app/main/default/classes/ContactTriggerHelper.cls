public class ContactTriggerHelper {

    public static void afterInsert(List<Contact> contactList){

    }

    public static void afterUpdate(List<Contact> contactList, Map<Id, Contact> contactOldMap){
        ContactTriggerHandler.updateAccountContactRelationForChangedEmail(contactList, contactOldMap);
        ContactTriggerHandler.processAccountRollup(contactList, contactOldMap);
    }

    public static void afterDelete(List<Contact> contactList){
        ContactTriggerHandler.processAccountRollup(contactList, new Map<Id, Contact>());
    }
}