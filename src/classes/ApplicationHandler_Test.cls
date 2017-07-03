@isTest
private class ApplicationHandler_Test {
    
    private static final String ACCOUNT_PREFIX = 'ACCT-';
    private static final String CONTACT_PREFIX = 'CONTACT-';
    private static final String OPP_PREFIX = 'OPP-';
    private static final Integer ARR_SIZE = 50;
    
    private static List<Account> setUpAccounts() {
        
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < ARR_SIZE; i++) {
            accountList.add(new Account(Name=ACCOUNT_PREFIX+i));
        }
        insert accountList;
        
        String whereClause = '%'+ACCOUNT_PREFIX+'%';
        accountList = [SELECT Id FROM Account WHERE Name LIKE :whereClause];
        
        List<Contact> contactList = new List<Contact>();
        Integer i = 0;
        for (Account anAccount : accountList) {
            Contact aContact = new Contact(
                LastName=CONTACT_PREFIX+i,
                AccountId=anAccount.Id);
            contactList.add(aContact);
            
            i++;
        }
        insert contactList;
        
        return accountList;
    }

    private static testMethod void testAfterInsert() {
        
        List<Account> accountList = setUpAccounts();
        List<Opportunity> oppList = new List<Opportunity>();
        
        Integer i = 0;
        for (Account anAccount : accountList) {
            oppList.add(new Opportunity(
                Name=OPP_PREFIX+i,
                AccountId=anAccount.Id,
                CloseDate=Date.today(),
                StageName='Opportunity'
                ));
            i++;
        }
        
       // Test.startTest();
        insert oppList;
       // Test.stopTest();
        
       // String whereClause = '%'+OPP_PREFIX+'%';
        //oppList = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Name LIKE :whereClause];
        //for (Opportunity anOpp : oppList) {
        //    System.assert(anOpp.Primary_Contact__c != null, 'Primary Contact should not be null');
        //}
        
        List<Application__c> applist = new List<Application__c>();
        applist.add(new Application__c (
            Account__c=accountList[0].Id,
            Opportunity__c= oppList[0].Id,
            Primary_Contact_First_Name__c='First name',
            Primary_Contact_Last_Name__c='Last name',
            Primary_Contact_Email__c='test@test.com',
            Legal_Company_Name__c='Legal name',
            Preferred_integration_General__c='Direct',
            Preferred_integration_Specific__c='API' 
            ));

        applist.add(new Application__c (
            Account__c=accountList[1].Id,
            Opportunity__c= oppList[1].Id,
            Primary_Contact_First_Name__c='First name',
            Primary_Contact_Last_Name__c='Last name',
            Primary_Contact_Email__c='test@test.com',
            Legal_Company_Name__c='Legal name',
            Preferred_integration_General__c='Channel Aggregator',
            Preferred_integration_Specific__c='Other' 
            ));
        Test.startTest();
        insert applist;
        Test.stopTest();
    }


}