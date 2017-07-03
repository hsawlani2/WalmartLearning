@isTest
public class CaseOwnerUpdateBatchTest{

    public static testMethod void unitTest(){
        User user = [select Id from User where id !=: UserInfo.getUserId() and IsActive = true and Profile.Name = 'System Administrator' limit 1];
        
        // creating account record ...
        Account acc = new Account(Name='Tes Acc', Type='Seller', Customer_Service_Email__c='test@test.com', Integration_Engineer__c = user.Id);
        insert acc;
        
        Contact con = new Contact(LastName='Test Con', AccountId=acc.Id, Contact_Type__c = 'Test');
        insert con;
        
        // creating custom setting record ...
        Contact_Types__c ct = new Contact_Types__c(Name='Test');
        insert ct;
        
        RecordType rt = [select Id from RecordType where Name = 'Seller Community Onboarding Case' and sObjectType = 'Case'];
        
        list<Group> queueList = [select id, Name from Group where Name = 'Seller Community Onboarding Queue'];
        
        Case cse = new Case(AccountId = acc.Id, ContactId = con.Id, RecordTypeId = rt.Id, OwnerId = (queueList.size() > 0 ? queueList[0].Id : UserInfo.getUserId()));
        insert cse;
        
        cse.OwnerId = (queueList.size() > 0 ? queueList[0].Id : UserInfo.getUserId());
        update cse;
        
        string CRON_EXP = '0 0 0 15 3 ? 2022';
        System.schedule('CaseOwnerUpdateBatchSchedulable',
                         CRON_EXP, 
                         new CaseOwnerUpdateBatchSchedulable());
        
        Test.startTest();
        
        Id batchJobId = Database.executeBatch(new CaseOwnerUpdateBatch(), 10);
        
        Test.stopTest();
    }
}