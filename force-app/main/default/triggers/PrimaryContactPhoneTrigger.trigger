trigger PrimaryContactPhoneTrigger on Contact (before update, before insert) {
    List<Contact> contactsToUpdate = new List<Contact>();
    Map<Id, Contact> primaryContactsMap = new Map<Id, Contact>();


    for (Contact updatedContact : Trigger.new) {
        if (updatedContact.IsPrimary__c && updatedContact.AccountId != null) {
            primaryContactsMap.put(updatedContact.AccountId, updatedContact);
        }
    }

    List<Id> primaryContactIds = new List<Id>(primaryContactsMap.keySet());

    for (Contact relatedContact : [SELECT Id, AccountId, Primary_Contact_Phone__c 
                                    FROM Contact
                                    WHERE AccountId IN :primaryContactIds AND Id != :primaryContactIds]) {
        if (primaryContactsMap.containsKey(relatedContact.AccountId)) {
            Contact primaryContact = primaryContactsMap.get(relatedContact.AccountId);
            relatedContact.Primary_Contact_Phone__c = primaryContact.Primary_Contact_Phone__c;
            contactsToUpdate.add(relatedContact);
        }
    }

   
    if (!contactsToUpdate.isEmpty()) {
        Database.SaveResult[] updateResults = Database.update(contactsToUpdate, false);
        for (Database.SaveResult result : updateResults) {
            if (result.isSuccess()) {
                System.debug('Update Contact ' + result.getId());
            } else {
                for (Database.Error err : result.getErrors()) {                   
                    System.debug('Error ' + err.getStatusCode() + ', Error Message ' + err.getMessage());
                }
            }
        }
    }
}
