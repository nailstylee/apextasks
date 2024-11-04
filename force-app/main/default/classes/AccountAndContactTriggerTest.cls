@isTest
public class AccountAndContactTriggerTest {

    @testSetup
    static void setupTestData() {
        //test user
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            ProfileId = profileId.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        //test account
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = testUser.Id,
            Priority__c = 'High'
        );
        insert testAccount;
    }

    @isTest
    static void testCaseCreationOnAccountInsert() {
        // fetch the test acc
        Account testAccount = [SELECT Id, Name, OwnerId, Priority__c FROM Account WHERE Name = 'Test Account' LIMIT 1];

        List<Case> createdCases = [SELECT Id, OwnerId, Origin, Priority, Subject, AccountId 
                                   FROM Case WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, createdCases.size(), 'A Case should have been created.');
        Case createdCase = createdCases[0];
        System.assertEquals(testAccount.OwnerId, createdCase.OwnerId, 'Case owner should match Account owner.');
        System.assertEquals('System', createdCase.Origin, 'Case Origin should be "System".');
        System.assertEquals(testAccount.Priority__c, createdCase.Priority, 'Case Priority should match Account Priority.');
        System.assertEquals(testAccount.Name + '- Onboarding', createdCase.Subject, 'Case Subject should be "<Account Name> - Onboarding".');
    }

    @isTest
    static void testUpdateCaseWithPrimaryContact() {
        // fetch the test acc
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        //create a primary contact
        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Level__c = 'primary'
        );
        insert primaryContact;

        //verify that the existing case was updated with the primary contact
        List<Case> updatedCases = [SELECT Id, ContactId FROM Case WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, updatedCases.size(), 'There should be one Case related to the Account.');
        Case updatedCase = updatedCases[0];
        
        //verify that the case was linked to the primary contact
        System.assertEquals(primaryContact.Id, updatedCase.ContactId, 'The Case should be linked to the primary Contact.');
    }

    @isTest
    static void testNoCaseUpdateWithNonPrimaryContact() {
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Contact nonPrimaryContact = new Contact(
            FirstName = 'Non-Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Level__c = 'secondary' //other than "primary"
        );
        insert nonPrimaryContact;

        // verify that the existing case was not updated with the not primary contact
        List<Case> cases = [SELECT Id, ContactId FROM Case WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, cases.size(), 'There should be one Case related to the Account.');
        Case caseToVerify = cases[0];
        
        System.assertEquals(null, caseToVerify.ContactId, 'The Case should not be linked to the non-primary Contact.');
    }
}