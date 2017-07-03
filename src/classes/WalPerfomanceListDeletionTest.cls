/**
 * Walmart
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            7/9/2016
 */
@isTest
Private class WalPerfomanceListDeletionTest{
    /*test Method*/
    static testMethod void testBatch() {
        User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account'); 
        database.insert(testAccount);
        List <wal_Performance_Snapshot__c> scratchnotes = new List<wal_Performance_Snapshot__c>();
        wal_Performance_Snapshot__c testsnaps = new wal_Performance_Snapshot__c();
        testsnaps.wal_Snapshot_Date__c = Date.Today().addDays(-6);
        insert testsnaps;
        Test.StartTest();
        WalPerfomanceListDeletion rc = new WalPerfomanceListDeletion();
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
            WalPerfomanceListDeletionScheduler sh1 = new WalPerfomanceListDeletionScheduler();      
        
        String sch = '0 0 23 * * ?';
        system.schedule('ScheduleApexClassTest', sch, sh1);
        }
        Test.stopTest();
    }
}