@isTest
public class ContactTriggerTest {

    @testSetup
    static void setupData() {
        // US account
        Account usAccount = new Account(
            Name = 'US Account',
            BillingCountry = 'US'
        );
        insert usAccount;

        //create not us account
        Account nonUsAccount = new Account(
            Name = 'Non-US Account',
            BillingCountry = 'Canada'
        );
        insert nonUsAccount;

        // US account with an industry
        Account usAccountWithIndustry = new Account(
            Name = 'US Industry Account',
            BillingCountry = 'US',
            Industry = 'Technology'
        );
        insert usAccountWithIndustry;
    }

    @isTest
    static void testLegalAgeValidation_USAccount() {
        // fetch the US account
        Account usAccount = [SELECT Id FROM Account WHERE Name = 'US Account' LIMIT 1];

        Contact minorContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = usAccount.Id,
            Birthdate = Date.today().addYears(-20) 
        );

        Test.startTest();
        try {
            insert minorContact;
            System.assert(false, 'Expected DML Exception due to minor contact.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('All contact persons should be of legal age.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testLegalAgeValidation_NonUSAccount() {
        // fetch the non US account
        Account nonUsAccount = [SELECT Id FROM Account WHERE Name = 'Non-US Account' LIMIT 1];

        // insert a contact who is below 18 for
        Contact minorContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            AccountId = nonUsAccount.Id,
            Birthdate = Date.today().addYears(-17)
        );

        Test.startTest();
        try {
            insert minorContact;
            System.assert(false, 'Expected DML Exception due to minor contact.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('All contact persons should be of legal age.'));
        }
        Test.stopTest();
    }
}
