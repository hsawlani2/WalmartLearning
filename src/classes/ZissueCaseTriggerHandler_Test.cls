@isTest

Private class ZissueCaseTriggerHandler_Test{
        static testMethod void test(){
        RecordType rt = [Select id,developerName from RecordType where sObjectType='Case' And developerName ='Seller_Community_Case'];
       
        //RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Wal_MP_Account'];
        Account acc1 = new Account();
        acc1.Name = 'TestAcc1';
        //acc1.RecordTypeId = rt1.id;
        insert acc1;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc1.id;
        insert con;
         test.startTest();
        Case ca = new Case();
        ca.Status = 'New';
        ca.AccountId= acc1.Id;
        ca.ContactId = con.Id;
        ca.RecordTypeId = rt.Id;
        
        insert ca;
        
        zsfjira__ZIssue__c zissue = new zsfjira__ZIssue__c();
        zissue.Name='Test';
        zissue.zsfjira__IssueKey__c='Test';
        zissue.zsfjira__IssueId__c=1231233221;
        insert zissue;
        
        zsfjira__ZIssue_Case__c issuecase = new zsfjira__ZIssue_Case__c ();
        issuecase.Name = '000012321-655936';
        issuecase.zsfjira__CaseId__c =ca.id;
        issuecase.zsfjira__ZIssueId__c=zissue.id;
        insert issuecase;
        test.stoptest();
        
        }



}