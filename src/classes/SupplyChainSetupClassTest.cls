@isTest(seeAllData=false)
public class SupplyChainSetupClassTest {
static testMethod void SupplyChainSetupClass(){ 
        
       
        Id mPAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('1P Account').getRecordTypeId();
        //Id mPAccountRecordTypeId= '012610000002gukAAA';.
        Id mPOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('1P Opportunity').getRecordTypeId();
        list<Account> accList = new List<Account>();
        Account tempAcc = new Account(Name = 'TestfName',Wal_SC_Setup_Complete_DSV__c= true,Wal_SC_Setup_Complete_Owned__c=true,RecordTypeID = mPAccountRecordTypeId,Wal_SC_Setup_Registered_DSV__c=true,Wal_SC_Setup_Registered_Owned__c=true,Cat_Mgr_Owner__c=UserInfo.getUserId());
        insert tempAcc;
        accList.add(tempAcc);
        list<Opportunity> OppList = new List<Opportunity>();
        Opportunity tempOpp = new Opportunity(Name = 'TestOppName',StageName='Initiated',CloseDate = Date.parse('12/15/15'), AccountId = tempAcc.Id,RecordTypeID = mPOpportunityRecordTypeId );
        insert tempOpp;
        OppList.add(tempOpp);
        
}
}