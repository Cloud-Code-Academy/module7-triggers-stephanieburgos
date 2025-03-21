trigger AccountTrigger on Account (before insert, after insert) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            for (Account acct : Trigger.new) {
                if (acct.Type == null) {
                    acct.Type = 'Prospect';
                }
                if (acct.ShippingAddress == null) {
                    acct.BillingStreet = acct.ShippingStreet;
                    acct.BillingCity = acct.ShippingCity;
                    acct.BillingState = acct.ShippingState;
                    acct.BillingPostalCode = acct.ShippingPostalCode;
                    acct.BillingCountry = acct.ShippingCountry;
                }
                if (acct.Phone != null && acct.Website != null && acct.Fax != null ) {
                    acct.Rating = 'Hot';
                }
            }
        }

        when AFTER_INSERT {
            List<Contact> contactsToInsert = new List<Contact>();

            for (Account acct : Trigger.new) {
                Contact newContact = new Contact(
                    LastName = 'DefaultContact',
                    Email = 'default@email.com',
                    AccountId = acct.Id
                );
                contactsToInsert.add(newContact);
            }

            Database.insert(contactsToInsert, AccessLevel.SYSTEM_MODE);
        }
    }
}
