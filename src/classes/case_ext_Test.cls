@isTest
(seeAllData=false)
public class case_ext_Test{
 static testMethod void caseReopen() {
        
        Test.startTest();
        Account accObj = TestUtilityClass.createAccount();
        
        Contact tempCon = new Contact(LastName = 'XYXTest',AccountId = accObj.Id);
        insert tempCon;
        list<Case> caseList = new List<Case>();
        Case c = new Case(ContactId = tempCon.Id,AccountId=accObj.Id);
        insert c;
        system.debug('..case idsss.. '+c);
        
        JIRA_CONFIG__c jiraObj = new JIRA_CONFIG__c(name='CONFIG',UserName__c='abc',Password__c='test',URL__c='test.com');
        insert jiraObj;
        
        Test.setCurrentPageReference(new PageReference('Page.reopen')); 
        System.currentPageReference().getParameters().put('id', c.Id);
        
        ApexPages.StandardController sc = new ApexPages.standardController(c);
        
        case_ext caseExt = new case_ext(sc);
        
        caseExt.validateComment();
        caseExt.saveReopen();
        caseExt.cancelReopen();
        
        CaseComment CC = new CaseComment(CommentBody='comment body',ParentId=c.Id);
        insert CC;
        Test.stopTest();
    }

}