public without sharing class SupplyChainSetupClass{
    
    public void Supplychainupdate(List<Opportunity> oppList){
        
        string RECTYPE='1P Opportunity';
        Id RECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RECTYPE).getRecordTypeId();
        
        List<Id> accListId = new List<Id>();
        for(Opportunity opp : oppList){
            if(opp.RecordTypeId==RECTYPEID){
                accListId.add(opp.AccountId);
            }
        }
       
        
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Account acc : [select Id,Wal_SC_Setup_Complete_DSV__c,Wal_SC_Setup_Complete_Owned__c,Wal_SC_Setup_Registered_DSV__c,Wal_SC_Setup_Registered_Owned__c from Account Where Id IN : accListId]){
            accMap.put(acc.Id,acc);
        }
        
        for(Opportunity op : oppList){
            if(op.RecordTypeId==RECTYPEID){
            op.SC_Setup_Complete_DSV__c = accMap.get(op.AccountId).Wal_SC_Setup_Complete_DSV__c;
            op.SC_Setup_Complete_Owned__c = accMap.get(op.AccountId).Wal_SC_Setup_Complete_Owned__c;
            op.SC_Setup_Registered_DSV__c = accMap.get(op.AccountId).Wal_SC_Setup_Registered_DSV__c;
            op.SC_Setup_Registered_Owned__c = accMap.get(op.AccountId).Wal_SC_Setup_Registered_Owned__c;
           }
        }
       
    }
}