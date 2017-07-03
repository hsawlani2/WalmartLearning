global class ReportCreation implements Database.batchable<sObject>{
global ReportCreation(){
    }
global Database.QueryLocator start(Database.BatchableContext BC){
        string  stage = 'Closed Won';   
        string mPAccountRecordTypeName  = 'MP Account'; 
        string query='Select Id,Active__c,more_than_one_opp__c,more_than_one_app__c,(select id,StageName from Opportunities where StageName = : stage) from Account where RecordType.name =: mPAccountRecordTypeName AND Active__c = true and (more_than_one_opp__c = false or more_than_one_app__c = false)';   
        //string query='Select Id,Active__c,more_than_one_opp__c,more_than_one_app__c,(select id,StageName from Opportunities) from Account where RecordType.name =: mPAccountRecordTypeName AND Active__c = true and (more_than_one_opp__c = false or more_than_one_app__c = false)';   

        system.debug('query.. '+query);
        return Database.getQueryLocator(query);
 }
 global void execute(Database.BatchableContext info, List<Account> scope){
    Set<Id> opportunitySetId = new Set<Id>();
    Map<id,Account> oppAccount = new Map<id,Account>();
    List<Account> accToBeUpdate = new List<Account>();

    for(Account acc : scope){
        if(acc.Opportunities.size() > 1){
            acc.more_than_one_opp__c = true;
            system.debug('acc.Opportunities.. '+acc.Opportunities[0].id);
            accToBeUpdate.add(acc);
            system.debug('...accc.. '+acc);
        }
        else if(acc.Opportunities.size() == 1){
            opportunitySetId.add(acc.Opportunities[0].id);
            oppAccount.put(acc.Opportunities[0].id,acc);
             system.debug('oppAccount.. '+oppAccount);
        }
        
    }

    if(opportunitySetId.size() > 0){
        List<Opportunity> oppLst = [select id,(select id from Applications__r) from opportunity where id in :opportunitySetId];
         system.debug('oppLst .. '+oppLst );
        for(Opportunity opp : oppLst){
        system.debug('opp.Applications__r.size().. '+opp.Applications__r.size());
            if(opp.Applications__r.size() > 1){
                Account acc = oppAccount.get(opp.id);
                acc.more_than_one_app__c = true;
                accToBeUpdate.add(acc);
                system.debug('opp.accToBeUpdate.size().. '+accToBeUpdate);
            }   
        }
    }

    if(accToBeUpdate.size() > 0){
        system.debug('opp.accToBeUpdate.size().4534. '+accToBeUpdate);
        update accToBeUpdate;   
    }

}


global void finish(Database.BatchableContext info) {}
}