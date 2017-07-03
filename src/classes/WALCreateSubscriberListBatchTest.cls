/**
 * @author          Accenture IDC
 * @version         1.0
 * @date            05/18/2016
 * @description     Test class for WALCreateSubscriberListBatch
 */
@isTest
private class WALCreateSubscriberListBatchTest{
    /**
     * @description       
     * @param             NA
     * @return            Na
     */
    static testMethod void WALCreateSubscriberListBatch1(){
            //Adding custom setting
             Setting_1P_3P__c setting3P=new Setting_1P_3P__c();
             setting3P.SetupOwnerId=UserInfo.getOrganizationId();
             setting3P.Global_GMV__c=10;
             setting3P.Snapshot_Date__c=1;
             setting3P.Trend_Date__c=2;
             insert setting3P;
            User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
            List<sObject> ls1 = Test.loadData(wal_Performance_Rule__c.sObjectType, 'PerformanceRule');
            String RecordTypeId = [Select Id From RecordType Where SobjectType = 'Department_Contact__c' and Developername = 'MP_Department_Contact'].Id;
            String deptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Department__c' and Developername = 'MP_Department'].Id;
            String accdeptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account_Department__c' and Developername = 'MP_Account_Department'].Id;
            String accRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Developername = 'MP_Account'].Id;
            //String accRecordTypeId = '';
            
