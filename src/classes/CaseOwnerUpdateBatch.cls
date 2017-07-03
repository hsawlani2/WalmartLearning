/**
 * A batch class that will update the Case owner with the Account integration engineer lookup
 * 
 * @createddate 27/07/2016
 */ 
global class CaseOwnerUpdateBatch implements Database.batchable<sObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC){
        string recordTypeName = 'Seller Community Onboarding Case';
        string ownerName = 'Seller Community Onboarding Queue';
        
        string query = ' select Id, OwnerId, AccountId, Account.Integration_Engineer__c, Account.Seller_Liaison__c, Account.Seller_Onboarding_Status__c '+
                       ' from Case where (Account.Integration_Engineer__c != null or Account.Seller_Liaison__c != null) '+
                       ' and RecordType.Name =: recordTypeName ';
        
        if(!Test.isRunningTest())
            query += ' and Owner.Name =: ownerName';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, list<Case> scope) {
        list<Case> caseUpdateList = new list<Case>();
        
        for(Case aCase : scope){
            if(aCase.OwnerId != aCase.Account.Integration_Engineer__c && 
               aCase.Account.Seller_Onboarding_Status__c != 'Pre Seller Setup' &&
               aCase.Account.Seller_Onboarding_Status__c != 'Seller Setup')
            {
                aCase.OwnerId = aCase.Account.Integration_Engineer__c;
                caseUpdateList.add(aCase);
            }else if(aCase.OwnerId != aCase.Account.Seller_Liaison__c && 
                    (aCase.Account.Seller_Onboarding_Status__c == 'Pre Seller Setup' ||
                     aCase.Account.Seller_Onboarding_Status__c == 'Seller Setup')){
                
                aCase.OwnerId = aCase.Account.Seller_Liaison__c;
                caseUpdateList.add(aCase);
            }
        }
        
        if(caseUpdateList.size() > 0){
            SFJIRAIntegrationHelper.UPDATE_JIRA_STATUS = false;
            update caseUpdateList;
        }
    }
    
    global void finish(Database.BatchableContext info) {}
}