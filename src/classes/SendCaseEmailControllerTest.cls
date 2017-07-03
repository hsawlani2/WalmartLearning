@isTest
public class SendCaseEmailControllerTest{

    public static testMethod void unitTest(){
        
        // creating account record ...
        Account acc = new Account(Name='Tes Acc', 
                                  Type='Seller',
                                  Customer_Service_Email__c='test@test.com',
                                  Seller_Onboarding_Status__c = 'Live on Site',
                                  Seller_Onboarding_Live_Status__c = 'Launched',
                                  Platform__c = 'GMP',
                                  RecordTypeId = [select id from RecordType where DeveloperName = 'MP_Account' limit 1].Id);
        insert acc;
        
        Contact con = new Contact(LastName='Test Con',AccountId=acc.Id, Email = 'test@test.com');
        insert con;
        
        // creating custom setting record ...
        Contact_Types__c ct = new Contact_Types__c(Name='Test');
        insert ct;
        
        RecordType rt = [select Id from RecordType where Name = 'Seller Community Onboarding Case' and sObjectType = 'Case'];
        
        list<Group> queueList = [select id, Name from Group where Name = 'Seller Community Onboarding Queue'];
        
        Case cse = new Case(AccountId = acc.Id, ContactId = con.Id, RecordTypeId = rt.Id, OwnerId = (queueList.size() > 0 ? queueList[0].Id : UserInfo.getUserId()));
        insert cse;
        
        ApexPages.standardController sc = new ApexPages.standardController(cse);
        SendCaseEmailController obj = new SendCaseEmailController(sc);
        
        obj.showHideEmail();
        obj.showHideArticle();
        obj.showHideBcc();
        obj.attachment = null;
        obj.getEmailTemplates();
        obj.send();
        obj.cancel();
        
        obj.templateId = [select id from EmailTemplate limit 1].Id;
        obj.populateTemplate();
        
        obj.getPrevRequired();
        obj.getNextRequired();
        obj.getCurrentPageNumber();
        obj.next();
        obj.previous();
        
        obj.articleId = 'test';
        obj.articleName = 'test';
        obj.addArticle();
        obj.emailMsg.CcAddress = 'test@test.com';
        obj.addlRecipients = 'test@test.com';
        obj.send();
        
        obj.removeIndex = 0;
        obj.removeArticle();
    }
}