/*
    @Author             : Rayson Landeta (CloudSherpas)
    @Date Created       : 6-JAN-2016
    @Description        : Data builder class. Pre-defined class to be used in test classes.
*/

@isTest
public with sharing class DataBuilder {
    
    //Returns Account
    public static Account createAccount(){
        Account myAccount = new Account(
            Name = 'Walmart Test Account'
        );
        myAccount.RecordType.DeveloperName='MP_Account';
        return myAccount; 
    }
    
    public static Account createAccount(String acctName){
        recordtype rec = [select id from recordtype where name =: 'MP Account' AND sObjectType =: 'Account'];
        Account myAccount = new Account(
            Name = acctName,
            recordTypeId = rec.Id
        );
        return myAccount; 
    }

    //Returns Opportunity 
    public static Opportunity createOpportunity(Id accId){ 
        Opportunity myOpp = new Opportunity(
            Name = 'Walmart Test Opportunity',
            CloseDate = System.today() + 30,
            StageName = 'Opportunity',
            AccountId = accId
        );
        myOpp.RecordType.DeveloperName='MP_Opportunity';
        return myOpp;
    }
    
    public static Contact createContact(Id accId) {
        Contact myContact = new Contact(
            FirstName = 'First',
            LastName = 'Second',
            Phone = '+123123211',
            Email = 'first@cloudsherpas.com',
            AccountId = accId
        );
        return myContact;
    }
    
    //Returns Application
    public static Application__c createApplication(Id accId, Id oppId){ 
        Application__c myApp = new Application__c(
            Account__c = accId,
            Opportunity__c = oppId,
            Primary_Contact_First_Name__c = 'TestName',
            Primary_Contact_Last_Name__c = 'TestLastName',
            Primary_Contact_Email__c = 'Test@mail.com',
            Legal_Company_Name__c = 'Test Company'
        );
        return myApp;
    }
    
    public static List<Category__c> createCategoryList() {
        List<Category__c> categories = new List<Category__c>();
        for(Integer i=0;i<20;i++) {
            Category__c cat = new Category__c(Name ='TestCategory' + i,
                            Customer_Rating_Acceptable_Threshold__c = 90,
                            Drop_Ship_Acceptable_Threshold__c = 50,
                            Active__c = true,
                            Custom_Naming__c = false,
                            Sort_Order__c = 999
                );
            categories.add(cat);
        }
        // create the 'other category'
        Category__c otherCat = new Category__c(Name ='Other',
                            Customer_Rating_Acceptable_Threshold__c = 90,
                            Drop_Ship_Acceptable_Threshold__c = 50,
                            Active__c = true,
                            Custom_Naming__c = true,
                            Sort_Order__c = 999);
        categories.add(otherCat);                            
                            
        insert categories;
        return categories;
    }
    
    public static Account createAcc() {
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
}