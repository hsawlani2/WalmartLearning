/**
  * @author        Accenture IDC Team
  * @date          
  * @description   Batch class for creating department contact
  */
global with sharing class WalCreateDeptContact implements Database.Batchable<sObject> {
    private static final String colonStr= ':';
    Date dueDate =  Date.today().addDays(-1);
    global string queryString = '';

    public WalCreateDeptContact(){
        
        queryString = 'SELECT wal_Account__c,wal_Department__c,wal_Department__r.Cancellation_Rate_Acute_Buffer__c,wal_Department__r.Cancellation_Rate_Chronic_Threshold__c,wal_Department__r.Catalog_SKU_Ramp_Threshold__c,wal_Department__r.On_Time_Ship_Rate_Acute_Buffer__c,wal_Department__r.On_Time_Ship_Rate_Chronic_Threshold__c,wal_Department__r.Price_Leadership_Parity_Rate_Threshold__c,wal_Department__r.Refund_Rate_Acute_Buffer__c,wal_Snapshot_Date__c,Wal_Account__r.Primary_Contact__c FROM wal_Performance_Snapshot__c where wal_Snapshot_Date__c =:dueDate';
    }

    /**
    * @description       This method queries the soql query and 
                       passes the List of records obtained to the execute method.
    * @param             Query String
    * @return            NA
    * @throws            NA
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }

    /**
    * @description       Method executes the query and return the QueryLocator Object
    * @param             Database.BatchableContext object
    * @return            Database.QueryLocator
    * @throws            NA   
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
         String deptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Department_Contact__c' and Developername = 'MP_Department_Contact'].Id;
         String accDeptRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account_Department__c' and Developername = 'MP_Account_Department'].Id;
         List<wal_Performance_Snapshot__c> snapShotObjList = (List<wal_Performance_Snapshot__c>)scope;         
         List<Account_Department__c> accDeptObjList = new List<Account_Department__c>();
         List<WAL_Threshold__c> thrsObjList = new List<WAL_Threshold__c>();
         List<Department_Contact__c> deptConObjList = new List<Department_Contact__c>();
         List<Contact> conList = new List<Contact>();
         Boolean isCreated;
         List<Id>accList = new List<Id>();
         Set<Id> accSet = new Set<Id>();
         Map<String,String >mapAccDept = new Map<String,String >();
         Map<String,String >mapThreshold = new Map<String,String >();
         Map<String,List<Contact>>accountConMap = new Map<String,List<Contact>>();
         Map<String,String>mapAccPrimarycon = new Map<String,String>();
         
         for(wal_Performance_Snapshot__c snapShotObj : snapShotObjList) {
             if(snapShotObj.wal_Account__c !=null && snapShotObj.wal_Department__c !=null ){
             accSet.add(snapShotObj.wal_Account__c);
             }
         }
         
         for(Account_Department__c accDeptObj :[Select Id,Wal_Account__c,Wal_Account__r.Primary_Contact__c,Wal_Department__c from Account_Department__c where Wal_Account__c IN:accSet  LIMIT 50000]){
          mapAccDept.put(accDeptObj.wal_Account__c+colonStr+accDeptObj.wal_Department__c,accDeptObj.id);
         }
         for(WAL_Threshold__c threshold :[Select Id,WAL_Account__c,WAL_Department__c from WAL_Threshold__c where WAL_Account__c IN:accSet  LIMIT 50000]){
          mapThreshold.put(threshold.WAL_Account__c+colonStr+threshold.WAL_Department__c,threshold.id);
         }
         
         for(wal_Performance_Snapshot__c snapShotObj: snapShotObjList){
                 if(!(mapAccDept.containsKey(snapShotObj.wal_Account__c+colonStr+snapShotObj.wal_Department__c))){
                      Account_Department__c createAccDeptObj = new Account_Department__c();
                      createAccDeptObj.Wal_Account__c = snapShotObj.Wal_Account__c;
                      createAccDeptObj.Wal_Department__c = snapShotObj.wal_Department__c;
                      createAccDeptObj.RecordTypeId = accDeptRecordTypeId;
                      mapAccDept.put(snapShotObj.wal_Account__c+colonStr+snapShotObj.wal_Department__c,snapShotObj.id);
                      accDeptObjList.add(createAccDeptObj);
                  }
                  if(!(mapThreshold.containsKey(snapShotObj.wal_Account__c+colonStr+snapShotObj.wal_Department__c))){
                      WAL_Threshold__c thresholdObj = new WAL_Threshold__c();
                      thresholdObj.Wal_Account__c = snapShotObj.Wal_Account__c;
                      thresholdObj.Wal_Department__c = snapShotObj.wal_Department__c;
                      thresholdObj.Cancellation_Rate_Acute_Buffer__c=snapShotObj.wal_Department__r.Cancellation_Rate_Acute_Buffer__c;
                      thresholdObj.Cancellation_Rate_Chronic_Threshold__c=snapShotObj.wal_Department__r.Cancellation_Rate_Chronic_Threshold__c;
                      thresholdObj.Catalog_SKUs_Threshold__c=snapShotObj.wal_Department__r.Catalog_SKU_Ramp_Threshold__c;
                      thresholdObj.On_Time_Ship_Acute_Buffer__c=snapShotObj.wal_Department__r.On_Time_Ship_Rate_Acute_Buffer__c;
                      thresholdObj.On_Time_Ship_Chronic_Threshold__c=snapShotObj.wal_Department__r.On_Time_Ship_Rate_Chronic_Threshold__c;
                      thresholdObj.WAL_Price_Leadership_Parity_Threshold__c=snapShotObj.wal_Department__r.Price_Leadership_Parity_Rate_Threshold__c;
                      thresholdObj.WAL_Refund_Rate_Buffer__c=snapShotObj.wal_Department__r.Refund_Rate_Acute_Buffer__c;
                      mapThreshold.put(snapShotObj.wal_Account__c+colonStr+snapShotObj.wal_Department__c,snapShotObj.id);
                      thrsObjList.add(thresholdObj);
                  }
         }   
          
         if(!accDeptObjList.isEmpty()){ 
               try{               
                insert accDeptObjList;
               }
               catch(Exception e){
                  e.getMessage();
                }
         }
         if(!thrsObjList.isEmpty()){ 
               try{
               Database.insert(thrsObjList);
               }
               catch(Exception e){
                  e.getMessage();
                } 
         }
         
         for(Account_Department__c accDeptObj : accDeptObjList){
              accList.add(accDeptObj.Wal_Account__c);
         }
         
         system.debug('accList============>'+accList);
         if(!accList.isEmpty()){
             for(Contact conObj:[Select Contact_Type__c,contact.Account.Id,contact.Account.Primary_Contact__c,email from Contact where contact.Account.Id IN:accList AND email!=null LIMIT 50000]){
                system.debug('conObj=======>'+conObj);
                if(conObj.Id==conObj.Account.Primary_Contact__c ){
                    mapAccPrimarycon.put(conObj.Account.Id,conObj.Account.Primary_Contact__c);
                }
                if(conObj.Contact_Type__c!=null && conObj.Contact_Type__c.contains('Marketplace Business Manager')){
                    if(accountConMap.containsKey(conObj.Account.Id)){
                      accountConMap.get(conObj.Account.Id).add(conObj);
                    }else{
                        conList = new List<Contact>();
                        conList.add(conObj);
                        accountConMap.put(conObj.Account.Id,conList);
                    }
                }
             }
         }
         system.debug('mapAccPrimarycon=======>'+mapAccPrimarycon);
         system.debug('accountConMap=======>'+accountConMap);
         for(Account_Department__c accDeptObj:accDeptObjList){
           if(!accountConMap.isEmpty() && accountConMap.containsKey(accDeptObj.Wal_Account__c)){
               for(contact conobj:accountConMap.get(accDeptObj.Wal_Account__c)){
                  Department_Contact__c deptConObj = new Department_Contact__c();
                  deptConObj.Wal_Account_Department__c=accDeptObj.id;
                  deptConObj.Account__c=accDeptObj.Wal_Account__c;
                  deptConObj.Wal_Contact__c=conObj.id;
                  deptConObj.RecordTypeId = deptRecordTypeId;
                  deptConObjList.add(deptConObj);
               }
           }
           else{
              if(mapAccPrimarycon.get(accDeptObj.Wal_Account__c)!=null){
                  Department_Contact__c deptConObj = new Department_Contact__c();
                  deptConObj.Wal_Account_Department__c=accDeptObj.id;
                  deptConObj.Account__c=accDeptObj.Wal_Account__c;
                  deptConObj.Wal_Contact__c=mapAccPrimarycon.get(accDeptObj.Wal_Account__c);
                  deptConObj.RecordTypeId = deptRecordTypeId;
                  deptConObjList.add(deptConObj);
              }
              
           }
         }
        system.debug('deptConObjList========>'+deptConObjList);
       //Inserting Department Contact
       if(!deptConObjList.isEmpty()){ 
           
           try{
           Database.insert(deptConObjList);
           }
           
           catch(Exception e){
              e.getMessage();
          } 
       }
    }

    /**
    * @description       Finish methord of Batch class 
    * @param             Database.BatchableContext object
    * @return            void
    * @throws            NA
    */
    global void finish(Database.BatchableContext bc){
    }   
}