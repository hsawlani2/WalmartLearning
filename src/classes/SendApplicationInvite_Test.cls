@isTest
private class SendApplicationInvite_Test {
    
    @testSetup static void setupTestData() {
        
        Account accnt = new Account();
        accnt.Name = 'Account TestData';
        insert accnt;
        
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.AccountId= accnt.Id;
        cont.Email='test@test.com';
        insert cont;
    
        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity TestData';
        opp.AccountId= accnt.Id;
        opp.StageName = 'Opportunity';
        opp.CloseDate = Date.today();
        insert opp; // at this the Primary_Contact__c should also be populated (because of the trigger)
    }

	private static testMethod void testEmailInviteSuccess() {

	    String oppName = 'Opportunity TestData';
	    Opportunity oppty = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Name = :oppName];
        
        Test.startTest();
        SendApplicationInvite.sendApplicationInvite(oppty.Id, oppty.Primary_Contact__c);
        Test.stopTest();
        
        Opportunity testOpp = [SELECT Application_Sent__c FROM Opportunity WHERE Name = :oppName];
        System.assertEquals(testOpp.Application_Sent__c, true, 'Email was sent!');
	}

}