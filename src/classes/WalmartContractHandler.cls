/****************************************************************************************************************************
File Name: WalmartContractHandler
Purpose  : Created to handle Walmart contract trigger events
Version  : Draft

***************************************************************************************************************************/
public class WalmartContractHandler{
    /*** This method is used to update the Opportunity stage based on contract type****/
    public static void updateOpportunity(list<Contract__c> newContractList){
        string WAITINGCONTRACT='Awaiting Contract';
        string SUPPLYCHAIN='Supply Chain Setup';
        string CONTRACT1PRECTYPE='1P Contract';
        string DSV='DSV';
        string OWNED='Owned';
        string VENDOR='Vendor';
        string BOTH='Both';
        system.debug('newContractList===========>'+newContractList);
        map<Id,list<Opportunity>> accountDeptOptyMap=new map<Id,list<Opportunity>>();
        //looped through the contract to find the account department ids
        Id ONEPRECTYPEID = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(CONTRACT1PRECTYPE).getRecordTypeId();
        system.debug('ONEPRECTYPEID===========>'+ONEPRECTYPEID);
        for(Contract__c eachContract: newContractList){
            system.debug('eachContract.recordType.Name===========>'+eachContract.recordType.Name);
            system.debug('eachContract.recordType.DeveloperName===========>'+eachContract.recordType.DeveloperName);
            if(ONEPRECTYPEID.equals(eachContract.recordTypeId) && eachContract.Account_Department_ID__c!=null){
               accountDeptOptyMap.put(eachContract.Account_Department_ID__c,new list<Opportunity>()); 
            }
        }
        
        //Fetched all the opportunities based on Account Department
        if(accountDeptOptyMap!=null && !accountDeptOptyMap.KeySet().isEmpty()){
           for(Opportunity eachOpty : [SELECT Id,
                                        Opportunity_Type__c,
                                        Active_DSV_Contracts__c,
                                        Active_OWNED_Contracts__c,
                                        StageName,
                                        Wal_Account_Department__c 
                                        FROM Opportunity 
                                        WHERE 
                                        Wal_Account_Department__c IN: accountDeptOptyMap.KeySet()
                                        AND StageName =: WAITINGCONTRACT]){
                if(accountDeptOptyMap.get(eachOpty.Wal_Account_Department__c)!=null){
                    accountDeptOptyMap.get(eachOpty.Wal_Account_Department__c).add(eachOpty);
                }
            }
        }
        system.debug('accountDeptOptyMap===========>'+accountDeptOptyMap);
        list<Opportunity> updateOpportunityList=new list<Opportunity>();
        for(Contract__c eachContract: newContractList){
            if(ONEPRECTYPEID.equals(eachContract.recordTypeId)
                && eachContract.Account_Department_ID__c!=null 
                && accountDeptOptyMap.get(eachContract.Account_Department_ID__c)!=null){
               for(Opportunity eachOpty : accountDeptOptyMap.get(eachContract.Account_Department_ID__c)){
                   if(DSV.equals(eachOpty.Opportunity_Type__c) && DSV.equals(eachContract.Contract_Type__c)){
                       eachOpty.StageName=SUPPLYCHAIN;
                       updateOpportunityList.add(eachOpty);    
                   }
                   if(OWNED.equals(eachOpty.Opportunity_Type__c) && VENDOR.equals(eachContract.Contract_Type__c)){
                       eachOpty.StageName=SUPPLYCHAIN; 
                       updateOpportunityList.add(eachOpty);     
                   }
                   if(BOTH.equals(eachOpty.Opportunity_Type__c) && eachOpty.Active_DSV_Contracts__c>0 && VENDOR.equals(eachContract.Contract_Type__c)){
                       eachOpty.StageName=SUPPLYCHAIN; 
                       updateOpportunityList.add(eachOpty);     
                   }
                   if(BOTH.equals(eachOpty.Opportunity_Type__c) && eachOpty.Active_OWNED_Contracts__c>0 && DSV.equals(eachContract.Contract_Type__c)){
                       eachOpty.StageName=SUPPLYCHAIN; 
                       updateOpportunityList.add(eachOpty);     
                   }
               }
            }
        }
        system.debug('updateOpportunityList======>'+updateOpportunityList);
        if(updateOpportunityList!=null && !updateOpportunityList.isEmpty()){
            Database.SaveResult[] updateOpportunityResult = Database.update(updateOpportunityList, false);
            for (Database.SaveResult sr : updateOpportunityResult) {
                if (sr.isSuccess()) {
                    system.debug('Successfully updated Opportunity record with Id=========>' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()){
                        System.debug('Following error has occurred while updating Opportunity');
                        System.debug('Error Message=====>'+err.getMessage());
                    }
                }
            }
        }
    }
}