@isTest
public class PerformanceSnapshotTest{

    static testMethod void PerformanceSnapshot(){
        
        Test.StartTest();
        
        Id mPAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MP Account').getRecordTypeId();

        Account acc = TestUtilityClass.createAccount();   
        acc.recordtypeId  =  mPAccountRecordTypeId ;
        update acc;
        
        Id mPdepartmentRecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByName().get('MP Department').getRecordTypeId();
        
        List<Department__c> dep = TestUtilityClass.createDepartment(1);
        dep[0].recordtypeId  = mPdepartmentRecordTypeId;
        update dep[0];
         
        wal_Performance_Snapshot__c   per  = TestUtilityClass.createPerformancesnapshot(acc.Id,dep[0].Id);
        PerformanceSnapshot per1 = new PerformanceSnapshot ();         
        Database.executeBatch(per1);
        
        Test.StopTest();
}
        
         /*test Method*/
        static testmethod void testschedule() {
            Test.StartTest();
                PerformanceSnapshotSchedular sh1 = new PerformanceSnapshotSchedular();      
                String sch = '0 0 23 * * ?';
                system.schedule('TestScheduleApexClass', sch, sh1);
            Test.stopTest();
        }

}