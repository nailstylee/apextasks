trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {

    // before insert/update logic for age
    if (Trigger.isBefore) {
        for (Contact con : Trigger.new) {
            if (con.AccountId != null && con.Birthdate != null) {
                Account relatedAccount = [SELECT BillingCountry FROM Account WHERE Id = :con.AccountId LIMIT 1];
                Integer legalAge = (relatedAccount.BillingCountry == 'US') ? 21 : 18;
                
                Integer contactAge = Date.today().year() - con.Birthdate.year();
                
                // if their birthday hasn't occurred yet this year subtract 1 from the age
                if (Date.today().month() < con.Birthdate.month() || 
                    (Date.today().month() == con.Birthdate.month() && Date.today().day() < con.Birthdate.day())) {
                    contactAge--;
                }

                if (contactAge < legalAge) {
                    con.addError('All contact persons should be of legal age.');
                }
            }
        }
    }


}
