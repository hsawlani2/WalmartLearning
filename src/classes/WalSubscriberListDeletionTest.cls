/**
 * Walmart
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            7/9/2016
 */
@isTest
Private class WalSubscriberListDeletionTest{
    /*test Method*/
    static testMethod void testBatch() {
        User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account'); 
        database.insert(testAccount);
        List <Subscriber_List__c> scratchnotes = new List<Subscriber_List__c>();
        Subscriber_List__c testsubs = new Subscriber_List__c();
        testsubs.Account_Name__c = 'Test Account';
        testsubs.Contact_ID__c = '1234';
        testsubs.Contact_Name__c = 'Test Contact';
        testsubs.Department_Name__c = 'Test Department';
        testsubs.Department_Number__c = '123456';
        testsubs.Contact_Email__c = 'test@mail.com';
        insert testsubs;
        Test.StartTest();
        WalSubscriberListDeletion rc = new WalSubscriberListDeletion();
        system.RunAs(admin){
            Database.executeBatch(rc);
        }
        Test.StopTest();                    
    }
    /*test Method*/
    static testmethod void testschedule() {
    User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
        Test.StartTest();
        system.RunAs(admin){
            WalSubscriberListDeletionScheduler sh1 = new WalSubscriberListDeletionScheduler();      
        
        String sch = '0 0 23 * * ?';
        system.schedule('ScheduleApexClassTest', sch, sh1);
        }
        Test.stopTest();
    }
}