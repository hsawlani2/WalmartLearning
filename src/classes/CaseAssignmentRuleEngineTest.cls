@isTest
public class CaseAssignmentRuleEngineTest{

    public static testMethod void unitTest(){
        User user = [select Id from User where id !=: UserInfo.getUserId() and IsActive = true and Profile.Name = 'System Administrator' limit 1];
        List<Account> Account1 = new List<account>();
        
        // creating account record ...
        Account acc = new Account(Name='Tes Acc', Type='Seller', Customer_Service_Email__c='test@test.com', Integration_Engineer__c = user.Id);
        Account1.add(acc);
        
        Account acc1 = new Account(Name='Tes Acc1', Type='Channel Partner', Customer_Service_Email__c='test1@test.com', Integration_Engineer__c = user.Id);
         Account1.add(acc1);
        
        
        Account acc2 = new Account(Name='Tes Acc2', Type='Channel Partner', Customer_Service_Email__c='test2@test.com',Seller_Onboarding_Status__c='Seller Setup' ,Seller_Liaison__c = user.Id);
        Account1.add(acc2);
        
        insert Account1;
        
        List<Contact>Contact1 =new List<contact>();
        
        Contact con = new Contact(LastName='Test Con', AccountId=acc.Id, Contact_Type__c = 'Test');
        
        Contact1.add(con);
        
         Contact con1 = new Contact(LastName='Test Con1', AccountId=acc1.Id, Contact_Type__c = 'Test');
        Contact1.add(con1);
        
        Contact con2 = new Contact(LastName='Test Con2', AccountId=acc2.Id, Contact_Type__c = 'Test');
        Contact1.add(con2);
        
        insert Contact1;
        
        // creating custom setting record ...
        Contact_Types__c ct = new Contact_Types__c(Name='Test');
        insert ct;
        
         Entitlement entl = new Entitlement(Name='Onboarding Team', AccountId=acc1.Id,StartDate=Date.valueof(System.now().addDays(-2)), 
        EndDate=Date.valueof(System.now().addYears(2)));
        insert entl;
        
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Onboarding Team' and IsActive = true LIMIT 1];
            if (lstEntitlementProcess.size()>0)
            {
                entl.SlaProcessId = lstEntitlementProcess[0].id;
                update entl;        
            }
        
        String entlId;
        if (entl != null)
        entlId = entl.Id;
        
        test.starttest();
        
        RecordType rt = [select Id from RecordType where Name = 'Seller Community Onboarding Case' and sObjectType = 'Case'];
        
        list<Group> queueList = [select id, Name from Group where Name = 'Seller Community Onboarding Queue'];
        list<case> Case1= new list<Case>();
        Case cse = new Case(AccountId = acc.Id, ContactId = con.Id, RecordTypeId = rt.Id);
        Case1.add(cse);
        //insert cse;
                
        Case cse1 = new Case(AccountId = acc1.Id, ContactId = con1.Id,In_Reference_to_Seller__c =acc.Id, RecordTypeId = rt.Id);
        //Case1.add(cse1);
        insert cse1;
        
        Case cse2 = new Case(AccountId = acc1.Id, ContactId = con1.Id, RecordTypeId = rt.Id);
        Case1.add(cse2);
        // insert cse2;
         
         Insert Case1;      
        CaseAssignmentRuleEngine.runCaseAssignmentRules(cse2);
        
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
         Account acc10 = new Account(Name='Tes Acc10', Type='Seller', Customer_Service_Email__c='test@test.com', Seller_Onboarding_Status__c='Pre Seller Setup' ,Seller_Liaison__c = user.Id);
        insert acc10;
        
        Contact con10 = new Contact(LastName='Test Con', AccountId=acc10.Id, Contact_Type__c = 'Test');
        insert con10;
        
        //list<case> Case2= new list<Case>();
        Case cse10 = new Case(AccountId = acc10.Id, ContactId = con10.Id, RecordTypeId = rt.Id);
        //Case2.add(cse10);
        insert cse10;
        
        test.stoptest();
        
        Case cse6 = new Case(AccountId = acc.Id, ContactId = con.Id, OwnerId = (queueList.size() > 0 ? queueList[0].Id : UserInfo.getUserId()));
        //Case2.add(cse6);
        //insert Case2;
        insert cse6;
        
        //CaseAssignmentRuleEngine.runCaseAssignmentRules(cse6);
    }
    
    public static testMethod void supplierCaseRuleTest(){
        
        Case_Assignment_Rule__c calObj = new Case_Assignment_Rule__c(Issue_category__c='API',Sub_Category_1__c='API Errors',JIRA_Priority__c='P1');
        insert calObj;
        
        Case_Assignment_Owner__c caoObj = new Case_Assignment_Owner__c(Queue_Name__c='Supplier Helpdesk',Case_Assignment_Rule__c=calObj.Id);
        insert caoObj;
        
        Case_Assignment_Rule__c calObj1 = new Case_Assignment_Rule__c(Issue_category__c='API',Sub_Category_1__c='Authentication',JIRA_Priority__c='P1',JIRA_Project__c='ONEPSUPP');
        insert calObj1;
        
        Case_Assignment_Owner__c caoObj1 = new Case_Assignment_Owner__c(Queue_Name__c='Supplier Helpdesk',Case_Assignment_Rule__c=calObj1.Id,DSV_Supplier_Onboarding_Status__c='Onboarding');
        insert caoObj1;
        
        Case_Assignment_Owner__c caoObj2 = new Case_Assignment_Owner__c(Queue_Name__c='Supplier Helpdesk',Case_Assignment_Rule__c=calObj1.Id,DSV_Supplier_Onboarding_Status__c='Operations');
        insert caoObj2;
        
        String profileName = '1P: Buyer Users';
        User u = createTestUser(profileName);
        System.runAs(u){
        
        List<Account> accList = TestUtilityClass.createAccount(1);
        
        List<Contact> conList = TestUtilityClass.createContact(1,accList[0].Id);
        
        RUN_SUPPLIER_CASE_ASSIGNMENT_RULE__c rsca = new RUN_SUPPLIER_CASE_ASSIGNMENT_RULE__c(Name='1P: Buyer Users');
        insert rsca;
        
        Id recId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Supplier Open Case').getRecordTypeId();
        //List<Case> caseList = TestUtilityClass.createSupplierCase(accList[0].Id,conList[0].Id,recId,1);
        List<Case> caseList = new List<Case>();
        Case cse = new Case(AccountId = accList[0].Id, ContactId = conList[0].Id, RecordTypeId = recId,
                            Issue_Category__c='API',Sub_Category_1__c='API Errors');
        caseList.add(cse);
        Case cse1 = new Case(AccountId = accList[0].Id, ContactId = conList[0].Id, RecordTypeId = recId,
                            Issue_Category__c='API',Sub_Category_1__c='Authentication');
        caseList.add(cse1);
        
        insert caseList;
        
        CaseAssignmentRuleEngine.runSupplierCaseAssignmentRules(caseList[0]);
        CaseAssignmentRuleEngine.runSupplierCaseAssignmentRules(caseList[1]);
    }
    }
    
    private static User createTestUser(String profileName) {
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', Username = 'User' + Math.random()*100 + '@test.com'
                );
            
        return u;
    }
}