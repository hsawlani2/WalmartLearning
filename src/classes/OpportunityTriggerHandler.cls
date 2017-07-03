public class OpportunityTriggerHandler {

    public static boolean isUpdating=false;
    
   
    public void beforeUpdate(List<Opportunity> opportunityList, Map<Id,Opportunity> oldOpportunityMap){
         //Added MP record type
         string OPTYMPRECTYPE='MP Opportunity';
         Id MPRECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPTYMPRECTYPE).getRecordTypeId();
         for (Opportunity anOpp : opportunityList) {
                if(anOpp.RecordTypeId==MPRECTYPEID && oldOpportunityMap.get(anOpp.Id).RecordTypeId==MPRECTYPEID && oldOpportunityMap.get(anOpp.Id).StageName =='Closed Won' && (anOpp.Preferred_integration_General__c != oldOpportunityMap.get(anOpp.Id).Preferred_integration_General__c )){
                 anOpp.addError('Preferred integration - General not updatable when the stage is Closed Won. Update the fields in Account');    
                }

                if(anOpp.RecordTypeId==MPRECTYPEID && oldOpportunityMap.get(anOpp.Id).RecordTypeId==MPRECTYPEID && oldOpportunityMap.get(anOpp.Id).StageName =='Closed Won' && (anOpp.Preferred_integration_Specific__c != oldOpportunityMap.get(anOpp.Id).Preferred_integration_Specific__c )){
                 anOpp.addError('Preferred integration - Specific not updatable when the stage is Closed Won. Update the fields in Account');    
                }
         }
    }        
    public void afterInsert(List<Opportunity> opportunityList) {
        
        Map<String, String> oppContactMap = new Map<String, String>();
        
        // collect account ids
        Map<String, Opportunity> accountOppMap = new Map<String, Opportunity>();
        List<String> accountIds = new List<String>();
        List<String> oppIds = new List<String>();
        
        for (Opportunity anOpp : opportunityList) {
            oppIds.add(anOpp.Id);
            accountIds.add(anOpp.AccountId);    
            accountOppMap.put(anOpp.AccountId, anOpp);
        }
        
        List<Account> accountList = [SELECT Id, Primary_Contact__c FROM Account WHERE ID IN :accountIds];
        for (Account fetchedAccount : accountList) {
            
            if (fetchedAccount.Primary_Contact__c != null) {
                //Contact primaryContact = [SELECT Id FROM Contact WHERE ID = :fetchedAccount.Primary_Contact__c];
                //if (primaryContact != null) {
                    if (accountOppMap.containsKey(fetchedAccount.Id)) {
                        Opportunity theOpp = accountOppMap.get(fetchedAccount.Id);
                        oppContactMap.put(theOpp.Id, fetchedAccount.Primary_Contact__c);
                    }
                    
                //}
            }
            
        }
        
        List<Opportunity> fetchedOpps = [SELECT Id, Primary_Contact__c FROM Opportunity WHERE Id IN :oppIds];
        
        // update the opportunities
        for (Opportunity anOpp : fetchedOpps) {
            String oppId = anOpp.Id;
            if (oppContactMap.containsKey(oppId)) {
                String contactId = oppContactMap.get(anOpp.Id);
                anOpp.Primary_Contact__c = contactId;
            }
        }
        
        update fetchedOpps;
        
    }
    

    
    public void afterUpdate(list<Opportunity> triggerNew,Map<Id, Opportunity> oldMap){
        //Added MP record type
        string OPTYMPRECTYPE='MP Opportunity';
        Id MPRECTYPEID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPTYMPRECTYPE).getRecordTypeId();
        set<Id> setAccountId = new set<Id>();
        Set<Id> OpportunitySetId = new Set<Id>();
        for(Opportunity oOpportunity: [SELECT Id,StageName,RecordTypeId,Account.Catalog_Size__c from Opportunity where Id IN : triggerNew]){
            
            if(oOpportunity.RecordTypeId==MPRECTYPEID && oOpportunity.StageName !=null && oOpportunity.StageName=='Closed Won' && (oldMap.get(oOpportunity.Id).StageName!=oOpportunity.StageName) && oOpportunity.AccountId!=null){
                setAccountId.add(oOpportunity.AccountId);
                OpportunitySetId.add(oOpportunity.Id);
            }
            
        }
        
        
        if(setAccountId.size()>0){
            list<Account> lstAccount = [Select id,Integration_Channel__c,Integration_Method__c,Seller_Onboarding_Status__c,Type,Catalog_Size__c  From Account Where id in : setAccountId];
            map<Id,Account> mapIdWiseAccount = new map<Id,Account>();
            for(Account oAccount:lstAccount){
                mapIdWiseAccount.put(oAccount.Id,oAccount);
            }
            //for(Opportunity oOpportunity:triggerNew){
            
            for(Opportunity oOpportunity : [SELECT Id,AccountId,Account.Catalog_Size__c,Preferred_integration_Specific__c,Preferred_integration_General__c,SpecialitypartnerIds__c,Preferred_integration_Specific_Id__c,Specialitypartner__c,  (Select Id, No_of_SKU_s_to_be_sold_at_Walmart__c from AppliationCategories__r) from Opportunity where Id IN : OpportunitySetId]){
                //if(oOpportunity.RecordTypeId==MPRECTYPEID && oOpportunity.StageName !=null && oOpportunity.StageName=='Closed Won' && (oldMap.get(oOpportunity.Id).StageName!=oOpportunity.StageName) && oOpportunity.AccountId!=null){
                    Account oAccount=mapIdWiseAccount.get(oOpportunity.AccountId);
                    
                    oAccount.Seller_Onboarding_Status__c ='Closed';
                    oAccount.Type ='Seller';
                    oAccount.Specialitypartner__c = oOpportunity.Specialitypartner__c;
                    if(oOpportunity.SpecialitypartnerIds__c != null){
                         oAccount.SpecialitypartnerIds__c = oOpportunity.SpecialitypartnerIds__c ;
                    }
                                                           
                    if(oOpportunity.Preferred_integration_General__c=='Partner' && oOpportunity.Preferred_integration_Specific__c =='Other'){
                    
                        oAccount.Integration_Channel__c='Partner';
                        oAccount.Integration_Method__c= 'Unknown Partner';
                        oAccount.IntegrationMethodId__c= Null;
                        }                    
                    else{
                        oAccount.Integration_Channel__c = oOpportunity.Preferred_integration_General__c;
                        oAccount.Integration_Method__c= oOpportunity.Preferred_integration_Specific__c;  
                            if(oOpportunity.Preferred_integration_Specific_Id__c != null){
                             oAccount.IntegrationMethodId__c = oOpportunity.Preferred_integration_Specific_Id__c;
                            }  
                        }
                    
                    
                    
                    if(oOpportunity .AppliationCategories__r.size() > 0 ){
                        Decimal catalogSize = 0;
                        for(ApplicationCategories__c appCat : oOpportunity .AppliationCategories__r){
                        if(appCat.No_of_SKU_s_to_be_sold_at_Walmart__c != null){
                            catalogSize += appCat.No_of_SKU_s_to_be_sold_at_Walmart__c;
                        }
                    
                    }
                    if(catalogSize != 0){
                        //accountList.add(new Account(Id=opp.AccountId,Catalog_Size__c = catalogSize));
                        oAccount.Catalog_Size__c = catalogSize;
                    }else{
                        //accountList.add(new Account(Id=opp.AccountId,Catalog_Size__c = 1000));
                        oAccount.Catalog_Size__c = 1000;
                    }
                    
                    }else{
                        //accountList.add(new Account(Id=opp.AccountId,Catalog_Size__c = 1000));
                        oAccount.Catalog_Size__c = 1000;
                    }
                //}
            }
            update lstAccount;
            system.debug('integration channel'+lstAccount[0].Integration_Channel__c);
        }
    }
    
}