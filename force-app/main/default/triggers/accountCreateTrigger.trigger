trigger accountCreateTrigger on Account (after insert) {
    List<Case> casesToInsert = new List<Case>();

    for (Account acc : Trigger.new) {
        Case newCase = new Case(
            OwnerId = acc.OwnerId,
            Origin = 'System',
            Priority = acc.Priority__c,        
            Subject = acc.Name + '- Onboarding', 
            AccountId = acc.Id                        
        );
        casesToInsert.add(newCase);
    }

    if (casesToInsert.size() > 0) {
        insert casesToInsert;
    }
}