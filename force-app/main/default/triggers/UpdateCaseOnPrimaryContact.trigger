trigger UpdateCaseOnPrimaryContact on Contact (after insert, after update) {
    List<Case> casesToUpdate = new List<Case>();

    for (Contact con : Trigger.new) {
        if (con.Level__c == 'primary') { 
            List<Case> relatedCases = [SELECT Id, ContactId FROM Case WHERE AccountId = :con.AccountId];

            for (Case c : relatedCases) {
                if (c.ContactId == null) {  
                    c.ContactId = con.Id;
                    casesToUpdate.add(c);
                }
            }
        }
    }

    if (casesToUpdate.size() > 0) {
        update casesToUpdate;
    }
}
