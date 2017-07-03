@isTest
private class OpportunityTrigger_Test {
    
    private static final String ACCOUNT_PREFIX = 'ACCT-';
    private static final String CONTACT_PREFIX = 'CONTACT-';
    private static final String OPP_PREFIX = 'OPP-';
    private static final Integer ARR_SIZE = 50;
    
    private static List<Account> setUpAccounts() {
        //Added MP record type
        string ACCMPRECTYPE='MP Account';
        Id ACCMPRECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACCMPRECTYPE).getRecordTypeId();
        system.debug('ACCMPRECTYPEID ===>'+ACCMPRECTYPEID );
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < ARR_SIZE; i++) {
            accountList.add(new Account(Name=ACCOUNT_PREFIX+i,recordtypeid=ACCMPRECTYPEID));
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
        //Added MP record type
        string OPTYMPRECTYPE='MP Opportunity';
        Id MPRECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPTYMPRECTYPE).getRecordTypeId();
        system.debug('MPRECTYPEID ===>'+MPRECTYPEID );
        List<Account> accountList = setUpAccounts();
        List<Opportunity> oppList = new List<Opportunity>();
        Integer i = 0;
        for (Account anAccount : accountList) {
            oppList.add(new Opportunity(
                Name=OPP_PREFIX+i,
                recordtypeId=MPRECTYPEID,
                AccountId=anAccount.Id,
                CloseDate=Date.today(),
                StageName='Opportunity'
                ));
            i++;
        }
        
        Test.startTest();
        insert oppList;
        for(opportunity opp : oppList){
           opp.StageName='Closed Won';
        }
        update oppList;
        Test.stopTest();
        
        String whereClause = '%'+OPP_PREFIX+'%';
        oppList = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Name LIKE :whereClause];
        for (Opportunity anOpp : oppList) {
            System.assert(anOpp.Primary_Contact__c != null, 'Primary Contact should not be null');
        }
        
    }

}