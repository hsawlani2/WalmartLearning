@isTest
public class TestUtilityClass{
    public static List<Account> createAccount(Integer numAcc) {
        List<Account> accList = new List<Account>();
        recordtype rec = [select id from recordtype where name =: '1P Account' AND sObjectType =: 'Account'];
        //Id recId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('X1P_Account').getRecordTypeId();
        for(Integer i=0;i<numAcc;i++){
            Account tempAcc = new Account(Name = 'TestfName'+i, RecordTypeId = rec.Id );
            accList.add(tempAcc);
        }
        insert accList;
        return accList;
        
    }
    
    public static List<Contact> createContact(Integer numAcc,Id accId) {
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<numAcc;i++){
            Contact tempAcc = new Contact(AccountId=accId,LastName='LastName'+i);
            conList.add(tempAcc);
        }
        insert conList;
        return conList;
        
        
    }

    
    public static wal_Performance_Snapshot__c createPerformancesnapshot(Id accId,Id depId){
        wal_Performance_Snapshot__c walpList = new wal_Performance_Snapshot__c(wal_Account__c= accId,wal_Department__c=depId);
         
        insert walpList;
        return walpList;
    }
    public static Account createAccount() {
        recordtype rec = [select id from recordtype where name =: '1P Account' AND sObjectType =: 'Account'];
        //Id recId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('X1P_Account').getRecordTypeId();
        Account tempAcc = new Account(Name = 'XYXTest', RecordTypeId = rec.Id );
        insert tempAcc;
        return tempAcc;
    }
    
    public static List<Department__c> createDepartment(Integer numAcc) {
        List<Department__c> depList = new List<Department__c>();
        recordtype rec = [select id from recordtype where name=: '1P Department' AND sObjectType =: 'Department__c' limit 1];
        for(Integer i=0;i<numAcc;i++){
            Department__c tempDep = new Department__c(Name = 'TestDep', RecordTypeId = rec.id );
            depList.add(tempDep);
        }
        insert depList;
        return depList;
    }
    
    public static Account_Department__c createAccDepartment(Id accId, Id depId) {
        recordtype rec = [select id from recordtype where name=: '1P Account-Department' AND sObjectType =: 'Account_Department__c' limit 1];
        Account_Department__c tempAccDep = new Account_Department__c(Name = 'TestAccDep', Wal_Department__c = depId, Wal_Account__c = accId,  RecordTypeId = rec.id );
        insert tempAccDep;
        return tempAccDep;
    }
    
    public static Contract__c createAccContract(Id accdepId, String type) {
        recordtype rec = [select id from recordtype where name=: '1P Contract' AND sObjectType =: 'Contract__c' limit 1];
        Contract__c tempAccCon = new Contract__c(Name = 'TestAccCon', Account_Department_ID__c = accdepId, RecordTypeId = rec.Id, Contract_Type__c = type);
        insert tempAccCon;
        return tempAccCon;
    }
    
    public static User createUsers() { 
        profile pro = [SELECT Id from Profile where Name = 'System Administrator' limit 1];
        UserRole role = [SELECT Id from UserRole where Name = 'BD Director' limit 1];
        User users = new User(Username = 'Test190215@kay.com', Email = 'TestUser@kay.com',
                              FirstName = 'TestU',LastName = 'testLName', Alias='tet',CommunityNickname = 'tetuser',emailencodingkey = 'UTF-8',
                              localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                              profileId = pro.id, userRoleId = role.Id);
        User users1 = [select id from user where alias = 'wsyst' limit 1];
        system.assert(users!=null);
        system.RunAs(users1){                     
            insert users;
        }
        return users;
    }
    
    
    public static Opportunity createOpp(Id accId, String type, Id accDepId) {
        recordtype rec = [select id from recordtype where name=: '1P Opportunity' AND sObjectType =: 'Opportunity' limit 1];
        Opportunity tempopp = new Opportunity(Name = 'TestOpp', Opportunity_Type__c = type, RecordTypeId = rec.Id, AccountId = accId, Wal_Account_Department__c = accDepId, StageName='Awaiting Contract', CloseDate = Date.Today());
        insert tempopp;
        return tempopp;
    }
    
    public static Opportunity createOpp(Id accId, String type, Id accDepId, Id userId) {
        recordtype rec = [select id from recordtype where name=: '1P Opportunity' AND sObjectType =: 'Opportunity' limit 1];
        Opportunity tempopp = new Opportunity(Name = 'TestOpp', Opportunity_Type__c = type, RecordTypeId = rec.Id, AccountId = accId, Wal_Account_Department__c = accDepId, StageName='Awaiting Contract', CloseDate = Date.Today(), Buyer2__c= userId);
        insert tempopp;
        return tempopp;
    }
    
    public static RHID__c createRHID(Id userId) {
        RHID__c tempRHID = new RHID__c( RHID__c = 'RH',Name='text', Buyer2__c= userID);
        insert tempRHID ;
        return tempRHID ;
    }   
    
    public static Account_RHID__c createAccount_RHID(Id accId, Id RHIDid){
        Account_RHID__c tempaccRHID = new Account_RHID__c(Account__c = accId, RHID_Name__c = RHIDid);
        insert tempaccRHID ;
        return tempaccRHID ;
    } 
    
    public static Buyer__c createBuyer() {
        Buyer__c Buyers = new Buyer__c(Name = 'Test');
        insert Buyers;
        return Buyers;
    }
    
    public static List<Case> createSupplierCase(Id accId,Id conId,Id recordTypeId,integer numOfCase) {
        List<Case> caseList = new List<Case>();
        for(Integer i=0;i<numOfCase;i++){
            Case cse = new Case(AccountId = accId, ContactId = conId, RecordTypeId = recordTypeId);
            caseList.add(cse);
        }
        
        insert caseList;
        return caseList;
    }
}