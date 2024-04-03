public with sharing class AccountController {
    private final Account acc;
    public List<Contact> contacts {get; set;}
    public Id selectedContactId {get; set;}
    
    public AccountController(ApexPages.StandardController stdController) {
        this.acc = (Account)stdController.getRecord();
        contacts = [SELECT Id, Name, Title, Phone, IsPrimary__c FROM Contact WHERE AccountId = :acc.Id];
    }
    
    public PageReference setPrimaryContact() {
        for(Contact con : contacts) {
            if(con.Id == selectedContactId) {
                con.IsPrimary__c = true;
            } else {
                con.IsPrimary__c = false;
            }
        }
        update contacts;
        return new PageReference('/' + acc.Id);
    }
}
