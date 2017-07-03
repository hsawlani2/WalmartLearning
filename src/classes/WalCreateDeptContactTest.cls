/**
 * @author          Krishan Gopal
 * @version         1.0
 * @date            05/18/2016
 * @description     Test class for WalCreateDeptContact
 */
@isTest
private class WalCreateDeptContactTest{
    /**
     * @description       
     * @param             NA
     * @return            Na
     */
    static testMethod void CreateDeptContact(){
        
        User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
        String deptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Department__c' and Developername = 'MP_Department'].Id;
        //String accRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Developername = 'MP_Account'].Id;
        String accRecordTypeId = '';
        
        system.runAs(admin) {
             Account guest = new Account();
             guest.Name='Guest';
             //guest.RecordTypeId=accRecordTypeId;
             Database.Insert(guest);
             
             
             Account guest1 = new Account();
             guest1.Name='Guest1';
             //guest1.RecordTypeId=accRecordTypeId;
             Database.Insert(guest1);
             
             Contact testContact = new Contact();
             testContact.LastName='Con';
             testContact.AccountId=guest.id;
             testContact.email = 'Test@test1.com';
             testContact.Contact_Type__c='Marketplace Business Manager';
             Database.Insert(testContact);
             
             Contact testContact1 = new Contact();
             testContact1.LastName='Con1';
             testContact1.AccountId=guest1.id;
             testContact1.email = 'Test@test.com';
             Database.Insert(testContact1);
               
             Department__c deptObj = new Department__c();
             deptObj.Name='Test';
             deptObj.RecordTypeId=deptRecordTypeId;
             Database.Insert(deptObj);
             
             wal_Performance_Snapshot__c snapShotObj = new wal_Performance_Snapshot__c();
             snapShotObj.wal_Account__c=guest.id;
             snapShotObj.wal_Department__c=deptObj.id;
             snapShotObj.wal_Snapshot_Date__c=system.today().addDays(-1);
             Database.insert(snapShotObj);
             
             wal_Performance_Snapshot__c snapShotObj1 = new wal_Performance_Snapshot__c();
             snapShotObj.wal_Account__c=guest1.id;
             snapShotObj.wal_Department__c=deptObj.id;
             snapShotObj.wal_Snapshot_Date__c=system.today().addDays(-1);
             Database.insert(snapShotObj1);
            
             Test.startTest();
                    WalCreateDeptContact DeptContact = new WalCreateDeptContact();
                    Database.executeBatch(DeptContact);
             Test.stopTest();
        }
        
  
    }
    /*test Method*/
    static testmethod void testschedule() {
        User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
        Test.StartTest();
        system.RunAs(admin){
            WalCreateDeptContactScheduler sh1 = new WalCreateDeptContactScheduler();      
            String sch = '0 0 23 * * ?';
            system.schedule('TestScheduleApexClass', sch, sh1);
        }
        Test.stopTest();
    }
}