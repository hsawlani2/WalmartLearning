/***********************************************************
Class Name:WALCreateSubscriberListBatch
Purpose:Create a Master Subscriber List in Salesforce to Synchronize Marketing Cloud’s Subscriber List
Version 1.0 5thAugust2016 Draft
/***********************************************************/
global class WALCreateSubscriberListBatch implements Database.Batchable<sObject>{ 
     
    /*Setting the query Parameter*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string MPRECORDTYPE='MP_Department_Contact';
        string query='Select RecordType.Developername,Wal_Account_Department__c,Wal_Account_Department__r.Wal_Account__c, ';
        query=query+'Wal_Account_Department__r.wal_Account__r.Tier__c,Wal_Account_Department__r.wal_Account__r.Category__c, ';
        query=query+'Wal_Account_Department__r.Name, Wal_Account_Department__r.Wal_Department__c,';
        query=query+'Wal_Account_Department__r.wal_Account__r.Amazon_No_of_Active_SKUs__c,Wal_Account_Department__r.wal_Account__r.Ebay_No_of_Active_SKUs__c, ';
        query=query+'Wal_Account_Department__r.wal_Account__r.Live_Date__c,Wal_Account_Department__r.wal_Account__r.Other_No_of_Active_SKUs__c, ';
        query=query+'Wal_Account_Name__c,Wal_Department_Name__c,Wal_Email__c,Wal_Contact__c, ';
        query=query+'Wal_Contact__r.Name,Wal_Account_Department__r.Wal_Department__r.Wal_Department_ID__c ';
        query=query+'FROM Department_Contact__c WHERE RecordType.Developername =:MPRECORDTYPE';
        return Database.getQueryLocator(query);
            
    }
    /*Manipulating department contact list to create subscribers list*/
    global void execute(Database.batchableContext BC,List<Department_Contact__c> departmentContactList){
        //Global GMV
        Setting_1P_3P__c setting = Setting_1P_3P__c.getOrgDefaults();
        decimal GLOBALGMV=setting.Global_GMV__c/100;
        //Constant Declaration
        string IMPRV='Improving';
        string WORS='Worsening';
        string NOCHNG='No Change';
        string RED='Red';
        string GREEN='Green';
        string NOTAVL='Not Available';
        integer SNAPSHOTDATESET=(Integer)setting.Snapshot_Date__c;
        integer TRENDDATESET=(Integer)setting.Trend_Date__c;
        
        //Getting the values from Custom Setting
        wal_Performance_Rule__c performanceRule = wal_Performance_Rule__c.getValues('Refund Spike');
        set<string> settingSet=new set<string>();
        if(performanceRule.Performance_Snapshot_Month__c!=null){
            list<string> settingList=performanceRule.Performance_Snapshot_Month__c.split('%%');
            settingSet.addAll(settingList);
        }
        
        //Retrieved Department Contacts
        system.debug('departmentContactList======>'+departmentContactList);
        //Getting all department and account ids
        set<Id> batchAccountIds=new set<Id>();
        for(Department_Contact__c eachDptContact : departmentContactList){
            batchAccountIds.add(eachDptContact.Wal_Account_Department__r.Wal_Account__c);
                       
        }
        system.debug('batchAccountIds======>'+batchAccountIds);
        //Getting Custom setting data
        list<wal_Performance_Rule__c> allPerfRules=wal_Performance_Rule__c.getAll().values();
        system.debug('allPerfRules======>'+allPerfRules);
        
        //Getting all Threshhold records
        map<String,WAL_Threshold__c> allThresholdMap=new map<String,WAL_Threshold__c>();
        for(WAL_Threshold__c eachThrs : [SELECT Id,WAL_Account__c,WAL_Department__c,On_Time_Ship_Acute_Buffer__c,
                                                   On_Time_Ship_Chronic_Threshold__c,
                                                   Cancellation_Rate_Chronic_Threshold__c,
                                                   Cancellation_Rate_Acute_Buffer__c,
                                                   WAL_Price_Leadership_Parity_Threshold__c,
                                                   Catalog_SKUs_Threshold__c,
                                                   WAL_Refund_Rate_Buffer__c FROM WAL_Threshold__c WHERE WAL_Account__c IN: batchAccountIds]){
            allThresholdMap.put(eachThrs.WAL_Account__c+''+eachThrs.WAL_Department__c,eachThrs);
        }
        //Getting all Performance Snapshots for today
        Date snapshotDate=Date.Today().addDays(-SNAPSHOTDATESET);
        map<String,wal_Performance_Snapshot__c> performanceSnapshotMap=new map<String,wal_Performance_Snapshot__c>();
        for(wal_Performance_Snapshot__c eachPerfSnap : [SELECT Id,wal_Account__c,wal_Department__c,
                                                        SLR_On_Time_Ship_Last_7d__c,
                                                        SLR_On_Time_Ship_Prev_Day__c,
                                                        DEPT_GMV_Prev_Day__c,
                                                        SLR_GMV_Prev_Day__c,
                                                        SLR_Cancel_Rate_Prev_Day__c,
                                                        SLR_Cancel_Rate_Last_7d__c,
                                                        DEPT_GMV_STDev_30d__c,
                                                        SLR_Refund_Rate_Last_7d__c,
                                                        DEPT_Buyable_SKUs_Prev_Day__c,
                                                        DEPT_Buyable_SKUs_STDev_30d__c,
                                                        DEPT_Price_Ld_Par_Last_7d__c,
                                                        DEPT_Out_of_Stock_Prev_Day__c,
                                                        wal_Snapshot_Date__c,
                                                        SLR_Pub_SKUs_Prev_Day__c,
                                                        DEPT_Out_of_Stock_STDev_30d__c,
                                                        SLR_Refund_Rate_Last_30d__c,
                                                        DEPT_Buyable_SKUs_Last_14d__c,
                                                        DEPT_GMV_Last_7d__c,
                                                        DEPT_Out_of_Stock_Last_14d__c,
                                                        DEPT_Pub_SKUs_Prev_Day__c,
                                                        DEPT_Pub_SKUs_Last_7d__c
                                                        FROM wal_Performance_Snapshot__c 
                                                        WHERE wal_Account__c IN: batchAccountIds 
                                                        AND wal_Snapshot_Date__c =: snapshotDate]){
            performanceSnapshotMap.put(eachPerfSnap.wal_Account__c+''+eachPerfSnap.wal_Department__c,eachPerfSnap);
        }
        
        //Getting all Performance Snapshots for yesterday
        map<String,wal_Performance_Snapshot__c> performanceSnapshotMapPrev=new map<String,wal_Performance_Snapshot__c>();
        Date snapshotDatePrev=Date.Today().addDays(-TRENDDATESET);
        for(wal_Performance_Snapshot__c eachPerfSnap : [SELECT Id,wal_Account__c,wal_Department__c,
                                                        SLR_On_Time_Ship_Prev_Day__c,
                                                        SLR_On_Time_Ship_Last_7d__c,
                                                        SLR_Cancel_Rate_Prev_Day__c,
                                                        SLR_Cancel_Rate_Last_7d__c,
                                                        DEPT_Buyable_SKUs_Prev_Day__c,
                                                        DEPT_Price_Ld_Par_Last_7d__c,
                                                        DEPT_GMV_Prev_Day__c,
                                                        DEPT_Out_of_Stock_Prev_Day__c,
                                                        SLR_Pub_SKUs_Prev_Day__c,
                                                        SLR_Refund_Rate_Last_7d__c,
                                                        DEPT_Pub_SKUs_Prev_Day__c
                                                        FROM wal_Performance_Snapshot__c 
                                                        WHERE wal_Account__c IN: batchAccountIds 
                                                        AND wal_Snapshot_Date__c =: snapshotDatePrev]){
            performanceSnapshotMapPrev.put(eachPerfSnap.wal_Account__c+''+eachPerfSnap.wal_Department__c,eachPerfSnap);
        }
        
        //List to store all the subscribers
        list<Subscriber_List__c> masterContactList=new list<Subscriber_List__c>();
        //variable to store trend and status Indicator
        Decimal trend;
        string statusIndecator;
        //variable to store trend and status Indicator
        string accDepartmentId;
        //variables for SKU Ramp(Seller)
        decimal Amazon_No_of_Active_SKUs;
        decimal Ebay_No_of_Active_SKUs;
        decimal Other_No_of_Active_SKUs;
        //checking if performance snapshot is not empty
        if(performanceSnapshotMap!=null && !performanceSnapshotMap.isEmpty() && performanceSnapshotMapPrev!=null && !performanceSnapshotMapPrev.isEmpty()){
            //Iterating through each rule to create subscriber list.
            for(wal_Performance_Rule__c eachRule:allPerfRules){
                for(Department_Contact__c eachDeptContact : departmentContactList){
                    accDepartmentId=null;
                    trend=null;
                    statusIndecator=null;
                    if(eachDeptContact.Wal_Account_Department__r.Wal_Account__c!=null && eachDeptContact.Wal_Account_Department__r.Wal_Department__c!=null){
                        accDepartmentId=eachDeptContact.Wal_Account_Department__r.Wal_Account__c+''+eachDeptContact.Wal_Account_Department__r.Wal_Department__c;
                    }
                    system.debug('accDepartmentId=======>'+accDepartmentId);
                    //Creating Subscriber for each Department Contact
                    Subscriber_List__c eachMaster=new Subscriber_List__c();
                    eachMaster.Account_Name__c=eachDeptContact.Wal_Account_Name__c;
                    eachMaster.Department_Name__c=eachDeptContact.Wal_Department_Name__c;
                    eachMaster.Department_Number__c=eachDeptContact.Wal_Account_Department__r.Wal_Department__r.Wal_Department_ID__c;
                    eachMaster.KPI_Name__c=eachRule.Name;
                    eachMaster.Contact_Email__c=eachDeptContact.Wal_Email__c;
                    eachMaster.Contact_Name__c=eachDeptContact.Wal_Contact__r.Name;
                    eachMaster.Contact_ID__c=eachDeptContact.Wal_Contact__c;
                    if(accDepartmentId!=null 
                        && performanceSnapshotMap.get(accDepartmentId)!=null 
                        && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c!=null 
                        && performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c!=null
                        && performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c!=0 
                        && (performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c/performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c)
                        >=GLOBALGMV){
                        eachMaster.Valid_GMV__c=True;
                    }
                    else if(accDepartmentId!=null 
                        && performanceSnapshotMap.get(accDepartmentId)!=null 
                        && (performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c==null
                        || performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c==0)){
                        eachMaster.Valid_GMV__c=True;
                    }
                    else{
                        eachMaster.Valid_GMV__c=false;
                    }
                    
                    //Added for requirement#129
                    eachMaster.Account__c=eachDeptContact.Wal_Account_Department__r.Wal_Account__c;
                    eachMaster.Wal_Department__c=eachDeptContact.Wal_Account_Department__r.Wal_Department__c;
                    eachMaster.Wal_Account_Department__c=eachDeptContact.Wal_Account_Department__c;
                    eachMaster.Wal_Account_Department_Name__c=eachDeptContact.Wal_Account_Department__r.Name;
                    eachMaster.wal_Contact__c=eachDeptContact.Wal_Contact__c;
                    eachMaster.wal_Threshold_Valid__c=True;
                    
                    //Added for Request ID 143
                    eachMaster.Department_Contact__c=eachDeptContact.Id; 
                    
                    
                    //Acute Late Shipping(KPI-1)
                    if('Acute Late Shipping'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                                && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c!=null
                                && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                                && performanceSnapshotMapPrev.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c==null)
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                  && allThresholdMap.get(accDepartmentId).On_Time_Ship_Acute_Buffer__c==null
                                )
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null   
                                ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).On_Time_Ship_Acute_Buffer__c!=null
                                    && ((performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c-
                                         performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Prev_Day__c)
                                         > allThresholdMap.get(accDepartmentId).On_Time_Ship_Acute_Buffer__c)
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    
                    //Chronic Late Shipping(KPI-2)
                    if('Chronic Late Shipping'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c==null)
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                  && allThresholdMap.get(accDepartmentId).On_Time_Ship_Chronic_Threshold__c==null
                                )
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null   
                                ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).On_Time_Ship_Chronic_Threshold__c!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).SLR_On_Time_Ship_Last_7d__c<
                                         allThresholdMap.get(accDepartmentId).On_Time_Ship_Chronic_Threshold__c)
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    
                    //Acute High Cancellations(KPI-3)
                    if('Acute High Cancellations'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || eachRule.GMV_Prev_Day__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c==null)
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                  && allThresholdMap.get(accDepartmentId).Cancellation_Rate_Acute_Buffer__c==null
                                )
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null   
                                ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c!=null
                                    && eachRule.GMV_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c>eachRule.GMV_Prev_Day__c)
                                    &&(performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).Cancellation_Rate_Acute_Buffer__c!=null
                                    && ((performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Prev_Day__c-
                                         performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c)>
                                         allThresholdMap.get(accDepartmentId).Cancellation_Rate_Acute_Buffer__c))
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    
                    //Chronic High Cancellations (KPI-4)
                    if('Chronic High Cancellations'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || eachRule.GMV_Prev_Day__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c==null)
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                  && allThresholdMap.get(accDepartmentId).Cancellation_Rate_Chronic_Threshold__c==null
                                )
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null   
                                ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c!=null
                                    && eachRule.GMV_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_GMV_Prev_Day__c>eachRule.GMV_Prev_Day__c)
                                    &&(performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).Cancellation_Rate_Chronic_Threshold__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_Cancel_Rate_Last_7d__c>
                                         allThresholdMap.get(accDepartmentId).Cancellation_Rate_Chronic_Threshold__c)
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                        
                    }
                    
                    //Return Spike (KPI-5)
                    if('Refund Spike'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_30d__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).wal_Snapshot_Date__c==null)
                            || (settingSet!=null && settingSet.isEmpty())
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                  && allThresholdMap.get(accDepartmentId).WAL_Refund_Rate_Buffer__c==null
                                )
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null   
                                ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_30d__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).WAL_Refund_Rate_Buffer__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_7d__c>
                                       (performanceSnapshotMap.get(accDepartmentId).SLR_Refund_Rate_Last_30d__c+allThresholdMap.get(accDepartmentId).WAL_Refund_Rate_Buffer__c)
                                    && ( settingSet!=null 
                                         && !settingSet.isEmpty() 
                                         && performanceSnapshotMap.get(accDepartmentId).wal_Snapshot_Date__c!=null 
                                         && !settingSet.contains(''+performanceSnapshotMap.get(accDepartmentId).wal_Snapshot_Date__c.Month()))
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    
                    //Acute Buyable SKU Drop (KPI-6)
                    if('Acute Buyable SKU Drop'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_STDev_30d__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Last_14d__c==null)
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null    
                           ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_STDev_30d__c!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Prev_Day__c<
                                         (performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_Last_14d__c-performanceSnapshotMap.get(accDepartmentId).DEPT_Buyable_SKUs_STDev_30d__c))
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    //Acute GMV Drop (KPI-7)
                    if('Acute GMV Drop'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).DEPT_GMV_Prev_Day__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).DEPT_GMV_Prev_Day__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_STDev_30d__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Last_7d__c==null)
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null    
                           ){
                            statusIndecator=NOTAVL;
                        }
                        else {
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_STDev_30d__c!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c<
                                         (performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Last_7d__c-(2*performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_STDev_30d__c)))
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    
                    //SKU Ramp (KPI-8)
                    if('SKU Ramp (Seller)'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c!=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c
                            -performanceSnapshotMapPrev.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c==null)
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                 && allThresholdMap.get(accDepartmentId).Catalog_SKUs_Threshold__c==null)
                            || (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Amazon_No_of_Active_SKUs__c==null
                            && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Ebay_No_of_Active_SKUs__c==null
                            && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Other_No_of_Active_SKUs__c==null)
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null
                           ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            Amazon_No_of_Active_SKUs=0;
                            Ebay_No_of_Active_SKUs=0;
                            Other_No_of_Active_SKUs=0;
                            if(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Amazon_No_of_Active_SKUs__c!=null){
                                Amazon_No_of_Active_SKUs=eachDeptContact.Wal_Account_Department__r.wal_Account__r.Amazon_No_of_Active_SKUs__c;   
                            }
                            if(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Ebay_No_of_Active_SKUs__c!=null){
                                Ebay_No_of_Active_SKUs=eachDeptContact.Wal_Account_Department__r.wal_Account__r.Ebay_No_of_Active_SKUs__c;
                            }
                            if(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Other_No_of_Active_SKUs__c!=null){
                                Other_No_of_Active_SKUs=eachDeptContact.Wal_Account_Department__r.wal_Account__r.Other_No_of_Active_SKUs__c;
                            }
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).Catalog_SKUs_Threshold__c!=null
                                    && ( performanceSnapshotMap.get(accDepartmentId).SLR_Pub_SKUs_Prev_Day__c<
                                         ( allThresholdMap.get(accDepartmentId).Catalog_SKUs_Threshold__c
                                          * math.max(math.max(Amazon_No_of_Active_SKUs,Ebay_No_of_Active_SKUs),Other_No_of_Active_SKUs)
                                         )
                                    )
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    
                    //Absolute Price Parity (KPI-9)
                    if('Absolute Price Parity'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if(allThresholdMap.get(accDepartmentId)==null){
                            eachMaster.wal_Threshold_Valid__c=False;
                        }
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c !=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c !=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c 
                            -performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c ;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || eachRule.GMV_Prev_Day__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c==null)
                            || allThresholdMap.get(accDepartmentId)==null
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                 && allThresholdMap.get(accDepartmentId).WAL_Price_Leadership_Parity_Threshold__c==null)
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null    
                           ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c!=null
                                    && eachRule.GMV_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_GMV_Prev_Day__c>eachRule.GMV_Prev_Day__c
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).WAL_Price_Leadership_Parity_Threshold__c!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).DEPT_Price_Ld_Par_Last_7d__c<
                                         allThresholdMap.get(accDepartmentId).WAL_Price_Leadership_Parity_Threshold__c)
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    //Out of Stock Spike (KPI-10)
                    if('Out of Stock Spike'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c !=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c !=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c 
                            -performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c ;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_STDev_30d__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Last_14d__c==null)
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null    
                           ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_STDev_30d__c!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Prev_Day__c>
                                         (performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_Last_14d__c+(2*performanceSnapshotMap.get(accDepartmentId).DEPT_Out_of_Stock_STDev_30d__c)))
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    //Out of Stock Spike (KPI-11)
                    if('SKU Ramp (Dept)'.equalsIgnorecase(eachRule.Name) && accDepartmentId!=null){
                        if( performanceSnapshotMap.get(accDepartmentId)!=null
                        && performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c !=null
                        && performanceSnapshotMapPrev.get(accDepartmentId)!=null
                        && performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c !=null){
                            trend=performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c 
                            -performanceSnapshotMapPrev.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c ;
                            if(trend>0){
                                eachMaster.KPI_Trend__c=IMPRV;
                            }
                            else if(trend<0){
                                eachMaster.KPI_Trend__c=WORS;
                            }
                            else if(trend==0){
                                eachMaster.KPI_Trend__c=NOCHNG;
                            }
                        }
                        if( eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c==null
                            || eachRule.Account_Launch_Readiness_Date__c==null
                            || eachRule.Account_Tier__c==null
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c==null
                            || eachRule.Account_Category__c==null
                            || performanceSnapshotMap.get(accDepartmentId)==null
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c==null)
                            || (performanceSnapshotMap.get(accDepartmentId)!=null 
                                 && performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Last_7d__c==null)
                            || (allThresholdMap.get(accDepartmentId)!=null 
                                 && allThresholdMap.get(accDepartmentId).Catalog_SKUs_Threshold__c==null)
                            || eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c==null    
                           ){
                            statusIndecator=NOTAVL;
                        }
                        else{
                            if( (eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c!=null 
                                    && eachRule.Account_Launch_Readiness_Date__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Live_Date__c<
                                    DateTime.Now().addDays(-(Integer)eachRule.Account_Launch_Readiness_Date__c)
                                )
                              &&(eachRule.Account_Tier__c!=null 
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c!=null
                                    && eachRule.Account_Tier__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Tier__c)
                                )
                              &&(eachRule.Account_Category__c!=null
                                    && eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c!=null
                                    && !eachRule.Account_Category__c.contains(eachDeptContact.Wal_Account_Department__r.wal_Account__r.Category__c) 
                                )
                              &&(performanceSnapshotMap.get(accDepartmentId)!=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c !=null
                                    && performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Last_7d__c!=null
                                    && allThresholdMap.get(accDepartmentId)!=null
                                    && allThresholdMap.get(accDepartmentId).Catalog_SKUs_Threshold__c!=null
                                    && (performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Prev_Day__c<(allThresholdMap.get(accDepartmentId).Catalog_SKUs_Threshold__c * performanceSnapshotMap.get(accDepartmentId).DEPT_Pub_SKUs_Last_7d__c))
                                )
                              ){
                                statusIndecator=RED;
                            }else{
                                statusIndecator=GREEN;
                            }
                        }
                    }
                    if(statusIndecator!=null){
                        eachMaster.KPI_Status_Indicator__c=statusIndecator;
                    }
                    else{
                        eachMaster.KPI_Status_Indicator__c=NOTAVL;
                    }                
                    if(trend==null){
                        eachMaster.KPI_Trend__c=NOTAVL;
                    }
                    //Adding the Subscriber to the master list
                    masterContactList.add(eachMaster);              
                                   
                }
            }
        }
        system.debug('masterContactList======>'+masterContactList);
        if(masterContactList!=null && !masterContactList.isEmpty()){
            Database.SaveResult[] masterSubscriberResult = Database.insert(masterContactList, false);
            for (Database.SaveResult sr : masterSubscriberResult) {
                if (sr.isSuccess()) {
                    system.debug('Successfully inserted Master Subscriber record with Id=========>' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()){
                        System.debug('Following error has occurred while inserting Master Subscriber');
                        System.debug('Error Message=====>'+err.getMessage());
                    }
                }
            }
        }
    }
    /*Sending batch status email to scheduler */
    global void finish(Database.BatchableContext BC){
    
    }    
    
}