            system.runAs(admin) {
            Account guest = new Account();
            guest.Name = 'Test';
            guest.Live_Date__c=system.now().addDays(-90);
            guest.Category__c='Baby';
            guest.Tier__c='2';
            guest.RecordTypeId=accRecordTypeId;
            guest.Amazon_No_of_Active_SKUs__c=50;
            guest.Ebay_No_of_Active_SKUs__c=100;
            guest.Other_No_of_Active_SKUs__c=500;
            Database.Insert(guest);
            
            Contact testContact = new Contact();
            testContact.Account =Guest;
            testContact.LastName = 'TestLast';
            testContact.email = 'Test@test.com';
            Database.insert(testContact );
            
            Department__c deptObj = new Department__c();
            deptObj.Wal_Department_Owner__c=UserInfo.getUserId();
            deptObj.RecordTypeId=deptRecordTypeId;
            Database.insert(deptObj);
            
            Account_Department__c accDeptObj = new Account_Department__c();
            accDeptObj.Wal_Account__c=Guest.id;
            accDeptObj.Wal_Department__c=deptObj.id;
            accDeptObj.RecordTypeId=accdeptRecordTypeId;
            Database.insert(accDeptObj);
            
            WAL_Threshold__c thresholdObj = new WAL_Threshold__c();
            thresholdObj.WAL_Account__c = Guest.id;
            thresholdObj.WAL_Department__c =deptObj.id;
            thresholdObj.On_Time_Ship_Acute_Buffer__c=0.5;
            thresholdObj.On_Time_Ship_Chronic_Threshold__c=0.5;
            thresholdObj.Cancellation_Rate_Acute_Buffer__c=0.5;
            thresholdObj.Cancellation_Rate_Chronic_Threshold__c=0.5;
            thresholdObj.WAL_Refund_Rate_Buffer__c=0.5;
            thresholdObj.Catalog_SKUs_Threshold__c=0.5;
            thresholdObj.WAL_Price_Leadership_Parity_Threshold__c=0.5;
            Database.insert(thresholdObj); 
            
            wal_Performance_Snapshot__c snapshotObj = new wal_Performance_Snapshot__c();
            snapshotObj.WAL_Account__c = Guest.id;
            snapshotObj.WAL_Department__c =deptObj.id;
            snapshotObj.wal_Snapshot_Date__c=Date.today().addDays(-1);
            snapshotObj.DEPT_Buyable_SKUs_STDev_30d__c=5;
            snapshotObj.DEPT_Buyable_SKUs_Last_14d__c=4;
            snapshotObj.SLR_On_Time_Ship_Prev_Day__c=5;
            snapshotObj.SLR_On_Time_Ship_Last_7d__c=5;
            snapshotObj.SLR_Cancel_Rate_Prev_Day__c=5;
            snapshotObj.SLR_Cancel_Rate_Last_7d__c=5;
            //snapshotObj.wal_Return_Rate_Last_7d__c=5;
            snapshotObj.DEPT_Buyable_SKUs_Prev_Day__c=20;
            snapshotObj.SLR_Pub_SKUs_Prev_Day__c=20;
            snapshotObj.DEPT_Price_Ld_Par_Last_7d__c=2;
            snapshotObj.DEPT_Out_of_Stock_Last_14d__c=2;
            //snapshotObj.wal_Return_Rate_Last_30d__c=2;
            snapshotObj.DEPT_Out_of_Stock_Prev_Day__c=2;
            snapshotObj.DEPT_Out_of_Stock_STDev_30d__c=2;
            snapshotObj.DEPT_Pub_SKUs_Last_7d__c=2;
            snapshotObj.DEPT_GMV_STDev_30d__c=50;
            snapshotObj.DEPT_GMV_Last_14d__c=5;
            snapshotObj.DEPT_GMV_Last_30d__c=30;
            snapshotObj.DEPT_GMV_Last_3d__c=30;
            snapshotObj.DEPT_GMV_Last_7d__c=30;
            snapshotObj.DEPT_GMV_Prev_Day__c=30;
            snapshotObj.SLR_GMV_STDev_30d__c=50;
            snapshotObj.SLR_GMV_Last_14d__c=5;
            snapshotObj.SLR_GMV_Last_30d__c=30;
            snapshotObj.SLR_GMV_Last_3d__c=30;
            snapshotObj.SLR_GMV_Last_7d__c=30;
            snapshotObj.SLR_GMV_Prev_Day__c=10;
            snapshotObj.SLR_Refund_Rate_Last_7d__c=1;
            snapshotObj.SLR_Refund_Rate_Last_30d__c=2;
            snapshotObj.DEPT_Pub_SKUs_Prev_Day__c=3;
            Database.insert(snapshotObj); 
            
            wal_Performance_Snapshot__c snapshotObj1 = new wal_Performance_Snapshot__c();
            snapshotObj1.WAL_Account__c = Guest.id;
            snapshotObj1.WAL_Department__c =deptObj.id;
            snapshotObj1.wal_Snapshot_Date__c=Date.Today().addDays(-2);
            snapshotObj1.DEPT_Buyable_SKUs_STDev_30d__c=5;
            snapshotObj1.DEPT_Buyable_SKUs_Last_14d__c=4;
            snapshotObj1.SLR_On_Time_Ship_Prev_Day__c=5;
            snapshotObj1.SLR_On_Time_Ship_Last_7d__c=5;
            snapshotObj1.SLR_Cancel_Rate_Prev_Day__c=5;
            snapshotObj1.SLR_Cancel_Rate_Last_7d__c=5;
            //snapshotObj1.wal_Return_Rate_Last_7d__c=5;
            snapshotObj1.DEPT_Buyable_SKUs_Prev_Day__c=20;
            snapshotObj1.SLR_Pub_SKUs_Prev_Day__c=20;
            snapshotObj1.DEPT_Price_Ld_Par_Last_7d__c=2;
            snapshotObj1.DEPT_Out_of_Stock_Prev_Day__c=2;
            //snapshotObj1.wal_Return_Rate_Last_30d__c=2;
            snapshotObj1.DEPT_Out_of_Stock_STDev_30d__c=2;
            snapshotObj1.DEPT_Out_of_Stock_Last_14d__c=2;
            snapshotObj1.DEPT_GMV_STDev_30d__c=50;
            snapshotObj1.DEPT_GMV_Last_14d__c=5;
            snapshotObj1.DEPT_GMV_Last_30d__c=30;
            snapshotObj1.DEPT_GMV_Last_3d__c=30;
            snapshotObj1.DEPT_GMV_Last_7d__c=30;
            snapshotObj1.DEPT_GMV_Prev_Day__c=30;
            snapshotObj1.SLR_GMV_STDev_30d__c=50;
            snapshotObj1.SLR_GMV_Last_14d__c=5;
            snapshotObj1.SLR_GMV_Last_30d__c=30;
            snapshotObj1.SLR_GMV_Last_3d__c=30;
            snapshotObj1.SLR_GMV_Last_7d__c=30;
            snapshotObj1.SLR_GMV_Prev_Day__c=10;
            snapshotObj1.SLR_Refund_Rate_Last_7d__c=2;
            snapshotObj1.SLR_Refund_Rate_Last_30d__c=1;
            snapshotObj1.DEPT_Pub_SKUs_Last_7d__c=2;
            snapshotObj1.DEPT_Pub_SKUs_Prev_Day__c=3;
            Database.insert(snapshotObj1); 
                    
            Department_Contact__c deptConObj = new Department_Contact__c();
            deptConObj.Account__c = guest.id;
            deptConObj.Wal_Contact__c= testContact.id;
            deptConObj.Wal_Account_Department__c=accDeptObj.id;
            deptConObj.RecordTypeId=RecordTypeId;
            Database.Insert(deptConObj);
           
           
            Test.startTest();
            WALCreateSubscriberListBatch batchWALCreateSubscriberList = new WALCreateSubscriberListBatch();
            Database.executeBatch(batchWALCreateSubscriberList);
            Test.stopTest();
            }
       
        }
        
     /**
     * @description       
     * @param             NA
     * @return            Na
     */
    static testMethod void WALCreateSubscriberListBatch2(){
            //Adding custom setting
            Setting_1P_3P__c setting3P=new Setting_1P_3P__c();
            setting3P.SetupOwnerId=UserInfo.getOrganizationId();
            setting3P.Global_GMV__c=10;
            setting3P.Snapshot_Date__c=1;
             setting3P.Trend_Date__c=2;
            insert setting3P;
            User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
            List<sObject> ls1 = Test.loadData(wal_Performance_Rule__c.sObjectType, 'PerformanceRule');
            String RecordTypeId = [Select Id From RecordType Where SobjectType = 'Department_Contact__c' and Developername = 'MP_Department_Contact'].Id;
            String deptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Department__c' and Developername = 'MP_Department'].Id;
            String accdeptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account_Department__c' and Developername = 'MP_Account_Department'].Id;
            String accRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Developername = 'MP_Account'].Id;
            //String accRecordTypeId = '';
            
            system.runAs(admin) {
            Account guest = new Account();
            guest.Name = 'Test';
            guest.Live_Date__c=system.now().addDays(-35);
            guest.Category__c='Baby';
            guest.Tier__c='1';
            guest.RecordTypeId=accRecordTypeId;
            guest.Amazon_No_of_Active_SKUs__c=50;
            guest.Ebay_No_of_Active_SKUs__c=100;
            guest.Other_No_of_Active_SKUs__c=500;
            Database.Insert(guest);
            
            Contact testContact = new Contact();
            testContact .Account =Guest;
            testContact .LastName = 'TestLast';
            testContact.email = 'Test@test.com';
            Database.insert(testContact );
            
            Department__c deptObj = new Department__c();
            deptObj.Wal_Department_Owner__c=UserInfo.getUserId();
            deptObj.RecordTypeId=deptRecordTypeId;
            Database.insert(deptObj);
            
            Account_Department__c accDeptObj = new Account_Department__c();
            accDeptObj.Wal_Account__c=Guest.id;
            accDeptObj.Wal_Department__c=deptObj.id;
            accDeptObj.RecordTypeId=accdeptRecordTypeId;
            Database.insert(accDeptObj);
            
            WAL_Threshold__c thresholdObj = new WAL_Threshold__c();
            thresholdObj.WAL_Account__c = Guest.id;
            thresholdObj.WAL_Department__c =deptObj.id;
            thresholdObj.On_Time_Ship_Acute_Buffer__c=0.5;
            thresholdObj.On_Time_Ship_Chronic_Threshold__c=0.5;
            thresholdObj.Cancellation_Rate_Acute_Buffer__c=0.5;
            thresholdObj.Cancellation_Rate_Chronic_Threshold__c=0.5;
            thresholdObj.WAL_Refund_Rate_Buffer__c=0.5;
            thresholdObj.Catalog_SKUs_Threshold__c=0.5;
            thresholdObj.WAL_Price_Leadership_Parity_Threshold__c=0.5;
            Database.insert(thresholdObj); 
            
            wal_Performance_Snapshot__c snapshotObj = new wal_Performance_Snapshot__c();
            snapshotObj.WAL_Account__c = Guest.id;
            snapshotObj.WAL_Department__c =deptObj.id;
            snapshotObj.wal_Snapshot_Date__c=Date.today().addDays(-1);
            snapshotObj.DEPT_Buyable_SKUs_STDev_30d__c=5;
            snapshotObj.DEPT_Buyable_SKUs_Last_14d__c=4;
            snapshotObj.SLR_On_Time_Ship_Prev_Day__c=5;
            snapshotObj.SLR_On_Time_Ship_Last_7d__c=5;
            snapshotObj.SLR_Cancel_Rate_Prev_Day__c=5;
            snapshotObj.SLR_Cancel_Rate_Last_7d__c=5;
            //snapshotObj.wal_Return_Rate_Last_7d__c=5;
            snapshotObj.DEPT_Buyable_SKUs_Prev_Day__c=20;
            snapshotObj.SLR_Pub_SKUs_Prev_Day__c=20;
            snapshotObj.DEPT_Price_Ld_Par_Last_7d__c=2;
            snapshotObj.DEPT_Out_of_Stock_Last_14d__c=2;
            //snapshotObj.wal_Return_Rate_Last_30d__c=2;
            snapshotObj.DEPT_Out_of_Stock_Prev_Day__c=2;
            snapshotObj.DEPT_Out_of_Stock_STDev_30d__c=2;
            snapshotObj.DEPT_GMV_STDev_30d__c=50;
            snapshotObj.DEPT_GMV_Last_14d__c=5;
            snapshotObj.DEPT_GMV_Last_30d__c=30;
            snapshotObj.DEPT_GMV_Last_3d__c=30;
            snapshotObj.DEPT_GMV_Last_7d__c=30;
            snapshotObj.DEPT_GMV_Prev_Day__c=30;
            snapshotObj.SLR_GMV_STDev_30d__c=50;
            snapshotObj.SLR_GMV_Last_14d__c=5;
            snapshotObj.SLR_GMV_Last_30d__c=30;
            snapshotObj.SLR_GMV_Last_3d__c=30;
            snapshotObj.SLR_GMV_Last_7d__c=30;
            snapshotObj.SLR_GMV_Prev_Day__c=10;
            snapshotObj.SLR_Refund_Rate_Last_7d__c=2;
            snapshotObj.SLR_Refund_Rate_Last_30d__c=1;
            snapshotObj.DEPT_Pub_SKUs_Last_7d__c=2;
            snapshotObj.DEPT_Pub_SKUs_Prev_Day__c=3;
            Database.insert(snapshotObj); 
            
            wal_Performance_Snapshot__c snapshotObj1 = new wal_Performance_Snapshot__c();
            snapshotObj1.WAL_Account__c = Guest.id;
            snapshotObj1.WAL_Department__c =deptObj.id;
            snapshotObj1.wal_Snapshot_Date__c=Date.Today().addDays(-2);
            snapshotObj1.DEPT_Buyable_SKUs_STDev_30d__c=5;
            snapshotObj1.DEPT_Buyable_SKUs_Last_14d__c=4;
            snapshotObj1.SLR_On_Time_Ship_Prev_Day__c=5;
            snapshotObj1.SLR_On_Time_Ship_Last_7d__c=5;
            snapshotObj1.SLR_Cancel_Rate_Prev_Day__c=5;
            snapshotObj1.SLR_Cancel_Rate_Last_7d__c=5;
            snapshotObj1.DEPT_Out_of_Stock_Last_14d__c=2;
            //snapshotObj1.wal_Return_Rate_Last_7d__c=5;
            snapshotObj1.DEPT_Buyable_SKUs_Prev_Day__c=20;
            snapshotObj1.SLR_Pub_SKUs_Prev_Day__c=20;
            snapshotObj1.DEPT_Price_Ld_Par_Last_7d__c=2;
            snapshotObj1.DEPT_Out_of_Stock_Prev_Day__c=2;
            //snapshotObj1.wal_Return_Rate_Last_30d__c=2;
            snapshotObj1.DEPT_Out_of_Stock_STDev_30d__c=2;
            snapshotObj1.DEPT_GMV_STDev_30d__c=50;
            snapshotObj1.DEPT_GMV_Last_14d__c=5;
            snapshotObj1.DEPT_GMV_Last_30d__c=30;
            snapshotObj1.DEPT_GMV_Last_3d__c=30;
            snapshotObj1.DEPT_GMV_Last_7d__c=30;
            snapshotObj1.DEPT_GMV_Prev_Day__c=30;
            snapshotObj1.SLR_GMV_STDev_30d__c=50;
            snapshotObj1.SLR_GMV_Last_14d__c=5;
            snapshotObj1.SLR_GMV_Last_30d__c=30;
            snapshotObj1.SLR_GMV_Last_3d__c=30;
            snapshotObj1.SLR_GMV_Last_7d__c=30;
            snapshotObj1.SLR_GMV_Prev_Day__c=10;
            snapshotObj1.SLR_Refund_Rate_Last_7d__c=0;
            snapshotObj1.SLR_Refund_Rate_Last_30d__c=1;
            snapshotObj1.DEPT_Pub_SKUs_Last_7d__c=2;
            snapshotObj1.DEPT_Pub_SKUs_Prev_Day__c=3;
            Database.insert(snapshotObj1); 
                    
            Department_Contact__c deptConObj = new Department_Contact__c();
            deptConObj.Account__c = guest.id;
            deptConObj.Wal_Contact__c= testContact.id;
            deptConObj.Wal_Account_Department__c=accDeptObj.id;
            deptConObj.RecordTypeId=RecordTypeId;
            Database.Insert(deptConObj);
           
            Test.startTest();
            WALCreateSubscriberListBatch batchWALCreateSubscriberList = new WALCreateSubscriberListBatch();
            Database.executeBatch(batchWALCreateSubscriberList);
            Test.stopTest();
            }
           
      }
    /*test Method*/
    static testmethod void testschedule() {
        User admin = [select id from User where id =: UserInfo.getUserId() LIMIT 1];
        Test.StartTest();
        system.RunAs(admin){
            WALCreateSubscriberListBatchScheduler sh1 = new WALCreateSubscriberListBatchScheduler();      
            String sch = '0 0 23 * * ?';
            system.schedule('TestScheduleApexClass', sch, sh1);
        }
        Test.stopTest();
    }        
  
    }