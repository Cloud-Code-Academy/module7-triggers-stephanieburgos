trigger AccountTrigger on Account (before insert) {
    for (Account acct : Trigger.new) {
        if (acct.Type == null) {
            acct.Type = 'Prospect';
        }
    }

    if (Trigger.isInsert) {
        for (Account acct : Trigger.new) {
            if (acct.ShippingAddress == null) {
                acct.BillingStreet = acct.ShippingStreet;
                acct.BillingCity = acct.ShippingCity;
                acct.BillingState = acct.ShippingState;
                acct.BillingPostalCode = acct.ShippingPostalCode;
                acct.BillingCountry = acct.ShippingCountry;
            }
        }
        for (Account acct : Trigger.new)  {
            if (acct.Phone != null && acct.Website != null && acct.Fax != null ) {
                acct.Rating = 'Hot';
            }
        }
    }
}