global class UpdateEngineerMappingBatch implements Database.Batchable<Sobject>,Database.Stateful{
    global map<Id,Engineer_Mapping__c>mapUserIdWiseEngineerMapping = new map<id,Engineer_Mapping__c>();
    global UpdateEngineerMappingBatch(){
        System.debug('@Developer --> UpdateEngineerMapping -->');
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        System.debug('@Developer --> UpdateEngineerMapping --> start --> timestamp:' + system.now());
        set<Id>setUserId = new set<Id>();
        set<string>setSellerOnboardingStatus = new set<string>();
        setSellerOnboardingStatus.add('Pre Seller Setup');
        setSellerOnboardingStatus.add('Seller Setup');
        setSellerOnboardingStatus.add('Item Setup');
        setSellerOnboardingStatus.add('Transaction Readiness');
        setSellerOnboardingStatus.add('Launch Readiness');
        for(Engineer_Mapping__c oEM:[Select Id,User__c,User__r.Name,Percentage__c,No_of_Accounts_working_on__c,User_Type__c,Integration_Channel__c,Maximum__c,(Select Id, Name, Engineer_Mapping__c From Engineer_Accounts__r)From Engineer_Mapping__c where Active__c =true]){
            setUserId.add(oEM.User__c);
            oEM.No_of_Accounts_working_on__c= 0;
            mapUserIdWiseEngineerMapping.put(oEM.User__c,oEM);
        }
        string sSOQL = 'Select Seller_Onboarding_Status__c, Seller_Liaison__c, Name, Integration_Engineer__c,Id From Account where Seller_Onboarding_Status__c in:setSellerOnboardingStatus and (Integration_Engineer__c in:setUserId or Seller_Liaison__c in:setUserId)';
        System.debug('@Developer --> sSOQL:' + sSOQL);   
        return Database.getQueryLocator(sSOQL);
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        System.debug('@Developer --> UpdateEngineerMapping --> execute --> timestamp:' + system.now());
        for(Account oAccount:scope){
            if(mapUserIdWiseEngineerMapping.containsKey(oAccount.Integration_Engineer__c)){
                Engineer_Mapping__c oEM = mapUserIdWiseEngineerMapping.get(oAccount.Integration_Engineer__c);
                oEM.No_of_Accounts_working_on__c++;
                mapUserIdWiseEngineerMapping.put(oAccount.Integration_Engineer__c,oEM);
            }
            if(mapUserIdWiseEngineerMapping.containsKey(oAccount.Seller_Liaison__c)){
                Engineer_Mapping__c oEM = mapUserIdWiseEngineerMapping.get(oAccount.Seller_Liaison__c);
                oEM.No_of_Accounts_working_on__c++;
                mapUserIdWiseEngineerMapping.put(oAccount.Seller_Liaison__c,oEM);
            }
        }
    }      
    global void finish(Database.BatchableContext bc){
        System.debug('@Developer --> UpdateEngineerMapping --> finish --> timestamp:' + system.now());   
        if(mapUserIdWiseEngineerMapping.size()>0){
            update mapUserIdWiseEngineerMapping.values();
        }  
    }
}