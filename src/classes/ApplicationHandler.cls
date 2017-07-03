public class ApplicationHandler {
    public static void afterInsert(list<Application__c> triggerNew){
        System.debug('@Developer -->afterInsert:' );
        set<Id> setOppId = new set<Id>();
        for(Application__c oApplication :triggerNew){
            if(oApplication.Opportunity__c!=null){
                setOppId.add(oApplication.Opportunity__c);
            }
        }
        System.debug('@Developer -->setOppId:'+setOppId );
        if(setOppId.size()>0){
            map<Id,Opportunity> mapApplicationWiseOpp = new map<Id,Opportunity>();
            list<Opportunity> lstOpportunityToUpdate = [Select id,Preferred_integration_General__c,Preferred_integration_Specific__c,Third_Party_integration_specifics__c From Opportunity Where id in : setOppId];
            for(Opportunity oOpportunity:lstOpportunityToUpdate){
                mapApplicationWiseOpp.put(oOpportunity.Id,oOpportunity);
            }
            for(Application__c oApplication :triggerNew){
                if(oApplication.Opportunity__c!=null){
                    Opportunity oOpportunity = mapApplicationWiseOpp.get(oApplication.Opportunity__c);
                    
                    if(oApplication.Preferred_integration_General__c!=null && oApplication.Preferred_integration_General__c=='Channel Aggregator' && oApplication.Preferred_integration_Specific__c!=null && oApplication.Preferred_integration_Specific__c=='Other'){
                        oOpportunity.Preferred_integration_General__c=oApplication.Preferred_integration_General__c;
                        oOpportunity.Preferred_integration_Specific__c='Unknown Partner';
                        oOpportunity.Third_Party_integration_specifics__c=oApplication.Third_Party_integration_specifics__c;
                    }
                    else{
                        oOpportunity.Preferred_integration_General__c = oApplication.Preferred_integration_General__c;
                        oOpportunity.Preferred_integration_Specific__c = oApplication.Preferred_integration_Specific__c;
                    }
                }
                
            }
            update lstOpportunityToUpdate;
        }
    }
    
    public static void beforeUpdate(list<Application__c> triggerNew,map<Id,Application__c> oldMap){
        System.debug('@Developer -->before update:' );
        set<Id> setLeadId = new set<Id>();
        map<Id,Id> mapLeadWiseApplication = new map<Id,Id>();
        for(Application__c oApplication :triggerNew){
            if(oApplication.Lead__c !=null && oApplication.Application_Completed__c==true && oApplication.Application_Completed__c!=oldMap.get(oApplication.Id).Application_Completed__c){
                setLeadId.add(oApplication.Lead__c);
                mapLeadWiseApplication.put(oApplication.Lead__c,oApplication.Id);
            }
        }
        
        if(setLeadId.size()>0){
            List<Database.LeadConvert> lstLeadConvert = new List<Database.LeadConvert>();
            for(Lead oLead:[Select Id,Webtolead__c From Lead Where Id in :setLeadId]){
                Database.LeadConvert oLeadConvert = new Database.LeadConvert();
                            oLeadConvert.setLeadId(oLead.id);
                            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                            oLeadConvert.setConvertedStatus(convertStatus.MasterLabel);
                            lstLeadConvert.add(oLeadConvert);
            }
            if(lstLeadConvert.size()>0){
                List<Database.LeadConvertResult> lstResult = Database.convertLead(lstLeadConvert,true);
                
                system.debug('@developer -->lstResult :'+lstResult);
                map<Id,Database.LeadConvertResult> mapLeadIdWiseConvertResult = new map<Id,Database.LeadConvertResult>();
                set<Id> setSuccessApplications = new set<Id>();
                for(Database.LeadConvertResult oLeadResult:lstResult){
                    if(oLeadResult.IsSuccess()){
                        Id LeadId = oLeadResult.getLeadID();
                        mapLeadIdWiseConvertResult.put(LeadId,oLeadResult);
                        if(mapLeadWiseApplication.containsKey(LeadId)){
                            setSuccessApplications.add(mapLeadWiseApplication.get(LeadId));
                        }
                    }
                    else{
                        List<string> lstErrorMsg = new List<string>();
                        for(Database.Error err : oLeadResult.getErrors()) {
                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                        lstErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                                        //System.debug('fields that affected this error: ' + err.getFields());
                                    }
                                    
                        throw new ConvertLeadException(string.join(lstErrorMsg,'\n'));
                    }
                }
                map<Id,Application__c> mapIdWiseApplication = new map<Id,Application__c>();
                for(Application__c oApplication:[Select Id,(Select Id, Opportunity__c From ApplicationCategories__r) From Application__c Where Id in :setSuccessApplications]){
                    mapIdWiseApplication.put(oApplication.Id,oApplication);
                }
                
                list<Opportunity> lstOpportunityToUpdate = new list<Opportunity>();
                list<ApplicationCategories__c> lstApplicationCategoriesToUpdate = new list<ApplicationCategories__c>();
                list<Contact> lstSecondaryContacts = new list<Contact>();
                list<Contact> lstPrimaryContactsToUpdate = new list<Contact>();
                for(Application__c oApplication :triggerNew){
                    if(oApplication.Lead__c !=null && oApplication.Application_Completed__c==true && oApplication.Application_Completed__c!=oldMap.get(oApplication.Id).Application_Completed__c){
                        if(mapLeadIdWiseConvertResult.containsKey(oApplication.Lead__c)){
                            Database.LeadConvertResult oLeadResult = mapLeadIdWiseConvertResult.get(oApplication.Lead__c);
                            oApplication.Account__c = oLeadResult.getAccountId();
                            oApplication.Opportunity__c = oLeadResult.getOpportunityId();
                            Opportunity oOpportunity = new Opportunity();
                            oOpportunity.Id = oApplication.Opportunity__c;
                            oOpportunity.Application_Sent__c = true;
                            lstOpportunityToUpdate.add(oOpportunity);
                            
                            if(oApplication.Same_as_Primary_Contact__c!=true && oApplication.Secondary_Contact_Last_Name__c!=null){
                                Contact oContact = new Contact();
                                oContact.Contact_Type__c = 'IT/Technical';
                                 oContact.FirstName = oApplication.Secondary_Contact_First_Name__c;
                                 oContact.LastName = oApplication.Secondary_Contact_Last_Name__c;
                                                oContact.Email = oApplication.Secondary_Contact_Email__c;
                                                oContact.Phone = oApplication.Secondary_Contact_Phone__c;
                                                oContact.Extension__c = oApplication.Secondary_Contact_Ext__c;
                                                oContact.MobilePhone = oApplication.Secondary_Contact_Mobile__c;
                                                if(oApplication.Permission_to_text__c){
                                                    oContact.Permission_to_text_for_notification__c = 'Yes';
                                                }
                                                else{
                                                    oContact.Permission_to_text_for_notification__c = 'No';
                                                }
                                 oContact.AccountId = oApplication.Account__c;
                                
                                lstSecondaryContacts.add(oContact);
                            }
                            else if(oApplication.Same_as_Primary_Contact__c==true){
                                Contact oPrimaryContact = new Contact();
                                oPrimaryContact.Id = oLeadResult.getContactId();
                                oPrimaryContact.Contact_Type__c = 'Marketplace Business Manager;IT/Technical';
                                lstPrimaryContactsToUpdate.add(oPrimaryContact);
                            }
                            
                            if(mapIdWiseApplication.containsKey(oApplication.Id)){
                                Application__c oSuccessApplication = mapIdWiseApplication.get(oApplication.Id);
                                if(oSuccessApplication.ApplicationCategories__r!=null){
                                    for(ApplicationCategories__c oApplicationCategories:oSuccessApplication.ApplicationCategories__r){
                                        oApplicationCategories.Opportunity__c = oOpportunity.Id;
                                        lstApplicationCategoriesToUpdate.add(oApplicationCategories);
                                    }
                                }
                            }
                        }
                    }
                }
                if(lstOpportunityToUpdate.size()>0){
                    update lstOpportunityToUpdate;
                }
                if(lstApplicationCategoriesToUpdate.size()>0){
                    update lstApplicationCategoriesToUpdate;
                }
                if(lstSecondaryContacts.size()>0){
                    insert lstSecondaryContacts;
                }
                if(lstPrimaryContactsToUpdate.size()>0){
                    update lstPrimaryContactsToUpdate;
                }
            }
        }
    }
    
    public static void AfterUpdate(list<Application__c> triggerNew,map<Id,Application__c> oldMap){
        for(Application__c oApplication :triggerNew){
            if(oApplication.Lead__c !=null && oApplication.Application_Completed__c==true && oApplication.Application_Completed__c!=oldMap.get(oApplication.Id).Application_Completed__c){
                Application_Seller_Link.link(oApplication.Id, null);
            }
        }
    }
    
    class ConvertLeadException extends Exception {}
}