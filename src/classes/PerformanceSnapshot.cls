global class  PerformanceSnapshot implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date todayDate = system.today();
        system.debug('..todayss.. '+todayDate);



       // List<wal_Performance_Snapshot__c> performanceList = [Select Id,wal_Account__c,wal_Account__r.RecordTypeId from wal_Performance_Snapshot__c where CreatedDate = TODAY];
        string query = 'Select Id,wal_Account__c,wal_Account__r.RecordTypeId from wal_Performance_Snapshot__c where CreatedDate = TODAY';
        
        /*
        string query = 'Select Id,(Select '  +'Id,wal_Account__c,wal_Account__r.RecordTypeId,SLR_On_Time_Ship_Prev_Day__c,SLR_Sold_SKUs_Prev_Day__c,SLR_Cancel_Rate_Prev_Day__c,'
        +' SLR_In_Stock_Prev_Day__c,SLR_Refund_Rate_Prev_Day__c,SLR_Out_of_Stock_Prev_Day__c,SLR_Pub_SKUs_Prev_Day__c,SLR_GMV_Prev_Day__c,'
        +' SLR_Buyable_SKUs_Prev_Day__c,SLR_Unpub_SKUs_Prev_Day__c,SLR_On_Time_Ship_Last_14d__c,SLR_Sold_SKUs_Last_14d__c,'
        +' SLR_Cancel_Rate_Last_14d__c,SLR_In_Stock_Last_14d__c,SLR_Refund_Rate_Last_14d__c,SLR_Out_of_Stock_Last_14d__c,SLR_Pub_SKUs_Last_14d__c,'
        +' SLR_GMV_Last_14d__c,SLR_Buyable_SKUs_Last_14d__c,SLR_Unpub_SKUs_Last_14d__c from Performance_Snapshots__r ORDER BY wal_Snapshot_Date__c'
        +' DESC NULLS LAST LIMIT 1 ) from Account where Id IN : accIdSet AND RecordTypeId =: mPAccountRecordTypeId limit 30000'; 
        */
        
        system.debug('accc.. '+query);
        system.debug('accc.. new.. '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext info, List<sObject> scope){
        system.debug('..scopee.. new .. hello');
        Map<Id,Account> accountList = new Map<Id,account>(); 
        system.debug('..scopee.. new .. '+scope);
        
        Id mPAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MP Account').getRecordTypeId();
        Set<Id> accIdSet = new Set<Id>();
        for(SObject per : scope){
        wal_Performance_Snapshot__c acc = (wal_Performance_Snapshot__c)per;
        accIdSet.add(acc.wal_Account__c);
        }
        
        List<Account> accList = [Select Id,(Select Id,wal_Account__c,wal_Account__r.RecordTypeId,SLR_On_Time_Ship_Prev_Day__c,SLR_Sold_SKUs_Prev_Day__c,SLR_Cancel_Rate_Prev_Day__c,
        SLR_In_Stock_Prev_Day__c,SLR_Refund_Rate_Prev_Day__c,SLR_Out_of_Stock_Prev_Day__c,SLR_Pub_SKUs_Prev_Day__c,SLR_GMV_Prev_Day__c,
        SLR_Buyable_SKUs_Prev_Day__c,SLR_Unpub_SKUs_Prev_Day__c,SLR_On_Time_Ship_Last_14d__c,SLR_Sold_SKUs_Last_14d__c,
        SLR_Cancel_Rate_Last_14d__c,SLR_In_Stock_Last_14d__c,SLR_Refund_Rate_Last_14d__c,SLR_Out_of_Stock_Last_14d__c,SLR_Pub_SKUs_Last_14d__c,
        SLR_GMV_Last_14d__c,SLR_Buyable_SKUs_Last_14d__c,SLR_Unpub_SKUs_Last_14d__c from Performance_Snapshots__r ORDER BY wal_Snapshot_Date__c
        DESC NULLS LAST LIMIT 1 ) from Account where Id IN : accIdSet AND RecordTypeId =: mPAccountRecordTypeId limit 200];
        
        for(Account acc : accList){
            system.debug('..scopee.. '+scope);
           // Account acc = (Account)sco;
            if(acc.Performance_Snapshots__r.size() > 0){
                for(wal_Performance_Snapshot__c per : acc.Performance_Snapshots__r){
                    system.debug('..per.. '+per);
                    accountList.put(per.wal_Account__c,new Account(
                    Id = per.wal_Account__c,
                    SLR_On_Time_Ship_Prev_Day__c = per.SLR_On_Time_Ship_Prev_Day__c,
                    SLR_Sold_SKUs_Prev_Day__c = per.SLR_Sold_SKUs_Prev_Day__c,
                    SLR_Cancel_Rate_Prev_Day__c = per.SLR_Cancel_Rate_Prev_Day__c,
                    SLR_In_Stock_Prev_Day__c = per.SLR_In_Stock_Prev_Day__c,
                    SLR_Refund_Rate_Prev_Day__c = per.SLR_Refund_Rate_Prev_Day__c,
                    SLR_Out_of_Stock_Prev_Day__c = per.SLR_Out_of_Stock_Prev_Day__c,
                    SLR_Pub_SKUs_Prev_Day__c = per.SLR_Pub_SKUs_Prev_Day__c,
                    SLR_GMV_Prev_Day__c = per.SLR_GMV_Prev_Day__c,
                    SLR_Buyable_SKUs_Prev_Day__c = per.SLR_Buyable_SKUs_Prev_Day__c,
                    SLR_Unpub_SKUs_Prev_Day__c = per.SLR_Unpub_SKUs_Prev_Day__c,
                    SLR_On_Time_Ship_Last_14d__c = per.SLR_On_Time_Ship_Last_14d__c,
                    SLR_Sold_SKUs_Last_14d__c = per.SLR_Sold_SKUs_Last_14d__c,
                    SLR_Cancel_Rate_Last_14d__c = per.SLR_Cancel_Rate_Last_14d__c,
                    SLR_In_Stock_Last_14d__c = per.SLR_In_Stock_Last_14d__c,
                    SLR_Refund_Rate_Last_14d__c = per.SLR_Refund_Rate_Last_14d__c,
                    SLR_Out_of_Stock_Last_14d__c = per.SLR_Out_of_Stock_Last_14d__c,
                    SLR_Published_SKUs_Last_14d__c = per.SLR_Pub_SKUs_Last_14d__c,
                    SLR_GMV_Last_14d__c = per.SLR_GMV_Last_14d__c,
                    SLR_Buyable_SKUs_Last_14d__c = per.SLR_Buyable_SKUs_Last_14d__c,
                    SLR_Unpub_SKUs_Last_14d__c = per.SLR_Unpub_SKUs_Last_14d__c
                    ));
                }
            }           
        }
        
        
        try{ 
            update accountList.values();
        }catch(Exception e){
            
        } 
    }
    
    global void finish(Database.BatchableContext info) {}
}