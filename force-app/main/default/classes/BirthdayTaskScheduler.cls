global class BirthdayTaskScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Date today = Date.today();
        Date tomorrow = today.addDays(1);
        Date dayAfterTomorrow = today.addDays(2);
        List<Task> tasksToCreate = new List<Task>();

        //query 1
        List<Contact> contactsToday = [
            SELECT Id, FirstName, LastName, Birthdate, OwnerId, AccountId, 
                   MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM Contact
            WHERE DAY_IN_MONTH(Birthdate) = :today.day()
            AND CALENDAR_MONTH(Birthdate) = :today.month()
        ];

        //query 2
        List<Contact> contactsTomorrow = [
            SELECT Id, FirstName, LastName, Birthdate, OwnerId, AccountId, 
                   MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM Contact
            WHERE DAY_IN_MONTH(Birthdate) = :tomorrow.day()
            AND CALENDAR_MONTH(Birthdate) = :tomorrow.month()
        ];

        //query 3
        List<Contact> contactsDayAfterTomorrow = [
            SELECT Id, FirstName, LastName, Birthdate, OwnerId, AccountId, 
                   MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM Contact
            WHERE DAY_IN_MONTH(Birthdate) = :dayAfterTomorrow.day()
            AND CALENDAR_MONTH(Birthdate) = :dayAfterTomorrow.month()
        ];

        //all contacts into a single list
        List<Contact> allContacts = new List<Contact>();
        allContacts.addAll(contactsToday);
        allContacts.addAll(contactsTomorrow);
        allContacts.addAll(contactsDayAfterTomorrow);

        for (Contact con : allContacts) {
            String mailingAddress = (con.MailingStreet != null ? con.MailingStreet + ', ' : '') +
                                    (con.MailingCity != null ? con.MailingCity + ', ' : '') +
                                    (con.MailingState != null ? con.MailingState + ', ' : '') +
                                    (con.MailingPostalCode != null ? con.MailingPostalCode + ', ' : '') +
                                    (con.MailingCountry != null ? con.MailingCountry : '');
            String comments = '';
            if (String.isBlank(mailingAddress)) {
                comments = 'The mailing address is unknown.\n';
            } else {
                comments = 'The Mailing Address of the Contact is: ' + mailingAddress + '.\n';
            }

            //conditionall industry details  available
            if (con.AccountId != null) {
                Account acc = [SELECT Name, Industry FROM Account WHERE Id = :con.AccountId LIMIT 1];
                comments += 'This Contact is an employee of ' + acc.Name;
                
                if (acc.Industry != null) {
                    comments += ', part of the ' + acc.Industry + ' Industry';
                }
                comments += '.\n'; 
            }

            comments += 'Consider making an appropriate gift. Today is the Birthdate of ' + con.FirstName + ' ' + con.LastName + '. He/She is now ' + 
                        (today.year() - con.Birthdate.year()) + ' years old.';

            //create new task
            Task newTask = new Task(
                Subject = con.FirstName + ' ' + con.LastName + ' Birthday!',
                OwnerId = con.OwnerId,
                Priority = 'Low',
                Status = 'Not Started',
                ActivityDate = con.Birthdate.addYears(today.year() - con.Birthdate.year()),
                WhatId = con.AccountId,
                Description = comments
            );

            tasksToCreate.add(newTask);
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
}
