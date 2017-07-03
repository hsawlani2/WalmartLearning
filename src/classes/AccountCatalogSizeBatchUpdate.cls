global class AccountCatalogSizeBatchUpdate implements Database.batchable<sObject>{
    
    global AccountCatalogSizeBatchUpdate(){
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id mPAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MP Account').getRecordTypeId();
        string query='Select Id,Catalog_Size__c,Active__c from Account where RecordTypeID =: mPAccountRecordTypeId AND Active__c = true AND (Catalog_Size__c = 0 OR Catalog_Size__c = null)';
        system.debug('query.. '+query);
        return Database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext info, List<Account> scope){
         Set<Id> accountSetId = new Set<Id>();
         Set<Id> opportunitySetId = new Set<Id>();
         
         for(Account acc : [Select Id,(Select Id,StageName from Opportunities) from Account where Id IN : scope]){
             accountSetId.add(acc.ID);
             if(acc.Opportunities.size() == 1){
                 if(acc.Opportunities[0].StageName == 'Closed Won'){
                     opportunitySetId.add(acc.Opportunities[0].Id);
                 }
             }
             system.debug('..scopee... '+acc);
         }
         List<Account> accountList = new List<Account>();
         for(Opportunity opp : [Select Id,Account.Catalog_Size__c,(Select Id, No_of_SKU_s_to_be_sold_at_Walmart__c from AppliationCategories__r),(Select Id,Amazon_No_of_Active_SKUs__c from Applications__r) from Opportunity where Id IN : opportunitySetId]){
             if(opp.Applications__r.size() == 1){
                 if(opp.AppliationCategories__r.size() > 0){
                     Decimal catalogSize = 0;
                     for(ApplicationCategories__c appCat : opp.AppliationCategories__r){
                         if(appCat.No_of_SKU_s_to_be_sold_at_Walmart__c != null){
                            catalogSize += appCat.No_of_SKU_s_to_be_sold_at_Walmart__c;
                         }
                     }
                     if(catalogSize != 0){
                        accountList.add(new Account(Id=opp.AccountId,Catalog_Size__c = catalogSize));
                     }else{
                        accountList.add(new Account(Id=opp.AccountId,Catalog_Size__c = 1000));
                     }
                 }else{
                     accountList.add(new Account(Id=opp.AccountId,Catalog_Size__c = 1000));
                 }
             }
         }
         
         try{
             system.debug('..update... list.. '+accountList);
            update accountList;
        }catch(Exception e){
        }
         
     }
     
     global void finish(Database.BatchableContext info) {}
}