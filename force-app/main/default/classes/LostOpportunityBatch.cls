global class LostOpportunityBatch implements Database.Batchable<sObject> {
    Map<Id, Decimal> closedWonAmounts = new Map<Id, Decimal>();
    Map<Id, Decimal> openAmounts = new Map<Id, Decimal>();
    Map<Id, Decimal> closedLostAmounts = new Map<Id, Decimal>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT AccountId, StageName, Amount FROM Opportunity WHERE CloseDate = THIS_MONTH';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for (Opportunity opp : scope) {

            if (opp.StageName == 'Closed Won') {
                if (closedWonAmounts.containsKey(opp.AccountId)) {
                    closedWonAmounts.put(opp.AccountId, closedWonAmounts.get(opp.AccountId) + opp.Amount);
                } else {
                    closedWonAmounts.put(opp.AccountId, opp.Amount);
                }
            } else if (opp.StageName == 'Closed Lost') {
                if (closedLostAmounts.containsKey(opp.AccountId)) {
                    closedLostAmounts.put(opp.AccountId, closedLostAmounts.get(opp.AccountId) + opp.Amount);
                } else {
                    closedLostAmounts.put(opp.AccountId, opp.Amount);
                }
            } else {
                if (openAmounts.containsKey(opp.AccountId)) {
                    openAmounts.put(opp.AccountId, openAmounts.get(opp.AccountId) + opp.Amount);
                } else {
                    openAmounts.put(opp.AccountId, opp.Amount);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'jenniferkorablik@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('opportunities');

        String emailBody = 'Bellow is a table opportunities related to the account:\n\n';

        emailBody += 'Close Won:\n';
        for (Id accountId : closedWonAmounts.keySet()) {
            emailBody += 'Account ID: ' + accountId + ', Total Amount: ' + closedWonAmounts.get(accountId) + '\n';
        }
        emailBody += '\n';

        emailBody += 'Open:\n';
        for (Id accountId : openAmounts.keySet()) {
            emailBody += 'Account ID: ' + accountId + ', Total Amount: ' + openAmounts.get(accountId) + '\n';
        }
        emailBody += '\n';

             emailBody += 'Close Lost:\n';
        for (Id accountId : closedLostAmounts.keySet()) {
            emailBody += 'Account ID: ' + accountId + ', Total Amount: ' + closedLostAmounts.get(accountId) + '\n';
        }

        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}
