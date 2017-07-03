public with sharing class IntegrationLookupController {
    public string sRecordID{get;set;}
    public string sType{get;set;}
    public List<SelectOption> lstIntegrationChannel{get;set;}
    public string sSelectedIntegrationChannel{get;set;}
    public string sSelectedIntegrationMethod{get;set;}
    public string sSelectedIntegrationMethodId{get;set;}
    public List<IntegrationMethodWrapper> lstIntegrationMethodList{get;set;}
    public IntegrationLookupController(){
        
        sType=ApexPages.currentPage().getParameters().get('type');
        if(sType==null ||(sType!='account' && sType!='opportunity' && sType!='application')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Type.'));
            return;
        }
        sRecordID = ApexPages.currentPage().getParameters().get('Id');
        if(sRecordID==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Id is null.'));
        }
        else{
            lstIntegrationChannel = new List<SelectOption>();
            lstIntegrationChannel.add(new SelectOption('','--None--'));
            
            if(sType=='account'){
                fetchAccountData();
            }
            else if(sType=='opportunity'){
                fetchOpportunityData();
            }
            else if(sType=='application'){
                fetchApplicationData();
            }
            FetchIntegrationMethods();
        }
    }
    
     private void fetchAccountData(){
        for( Schema.PicklistEntry f : Account.Integration_Channel__c.getDescribe().getPicklistValues()){
            //system.debug('@develoepr -->f :'+f);
          lstIntegrationChannel.add(new SelectOption(f.getValue(),f.getLabel()));
        }
                    for(Account oAccount:[SELECT id,Integration_Channel__c,Integration_Method__c,IntegrationMethodId__c FROM Account where id=:sRecordID]){
                        sSelectedIntegrationChannel = oAccount.Integration_Channel__c;
                        sSelectedIntegrationMethod =  oAccount.Integration_Method__c;
                        sSelectedIntegrationMethodId = oAccount.IntegrationMethodId__c;
                    }
    }
    private void fetchOpportunityData(){
        for( Schema.PicklistEntry f : Opportunity.Preferred_integration_General__c.getDescribe().getPicklistValues()){
            //system.debug('@develoepr -->f :'+f);
          lstIntegrationChannel.add(new SelectOption(f.getValue(),f.getLabel()));
        }
                    
                    for(Opportunity oOpportunity:[SELECT id,Preferred_integration_General__c,Preferred_integration_Specific__c,Preferred_integration_Specific_Id__c FROM Opportunity where id=:sRecordID]){
                        sSelectedIntegrationChannel = oOpportunity.Preferred_integration_General__c;
                        sSelectedIntegrationMethod =  oOpportunity.Preferred_integration_Specific__c;
                        sSelectedIntegrationMethodId = oOpportunity.Preferred_integration_Specific_Id__c;
                    }
    }
    private void fetchApplicationData(){
        for( Schema.PicklistEntry f : Application__c.Preferred_integration_General__c.getDescribe().getPicklistValues()){
            //system.debug('@develoepr -->f :'+f);
          lstIntegrationChannel.add(new SelectOption(f.getValue(),f.getLabel()));
        }
                    for(Application__c oApplication:[SELECT id,Preferred_integration_General__c,Preferred_integration_Specific__c,Preferred_integration_Specific_Id__c FROM Application__c where id=:sRecordID]){
                        sSelectedIntegrationChannel = oApplication.Preferred_integration_General__c;
                        sSelectedIntegrationMethod =  oApplication.Preferred_integration_Specific__c;
                        sSelectedIntegrationMethodId = oApplication.Preferred_integration_Specific_Id__c;
                    }
    }
    
    
    public void FetchIntegrationMethods(){
        lstIntegrationMethodList = new List<IntegrationMethodWrapper>();
        if(sSelectedIntegrationChannel=='Direct'){
            set<string> setIntegrationMethodDirect = new set<string>();
            List<IntegrationMethodDirectMapping__c> lstIntegrationMethodDirectMapping = IntegrationMethodDirectMapping__c.getAll().values();
            if(lstIntegrationMethodDirectMapping!=null && lstIntegrationMethodDirectMapping.size()>0){
                for(IntegrationMethodDirectMapping__c oIntegrationMethodDirectMapping:lstIntegrationMethodDirectMapping){
                    if(oIntegrationMethodDirectMapping.IsActive__c){
                        setIntegrationMethodDirect.add(oIntegrationMethodDirectMapping.MethodName__c);
                    }
                }
            }
            system.debug('setIntegrationMethodDirect:'+setIntegrationMethodDirect);
            for( Schema.PicklistEntry f : Account.Integration_Method__c.getDescribe().getPicklistValues()){
                string sValue = f.getValue();
                if(setIntegrationMethodDirect.contains(sValue)){
            lstIntegrationMethodList.add(new IntegrationMethodWrapper(null,sValue));
                }
            }
        }
        else if((sSelectedIntegrationChannel=='Partner')||(sSelectedIntegrationChannel=='Channel Aggregator')){
            //The we would query Accounts which are of Channel partner record type.And the partner type field will be Future Service partner and their partner onboarding status field will be Live and pilot.
            for(Account oAccount : [Select Id,Name From Account Where RecordType.DeveloperName ='Partner_Account' and Partner_Type__c='Full Service Partner' and (Partner_Onboarding_Status__c = 'Live' or Partner_Onboarding_Status__c = 'Pilot')]){
                lstIntegrationMethodList.add(new IntegrationMethodWrapper(oAccount.Id,oAccount.Name));
            }
        }
        else{
            lstIntegrationMethodList.add(new IntegrationMethodWrapper('','None'));
        }
    }
    
    public PageReference selectIntegrationMethod(){
        if(sType=='account'){
            UpdateAccount();
        }
        else if(sType=='opportunity'){
            UpdateOpportunity();
        }
        else if(sType=='application'){
            UpdateApplication();
        }
        return new PageReference('/'+sRecordID);
    }
    
    private void UpdateAccount(){
        if(sSelectedIntegrationChannel=='' ||sSelectedIntegrationChannel=='Direct'){
            sSelectedIntegrationMethodId = null;
        }
        Account oAccount=new Account();
        oAccount.Id = sRecordID;
        oAccount.Integration_Channel__c = (sSelectedIntegrationChannel=='')?null:sSelectedIntegrationChannel;
        oAccount.Integration_Method__c = (sSelectedIntegrationMethod=='' || sSelectedIntegrationMethod=='None')?null:sSelectedIntegrationMethod;
        oAccount.IntegrationMethodId__c = (sSelectedIntegrationMethodId=='')?null:sSelectedIntegrationMethodId;
        system.debug('@developer -->sSelectedIntegrationMethod:'+sSelectedIntegrationMethod);
        update oAccount;
    }
    
     private void UpdateOpportunity(){
        if(sSelectedIntegrationChannel=='' ||sSelectedIntegrationChannel=='Direct'){
            sSelectedIntegrationMethodId = null;
        }
        Opportunity oOpportunity = new Opportunity();
        oOpportunity.Id = sRecordID;
        oOpportunity.Preferred_integration_General__c = (sSelectedIntegrationChannel=='')?null:sSelectedIntegrationChannel;
        system.debug('@developer -->sSelectedIntegrationMethod:'+sSelectedIntegrationMethod);
        oOpportunity.Preferred_integration_Specific__c = (sSelectedIntegrationMethod=='' || sSelectedIntegrationMethod=='None')?null:sSelectedIntegrationMethod;
        oOpportunity.Preferred_integration_Specific_Id__c = (sSelectedIntegrationMethodId=='')?null:sSelectedIntegrationMethodId;
        
        update oOpportunity;
    }
    
     private void UpdateApplication(){
        if(sSelectedIntegrationChannel=='' ||sSelectedIntegrationChannel=='Direct'){
            sSelectedIntegrationMethodId = null;
        }
        Application__c oApplication = new Application__c();
        oApplication.Id = sRecordID;
        oApplication.Preferred_integration_General__c = (sSelectedIntegrationChannel=='')?null:sSelectedIntegrationChannel;
        oApplication.Preferred_integration_Specific__c = (sSelectedIntegrationMethod=='' || sSelectedIntegrationMethod=='None')?null:sSelectedIntegrationMethod;
        oApplication.Preferred_integration_Specific_Id__c = (sSelectedIntegrationMethodId=='')?null:sSelectedIntegrationMethodId;
        system.debug('@developer -->sSelectedIntegrationMethod:'+sSelectedIntegrationMethod);
        update oApplication;
    }
    
    
}