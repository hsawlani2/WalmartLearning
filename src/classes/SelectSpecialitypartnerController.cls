public with sharing class SelectSpecialitypartnerController {
    public string sRecordID{get;set;}
    public string sType{get;set;}
    public list<IntegrationMethodWrapper> lstSpecialitypartnerWrapper{get;set;}
    public list<string> lstExistingSpecialitypartner{get;set;}
    public string sSelectedSpecialitypartnerIds{get;set;}
    public string sSelectedSpecialitypartner{get;set;}
    public SelectSpecialitypartnerController(){
    	
    	sType=ApexPages.currentPage().getParameters().get('type');
    	if(sType==null ||(sType!='account' && sType!='application' && sType!='opportunity' )){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Type.'));
    		return;
    	}
    	sRecordID = ApexPages.currentPage().getParameters().get('Id');
    	if(sRecordID==null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Id is null.'));
    	}
    	else{
	    	if(sType=='account'){
		    	fetchAccountData();
	    	}
            else if(sType=='opportunity'){
                fetchOpportunityData();
            }
	    	else if(sType=='application'){
		    	fetchApplicationData();
	    	}
    		lstSpecialitypartnerWrapper = new list<IntegrationMethodWrapper>();
    		for(Account oAccount : [Select Id,Name From Account Where RecordType.DeveloperName ='Partner_Account' and Partner_Type__c='Specialty Partner' and (Partner_Onboarding_Status__c = 'Live' or Partner_Onboarding_Status__c = 'Pilot')]){
	    		lstSpecialitypartnerWrapper.add(new IntegrationMethodWrapper(oAccount.Id,oAccount.Name));
	    	}
	    	system.debug('@developer --> lstSpecialitypartnerWrapper:'+lstSpecialitypartnerWrapper);
    	}
    }
    
    private void fetchAccountData(){
    	lstExistingSpecialitypartner = new list<string>();
					for(Account oAccount:[SELECT id,SpecialitypartnerIds__c FROM Account where id=:sRecordID]){
						sSelectedSpecialitypartnerIds = oAccount.SpecialitypartnerIds__c;
						if(sSelectedSpecialitypartnerIds!=null && sSelectedSpecialitypartnerIds!=''){
							for(string sId : sSelectedSpecialitypartnerIds.split(',')){
								if(sId!=null && sId!=''){
									lstExistingSpecialitypartner.add(sId);
								}
							}
						}
					}
    }
    private void fetchOpportunityData(){
        lstExistingSpecialitypartner = new list<string>();
                    for(Opportunity oOpportunity:[SELECT id,SpecialitypartnerIds__c FROM Opportunity where id=:sRecordID]){
                        sSelectedSpecialitypartnerIds = oOpportunity.SpecialitypartnerIds__c;
                        if(sSelectedSpecialitypartnerIds!=null && sSelectedSpecialitypartnerIds!=''){
                            for(string sId : sSelectedSpecialitypartnerIds.split(',')){
                                if(sId!=null && sId!=''){
                                    lstExistingSpecialitypartner.add(sId);
                                }
                            }
                        }
                    }
    }
    private void fetchApplicationData(){
    	lstExistingSpecialitypartner = new list<string>();
					for(Application__c oApplication:[SELECT id,SpecialitypartnerIds__c FROM Application__c where id=:sRecordID]){
						sSelectedSpecialitypartnerIds = oApplication.SpecialitypartnerIds__c;
						if(sSelectedSpecialitypartnerIds!=null && sSelectedSpecialitypartnerIds!=''){
							for(string sId : sSelectedSpecialitypartnerIds.split(',')){
								if(sId!=null && sId!=''){
									lstExistingSpecialitypartner.add(sId);
								}
							}
						}
					}
    }
    
    public PageReference save(){
    	system.debug('@developer --> sSelectedSpecialitypartnerIds:'+sSelectedSpecialitypartnerIds);
    	system.debug('@developer --> sSelectedSpecialitypartner:'+sSelectedSpecialitypartner);
    	//Specialitypartner__c,SpecialitypartnerIds__c
    	if(sSelectedSpecialitypartner!=null && sSelectedSpecialitypartner!=''){
    		if(sSelectedSpecialitypartner.endsWith(',')){
    			sSelectedSpecialitypartner = sSelectedSpecialitypartner.left(sSelectedSpecialitypartner.length()-1);
    		}
    		if(sSelectedSpecialitypartner.length()>255){
    			sSelectedSpecialitypartner = sSelectedSpecialitypartner.left(252)+'...';
    		}
    	}
    	
    	if(sSelectedSpecialitypartnerIds!=null && sSelectedSpecialitypartnerIds!=''){
    		if(sSelectedSpecialitypartnerIds.endsWith(',')){
    			sSelectedSpecialitypartnerIds = sSelectedSpecialitypartnerIds.left(sSelectedSpecialitypartnerIds.length()-1);
    		}
    	}
    	
    	if(sType=='account'){
    		Account oAccount = new Account();
    		oAccount.Id=sRecordID;
    		oAccount.Specialitypartner__c = (sSelectedSpecialitypartner=='')?null:sSelectedSpecialitypartner;
    		oAccount.SpecialitypartnerIds__c = (sSelectedSpecialitypartnerIds=='')?null:sSelectedSpecialitypartnerIds;
    		update oAccount;
    	}
        else if(sType=='opportunity'){
            Opportunity oOpportunity = new Opportunity();
            oOpportunity.Id=sRecordID;
            oOpportunity.Specialitypartner__c = (sSelectedSpecialitypartner=='')?null:sSelectedSpecialitypartner;
            oOpportunity.SpecialitypartnerIds__c = (sSelectedSpecialitypartnerIds=='')?null:sSelectedSpecialitypartnerIds;
            update oOpportunity;
        }
    	else if(sType=='application'){
    		Application__c oApplication = new Application__c();
    		oApplication.Id=sRecordID;
    		oApplication.Specialitypartner__c = (sSelectedSpecialitypartner=='')?null:sSelectedSpecialitypartner;
    		oApplication.SpecialitypartnerIds__c = (sSelectedSpecialitypartnerIds=='')?null:sSelectedSpecialitypartnerIds;
    		update oApplication;
    	}
    	
    	return new PageReference('/'+sRecordID);
    }
}