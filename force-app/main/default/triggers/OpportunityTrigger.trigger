trigger OpportunityTrigger on Opportunity (before update, before delete) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            Set<Id> accountIds = new Set<Id>();

            for (Opportunity opp : Trigger.new) {
                // Validate that Amount is greater than 5000
                if (opp.Amount != null && opp.Amount <= 5000) {
                    opp.addError('Opportunity amount must be greater than 5000');
                }

                // Add Account Ids to Set
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }

            // Query the Contacts with Title = 'CEO' related to the Accounts
            List<Contact> ceoContacts = new List<Contact>([
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Title = 'CEO' 
                AND AccountId IN :accountIds
            ]);

            // Map the Contact's Account Id to the Contact
            Map<Id, Contact> acctToCeoContact = new Map<Id, Contact>();
            for (Contact con : ceoContacts) {
                acctToCeoContact.put(con.AccountId, con);
            }

            // Update Primary Contact in Opportunity 
            for (Opportunity opp : Trigger.new) {
                if (acctToCeoContact.containsKey(opp.AccountId)) {
                    opp.Primary_Contact__c = acctToCeoContact.get(opp.AccountId).Id;
                }
            }
        }
        
        when BEFORE_DELETE {
            // Create Set of related Account Ids from the deleted opportunities 
            Set<Id> accountIds = new Set<Id>();

            for (Opportunity opp : Trigger.old) {
                accountIds.add(opp.AccountId);
            }

            // Map Account Ids to the Account's Industry
            Map<Id, Account> accountMap = new Map<Id, Account>(
                [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
            );

            for (Opportunity opp : Trigger.old) {
                Account acc = accountMap.get(opp.AccountId);
                if (acc.Industry == 'Banking' && opp.StageName == 'Closed Won') {
                    opp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }
}