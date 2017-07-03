public class AccountTriggerHandler {
    
    public static boolean isUpdating=false;
    Map<String , Account_Custom_Settings__c> acs2 = Account_Custom_Settings__c.getAll();
    Map<String, Account_Setting_Metadata__mdt> asmMap = new Map<String, Account_Setting_Metadata__mdt>();
    List<Account_Setting_Metadata__mdt > asmList = [SELECT a.QualifiedApiName, a.Matching_Configured_Data_Category__c, 
                        a.Matching_Configured_Partner_Space__c, a.Matching_Configured_KB_Category_Value__c, 
                        a.Account_Record_Type_DeveloperName__c, a.MasterLabel, a.Label, a.Id, a.DeveloperName 
                        FROM Account_Setting_Metadata__mdt a
                        ];
    Map<ID, RecordType> rtMap = new Map<ID, RecordType>(
                        [SELECT Id, DeveloperName, SObjectType FROM RecordType 
                            WHERE IsActive=true and SObjectType = 'Account']);

    public void beforeInsert(list<Account> lstAccount){
        // Build the map for Record Type DeveloperName to KB Category value using configured Metadata.
        for(Account_Setting_Metadata__mdt asmRow : asmList){
            if(!String.isEmpty(asmRow.Account_Record_Type_DeveloperName__c)){
                asmMap.put(asmRow.Account_Record_Type_DeveloperName__c, asmRow);
            }
        }

        for (Account acctRow : lstAccount){
            if(asmMap.containsKey(rtMap.get(acctRow.RecordTypeId).DeveloperName)){
                acctRow.KB_Category_Visibility__c = asmMap.get(rtMap.get(acctRow.RecordTypeId).DeveloperName).Matching_Configured_KB_Category_Value__c;
            }
        }
        asmMap.clear(); //Clearing for reuse in other methods.  
    }
    
    public void beforeUpdatePartners(List<Account> lstAccount, Map<Id,Account> newAccountMap){
        // update the KB_Category_Visibility__C field.
        List<String> cleanPartnerSpaceValues, cleanKbCategoryValues;

        // Build the map for Partner Space to KB Category value using configured Metadata.
        for(Account_Setting_Metadata__mdt asmRow : asmList){
            if(!String.isEmpty(asmRow.Matching_Configured_Partner_Space__c)){
                asmMap.put(asmRow.Matching_Configured_Partner_Space__c, asmRow);
            }
        }

        // Update Accounts with appropriate KB Category value
        for(Account acctRow : lstAccount){
            if(String.isEmpty(acctRow.Partner_Space__c)){
                //TODO do we need to null out the KB Cat field if the Partner Space field gets nulled out?
                acctRow.Partner_Space__c.addError('This field can not be empty when Partner Account Record Type is used.');
            }else if(acctRow.Partner_Space__c.contains(';')){
                cleanPartnerSpaceValues = trimListValues(acctRow.Partner_Space__c.split(';'));
                cleanKbCategoryValues = convertPartnerSpaceValues(cleanPartnerSpaceValues);
                newAccountMap.get(acctRow.Id).KB_Category_Visibility__c = String.join(cleanKbCategoryValues, ';');
            }else{
                newAccountMap.get(acctRow.Id).KB_Category_Visibility__c = asmMap.get(acctRow.Partner_Space__c).Matching_Configured_KB_Category_Value__c;
            }
        }
        asmMap.clear(); //Clearing for reuse in other methods.
    }

    private List<String> trimListValues(List<String> workingList){
        List<String> cleanedValues = new List<String>();
        for(String row : workingList){
            cleanedValues.add(row.trim());
        }
        System.debug(LoggingLevel.WARN, '***** Value of cleanedValues => ' + cleanedValues);
        return cleanedValues;
    }

    private List<String> convertPartnerSpaceValues(List<String> workingList){
        List<String> mappedValues = new List<String>();
        for(String row : workingList){
            mappedValues.add(asmMap.get(row).Matching_Configured_KB_Category_Value__c);
        }
        return mappedValues;
    }

    public void beforeUpdate(list<Account> lstAccount, Map<Id,Account> oldAccountMap){
        System.debug('@Developer -->beforeUpdate:' );
        string sTriggerEvent='AccountTriggerHandler-beforeUpdate';
        if(TriggerMultipleExecutionPreventer.self.hasTriggerExecutionStarted(sTriggerEvent)){
            System.debug('@Developer -->beforeUpdate:Trigger already run:' );
            return;
        }
        TriggerMultipleExecutionPreventer.self.setTriggerExecutionStarted(sTriggerEvent);
        System.debug('@Developer -->beforeUpdate:Trigger First execution:' );
        map<Id,Account> mapAccount = new map<Id,Account>();
        
        for(Account a : lstAccount){
            // workflow rule -- "Update Last Modified Date for Seller OBS" logic moved in trigger
            if(a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c){
                a.Seller_OBS_Last_Modified_Date__c = system.now();
            }
            
            //from prepod
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            if(a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c){
               
                if(a.Seller_Onboarding_Status__c =='Closed') {
                    a.Seller_Closed_Date__c = dT;
                }
                if(a.Seller_Onboarding_Status__c =='Onboarding Queue') {
                    a.OBQ_Date__c = dT;               
                }
                if(a.Seller_Onboarding_Status__c =='Ready to Onboard') {
                    a.RTOB_Date__c = dT;                
                }
                if(a.Seller_Onboarding_Status__c =='Pre Seller Setup') {
                    a.Pre_SS_Date__c     = dT;                   
                }
                if(a.Seller_Onboarding_Status__c =='Seller Setup') {
                    a.SS_Date__c = dT;
                }
                if(a.Seller_Onboarding_Status__c =='Item Setup') {
                    a.Item_Setup_Date__c = dT;
                }
                if(a.Seller_Onboarding_Status__c =='Transaction Readiness') {
                    a.TR_Date__c     = dT;                    
                }
                if(a.Seller_Onboarding_Status__c =='Launch Readiness') {
                    a.Launch_Readiness_Date__c = dT;
                }
                if(a.Seller_Onboarding_Status__c =='Live on Site') {
                    a.Live_Date__c = dT;
                }
                if(a.Seller_Onboarding_Status__c =='Abandoned') {
                    a.OB_Abandoned_Date__c   = dT;                    
                }
                if(a.Seller_Onboarding_Status__c =='On hold') {
                    a.OB_Onhold_Date__c = dT;
                }  
                if(a.Blocked__c == True) {
                    a.Blocked_date__c = dT;
                }    
                
            }
            if(a.Seller_Onboarding_Live_Status__c !=oldAccountMap.get(a.Id).Seller_Onboarding_Live_Status__c ){
                  if(a.Seller_Onboarding_Live_Status__c =='Launched'){
                  a.Launched_Date__c = dT;
                  
                  }
                  if(a.Seller_Onboarding_Live_Status__c =='Ops Ready'){
                  a.Ops_Ready_Date__c = dT;
                  }
            
            }
            
            Date myDate1;
            Date myDate2;
            Date myDate3;
            Date myDate4;
            Date myDate5;
            Date myDate6;
            Date myDate7;
            Date myDate8;
            Date myDate9;
            Date myDate10;
            
            Date myDate11;
            Date myDate12;
            
            if(a.Seller_Closed_Date__c != null){
                DateTime dT1 = a.Seller_Closed_Date__c;
                myDate1 = date.newinstance(dT1.year(), dT1.month(), dT1.day());
            }
            if(a.OBQ_Date__c != null){
                DateTime dT2 = a.OBQ_Date__c;
                myDate2 = date.newinstance(dT2.year(), dT2.month(), dT2.day());
            }
            
            if(a.RTOB_Date__c != null){
                DateTime dT3 = a.RTOB_Date__c;
                myDate3 = date.newinstance(dT3.year(), dT3.month(), dT3.day());
            }
            if(a.Pre_SS_Date__c != null){
                DateTime dT4 = a.Pre_SS_Date__c;
                myDate4 = date.newinstance(dT4.year(), dT4.month(), dT4.day());
            }
            if(a.SS_Date__c != null){
                DateTime dT5 = a.SS_Date__c;
                myDate5 = date.newinstance(dT5.year(), dT5.month(), dT5.day());
            }
            if(a.Item_Setup_Date__c != null){
                DateTime dT6 = a.Item_Setup_Date__c;
                myDate6 = date.newinstance(dT6.year(), dT6.month(), dT6.day());
            }
            if(a.TR_Date__c != null){
                DateTime dT7 = a.TR_Date__c;
                myDate7 = date.newinstance(dT7.year(), dT7.month(), dT7.day());
            }
            if(a.Launch_Readiness_Date__c != null){
                DateTime dT8 = a.Launch_Readiness_Date__c;
                myDate8 = date.newinstance(dT8.year(), dT8.month(), dT8.day());
            }
            if(a.OB_Abandoned_Date__c != null){
                DateTime dT9 = a.OB_Abandoned_Date__c;
                myDate9 = date.newinstance(dT9.year(), dT9.month(), dT9.day());
            }
            if(a.OB_Onhold_Date__c != null){
                DateTime dT10 = a.OB_Onhold_Date__c;
                myDate10 = date.newinstance(dT10.year(), dT10.month(), dT10.day());
            }  
            
            if(a.Launched_Date__c != null){
                DateTime dT11  = a.Launched_Date__c;
                myDate11 = date.newinstance(dT11.year(), dT11.month(), dT11.day());
            }  
             if(a.Ops_Ready_Date__c != null){
                DateTime dT12  = a.Ops_Ready_Date__c ;
                myDate12 = date.newinstance(dT12.year(), dT12.month(), dT12.day());
            } 
                   
            
            
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Closed'){
                if(a.Seller_Closed_Date__c != null){
                a.Days_in_Closed_Status__c = myDate1.daysBetween(myDate);//; (system.now()-a.Seller_Closed_Date__c)
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Onboarding Queue'){
                if(a.OBQ_Date__c != null){
                a.Days_in_Onboarding_Queue__c = myDate2.daysBetween(myDate);//system.now()-a.OBQ_Date__c; 
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Ready to Onboard'){
                if(a.RTOB_Date__c != null){
                a.Days_in_Ready_to_Onboard__c = myDate3.daysBetween(myDate);//system.now()-a.RTOB_Date__c; 
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Pre Seller Setup'){
                if(a.Pre_SS_Date__c != null){
                a.Days_in_Pre_Seller_Setup__c = myDate4.daysBetween(myDate);//system.now()-a.Pre_SS_Date__c; 
                }
            }
            
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Seller Setup'){
                if(a.SS_Date__c != null){
                a.Days_in_Seller_Setup__c = myDate5.daysBetween(myDate);    //system.now()-a.SS_Date__c; 
                }
            }
            
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Item Setup'){
                if(a.Item_Setup_Date__c != null){
                a.Days_in_Item_Setup__c = myDate6.daysBetween(myDate);//system.now()-a.Item_Setup_Date__c; 
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Transaction Readiness'){
                if(a.TR_Date__c != null){
                a.Days_in__c = myDate7.daysBetween(myDate);//system.now()-a.TR_Date__c; 
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Launch Readiness'){
                if(a.Launch_Readiness_Date__c != null){
                a.Days_in_Launch_Readiness__c = myDate8.daysBetween(myDate);//system.now()-a.Launch_Readiness_Date__c; 
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'On hold'){
                if(a.OB_Onhold_Date__c != null){
                a.Days_in_Onhold__c = myDate10.daysBetween(myDate);//system.now()-a.On_hold_date__c; 
                }
            }
            if(a.Seller_Onboarding_Status__c != null && a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c == 'Abandoned'){
                  if(a.OB_Abandoned_Date__c != null){
                a.Days_in_Abandoned__c = myDate9.daysBetween(myDate);//system.now()-a.OB_Abandoned_Date__c; 
                }
            }
            
            if(a.Seller_Onboarding_Live_Status__c != null && a.Seller_Onboarding_Live_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Live_Status__c && oldAccountMap.get(a.Id).Seller_Onboarding_Live_Status__c == 'Launched'){
                  if(a.Launched_Date__c != null){
                  a.Days_in_Launched__c= myDate11.daysBetween(myDate);
                }
            }
            if(a.per_of_assortment_manufacturedby_company__c > 0){
                a.Manufacturer__c = True;
            }
            
          /*  if(a.No_of_CP__c >0){
                a.Integration_Channel__c = 'Partner';
            }
            */
            //Ashok
            //end from prepod
            
            
            /*
            if(a.Integration_Channel__c != null &&
            a.Integration_Channel__c != oldAccountMap.get(a.Id).Integration_Channel__c){
            mapAccount.put(a.Id,a);
            }
            
            if(a.Integration_Method__c != null &&
            a.Integration_Method__c != oldAccountMap.get(a.Id).Integration_Method__c){
            mapAccount.put(a.Id,a);
            }*/
            
            
            
            
        }
        /*System.debug('@Developer --> mapAccount :' + mapAccount);
        
        list <Opportunity> lstOpportunity = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :mapAccount.values()];
        
        for(Opportunity o : lstOpportunity){
        o.Preferred_integration_General__c = mapAccount.get(o.AccountId).Integration_Channel__c;
        o.Preferred_integration_Specific__c = mapAccount.get(o.AccountId).Integration_Method__c;
        }
        
        System.debug('@Developer --> lstOpportunity :' + lstOpportunity);
        if(lstOpportunity.size() > 0){
        update lstOpportunity;
        }*/
        
        //Integration Engineer assignment
        set<Id> setAccount = new set<Id>();
        set<String> setIntegrationChannel = new set<String>();
        set<String> setIntegrationMethod = new set<String>();
        
        /*for(Account a : lstAccount){
        if(a.Type__c == 'Seller'){
        if(a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c){
        if(a.Seller_Onboarding_Status__c == 'Pre Seller Setup' || a.Seller_Onboarding_Status__c == 'Seller Setup' ){
        setAccount.add(a.Id);
        setIntegrationChannel.add(a.Integration_Channel__c);
        setIntegrationMethod.add(a.Integration_Method__c);
        }
        }
        }
        }
        System.debug('@Developer --> setAccount :' + setAccount);
        System.debug('@Developer --> setIntegrationChannel :' + setIntegrationChannel);
        System.debug('@Developer --> setIntegrationMethod :' + setIntegrationMethod);
        
        list<EngineerMapping>lstEngineerMapping = new list<EngineerMapping>();
        list<Engineer_Mapping__c>lstEM = new list<Engineer_Mapping__c>();
        
        for(Engineer_Mapping__c em : [Select Id,    User__c,User__r.Name,Percentage__c,No_of_Accounts_working_on__c,User_Type__c,Integration_Channel__c,
        Maximum__c,
        (Select Id, Channel_Partner_Name__c,    Engineer_Mapping__c
        From Engineer_Accounts__r
        Where Channel_Partner_Name__c In :setIntegrationMethod)
        From Engineer_Mapping__c
        Where Active__c = true
        And Integration_Channel__c In :setIntegrationChannel
        Order By User_Type__c,Integration_Channel__c,Percentage__c
        ]){
        lstEM.add(em);
        lstEngineerMapping.add(new EngineerMapping(em));
        }
        System.debug('@Developer --> lstEngineerMapping :' + lstEngineerMapping);
        */
     /*   
        list<EngineerMapping>lstEngineerMapping = new list<EngineerMapping>();
        //list<Engineer_Mapping__c>lstEM = new list<Engineer_Mapping__c>();
        map<Id,Engineer_Mapping__c> mapUserWiseEngineerMapping = new map<Id,Engineer_Mapping__c>();
        
        for(Engineer_Mapping__c em : [Select Id,    User__c,User__r.Name,Percentage__c,No_of_Accounts_working_on__c,User_Type__c,Integration_Channel__c,Maximum__c,
                                                                                                                                (Select Id, Channel_Partner_Name__c,Engineer_Mapping__c From Engineer_Accounts__r)
                                                                                                                                From Engineer_Mapping__c
                                                                                                                                Where Active__c = true
                                                                                                                                Order By User_Type__c,Integration_Channel__c,Percentage__c]){
            //lstEM.add(em);
            mapUserWiseEngineerMapping.put(em.User__c,em);
            lstEngineerMapping.add(new EngineerMapping(em));
        }
        System.debug('@Developer --> lstEngineerMapping :' + lstEngineerMapping);
        
        set<string> setStatus = new set<string>();
        setStatus.add('Seller Setup');
        setStatus.add('Item Setup');
        setStatus.add('Transaction Readiness');
        setStatus.add('Launch Readiness');
        
        List<Integration_Method_Mapping__c> lstIntegrationMethodMapping = Integration_Method_Mapping__c.getAll().values();
        map<string,Id> mapIntegrationMethodMapping = new map<string,Id>();
        for(Integration_Method_Mapping__c oIntegrationMethodMapping:lstIntegrationMethodMapping){
            mapIntegrationMethodMapping.put(oIntegrationMethodMapping.Account_Name__c,oIntegrationMethodMapping.Account_Id__c);
        }
        
        for(Account a : lstAccount){
            
            if(a.Type == 'Seller'){
                if(a.Integration_Channel__c!=null){
                    UpdateStatusWrapper oUpdateStatusWrapper = new UpdateStatusWrapper();
                    if(a.Integration_Channel__c=='Direct'){
                            AutoAssignIEandSL( a, oldAccountMap, lstEngineerMapping, mapUserWiseEngineerMapping, setStatus, 'Direct',oUpdateStatusWrapper, false,null,false);
                    }
                    else if(a.Integration_Channel__c=='Partner'){
                        boolean bMatchEngineerAccount = false;
                        Id idIntegrationMethod = null;
                        if(a.Integration_Method__c!=null){
                            bMatchEngineerAccount = true;
                            if(a.IntegrationMethodId__c!=null){
                                                                                idIntegrationMethod = a.IntegrationMethodId__c;
                                                                            }
                        }
                        System.debug('@Developer --> partner :');
                        AutoAssignIEandSL(a, oldAccountMap, lstEngineerMapping, mapUserWiseEngineerMapping, setStatus, 'Partner',oUpdateStatusWrapper, bMatchEngineerAccount,idIntegrationMethod,false);
                        System.debug('@Developer --> oUpdateStatusWrapper :'+oUpdateStatusWrapper);
                        if(bMatchEngineerAccount && a.Seller_Onboarding_Status__c == 'Seller Setup' && (a.Seller_Liaison__c==null ||a.Integration_Engineer__c==null)){
                            System.debug('@Developer --> partner 2:');
                            AutoAssignIEandSL(a, oldAccountMap, lstEngineerMapping, mapUserWiseEngineerMapping, setStatus, 'Partner',oUpdateStatusWrapper, false,null,true);
                        }
                    }
                } 
            }
        }
        
        */
        
        /*if(lstEM.size() > 0){
            update lstEM;
        }*/
      /*  if(mapUserWiseEngineerMapping.values().size() > 0){
            update mapUserWiseEngineerMapping.values();
        }*/
        
    }
    
    public void afterUpdate(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        System.debug('@Developer --> AccountTriggerHandler.afterUpdate :' );
        
        string sTriggerEvent='AccountTriggerHandler-afterUpdate';
        if(TriggerMultipleExecutionPreventer.self.hasTriggerExecutionStarted(sTriggerEvent)){
            System.debug('@Developer -->Trigger already run:' );
            return;
        }
        TriggerMultipleExecutionPreventer.self.setTriggerExecutionStarted(sTriggerEvent);
        System.debug('@Developer -->Trigger First execution:' );
        Id idRecordType;
        for(recordtype rt : rtMap.values()){
            if(rt.DeveloperName == 'Partner_Account') {
                idRecordType = rt.Id;
            }
        }
        system.debug('@Developer --> idRecordType:'+idRecordType);
        set<Id> setAccountIdAdd = new set<Id>();
        set<Id> setAccountIdRemove = new set<Id>();
        set<Id> setAccId = new set<Id>();
        system.debug('@Developer --> newAccountMap:'+newAccountMap);
        set<id> setAccountIdForPartner=new set<id>();
        set<id> setAccountIdForSpecialityPartner=new set<id>();
        
        Id idMpRecordType;
        for(recordtype rt : rtMap.values()){
            if(rt.DeveloperName == 'MP_Account') {
                idMpRecordType = rt.Id;
            }
        }
        
        
        for(Account a : newAccountMap.values()){
            System.debug('@Developer --> a.Seller_Onboarding_Status__c :' + a.Seller_Onboarding_Status__c);
            System.debug('@Developer --> oldAccountMap.get(a.Id).Seller_Onboarding_Status__c :' + oldAccountMap.get(a.Id).Seller_Onboarding_Status__c);
            
            if(a.Seller_Onboarding_Status__c == 'Closed' && oldAccountMap.get(a.Id).Seller_Onboarding_Status__c != a.Seller_Onboarding_Status__c){
                setAccId.add(a.Id);
            }
            if((a.recordTypeId==idMpRecordType && a.Integration_Channel__c=='Partner' && a.Integration_Method__c!=oldAccountMap.get(a.Id).Integration_Method__c)||(a.recordTypeId==idMpRecordType && a.Integration_Channel__c!='Partner' && oldAccountMap.get(a.Id).Integration_Channel__c=='Partner')){
                setAccountIdForPartner.add(a.id);
            }
            setAccountIdForSpecialityPartner.add(a.Id);
            if((a.RecordTypeId!=oldAccountMap.get(a.Id).RecordTypeId)){
                if(a.RecordTypeId==idRecordType){
                    setAccountIdAdd.add(a.Id);
                }
                else if(oldAccountMap.get(a.Id).RecordTypeId==idRecordType){
                    setAccountIdRemove.add(a.Id);
                }
            }
        }
        System.debug('@Developer --> setAccId :' + setAccId);
        
        map<Id,Account> mapIdWiseAccountForPartner = new map<Id,Account>();
        map<Id,Account> mapIdWiseAccountForSpecialityPartner = new map<Id,Account>();
        
        map<Id,Account> mapIdWiseAccountToAdd = new map<Id,Account>();
        map<Id,Account> mapIdWiseAccountToRemove = new map<Id,Account>();
        set<Id> setChannelPartner = new set<Id>();
        for(Account a :[Select Id, (Select Id, Seller__c, Channel_Partner__c From Channel_Partner__r) From Account where id in :setAccountIdForPartner or id in :setAccountIdForSpecialityPartner or id in :setAccountIdAdd or id in:setAccountIdRemove]){
            if(setAccountIdForPartner.contains(a.Id)){
                mapIdWiseAccountForPartner.put(a.Id,a);
            }
            if(setAccountIdForSpecialityPartner.contains(a.Id)){
                mapIdWiseAccountForSpecialityPartner.put(a.Id,a);
            }
            boolean bParseChannelPartner = false;
            if(setAccountIdAdd.contains(a.Id)){
                mapIdWiseAccountToAdd.put(a.Id,a);
                bParseChannelPartner = true;
            }
            if(setAccountIdRemove.contains(a.Id)){
                mapIdWiseAccountToRemove.put(a.Id,a);
                bParseChannelPartner = true;
            }
            if(bParseChannelPartner && a.Channel_Partner__r!=null){
                for(Partner_Join__c oPartnerJoin :a.Channel_Partner__r){
                    setChannelPartner.add(oPartnerJoin.Channel_Partner__c);
                }
            }
        }
        list<Partner_Join__c> lstPartnerJoinToInsert = new list<Partner_Join__c>();
        map<Id,Partner_Join__c> mapPartnerJoinToUpdate = new map<Id,Partner_Join__c>();
        list<Partner_Join__c> lstPartnerJoinToDelete = new list<Partner_Join__c>();
        /*List<Integration_Method_Mapping__c> lstIntegrationMethodMapping = Integration_Method_Mapping__c.getAll().values();
        map<string,Id> mapIntegrationMethodMapping = new map<string,Id>();
        for(Integration_Method_Mapping__c oIntegrationMethodMapping:lstIntegrationMethodMapping){
            mapIntegrationMethodMapping.put(oIntegrationMethodMapping.Account_Name__c,oIntegrationMethodMapping.Account_Id__c);
        }*/
        
        
        for(Account a:newAccountMap.values()){
            system.debug('@Developer --> Integration_Channel__c:'+a.Integration_Channel__c);
            system.debug('@Developer --> Integration_Method__c:'+a.Integration_Method__c);
            system.debug('@Developer --> old Integration_Channel__c:'+oldAccountMap.get(a.Id).Integration_Method__c);
            if((a.recordTypeId==idMpRecordType && a.Integration_Channel__c=='Partner' && a.Integration_Method__c!=oldAccountMap.get(a.Id).Integration_Method__c)||(a.recordTypeId==idMpRecordType && a.Integration_Channel__c!='Partner' && oldAccountMap.get(a.Id).Integration_Channel__c=='Partner')){
                Id newPartnerId;
                Id oldPartnerId;
                
                if(a.Integration_Method__c!=null && a.IntegrationMethodId__c!=null){
                    newPartnerId = a.IntegrationMethodId__c;
                }
                string sOldIntegrationMethod = oldAccountMap.get(a.Id).Integration_Method__c;
                if(sOldIntegrationMethod!=null && oldAccountMap.get(a.Id).IntegrationMethodId__c!=null){
                    oldPartnerId = oldAccountMap.get(a.Id).IntegrationMethodId__c;
                }
                system.debug('@Developer --> newPartnerId:'+newPartnerId);
                system.debug('@Developer --> oldPartnerId:'+oldPartnerId);
                Account oAccountWithExistingPartner=mapIdWiseAccountForPartner.get(a.Id);
                boolean bUpdated = false;
                boolean bNewFound = false;
                //if(oldPartnerId!=null){
                system.debug('@Developer --> oAccountWithExistingPartner.Channel_Partner__r:'+oAccountWithExistingPartner.Channel_Partner__r);
                    if(oAccountWithExistingPartner.Channel_Partner__r!=null && oAccountWithExistingPartner.Channel_Partner__r.size()>0){
                        for(Partner_Join__c oPartnerJoin:oAccountWithExistingPartner.Channel_Partner__r){
                            if((oPartnerJoin.Channel_Partner__c==oldPartnerId)){
                                if((newPartnerId!=null)){
                                    if(newPartnerId!=oldPartnerId){
                                        oPartnerJoin.Channel_Partner__c=newPartnerId;
                                        mapPartnerJoinToUpdate.put(a.id,oPartnerJoin);
                                        bUpdated = true;
                                        system.debug('@Developer --> mapPartnerJoinToUpdate:'+mapPartnerJoinToUpdate);
                                    }
                                }
                                else{
                                    lstPartnerJoinToDelete.add(oPartnerJoin);
                                    system.debug('@Developer --> add to delete:'+oPartnerJoin);
                                }
                            }
                            else if(oPartnerJoin.Channel_Partner__c==newPartnerId){
                                bNewFound = true;
                                system.debug('@Developer --> new found:'+oPartnerJoin);
                            }
                        }
                    }
                //}
                if(bUpdated && bNewFound){
                    Partner_Join__c oPartnerJoin = mapPartnerJoinToUpdate.get(a.Id);
                    mapPartnerJoinToUpdate.remove(a.Id);
                    lstPartnerJoinToDelete.add(oPartnerJoin);
                    system.debug('@Developer --> both old and new found:');
                }
                if(newPartnerId!=null && !bUpdated && !bNewFound){
                    Partner_Join__c oPartnerJoin = new Partner_Join__c();
                    oPartnerJoin.Seller__c=a.Id;
                    oPartnerJoin.Channel_Partner__c=newPartnerId;
                    lstPartnerJoinToInsert.add(oPartnerJoin);
                }
            }
            
            if(a.SpecialitypartnerIds__c!=oldAccountMap.get(a.Id).SpecialitypartnerIds__c){
                Account oAccountWithExistingPartner=mapIdWiseAccountForSpecialityPartner.get(a.Id);
                                                    if(oldAccountMap.get(a.Id).SpecialitypartnerIds__c!=null){
                                                        set<string> setOldSpecialitypartnerIds= new set<string>();
                                                        for(string sSpecialitypartnerId : oldAccountMap.get(a.Id).SpecialitypartnerIds__c.split(',')){
                                                            if(sSpecialitypartnerId!=null && sSpecialitypartnerId!=''){
                                                                setOldSpecialitypartnerIds.add(sSpecialitypartnerId);
                                                            }
                                                        }
                                                        if(setOldSpecialitypartnerIds.size()>0){
                                                            if(oAccountWithExistingPartner.Channel_Partner__r!=null){
                            for(Partner_Join__c oPartnerJoin:oAccountWithExistingPartner.Channel_Partner__r){
                                if(setOldSpecialitypartnerIds.contains(oPartnerJoin.Channel_Partner__c)){
                                    lstPartnerJoinToDelete.add(oPartnerJoin);
                                }
                            }
                                                            }
                                                        }
                                                    }
                                                    if(a.SpecialitypartnerIds__c!=null){
                    for(string sSpecialitypartnerId : a.SpecialitypartnerIds__c.split(',')){
                                                            if(sSpecialitypartnerId!=null && sSpecialitypartnerId!=''){
                                                                Partner_Join__c oPartnerJoin = new Partner_Join__c();
                oPartnerJoin.Seller__c=a.Id;
                oPartnerJoin.Channel_Partner__c=sSpecialitypartnerId;
                lstPartnerJoinToInsert.add(oPartnerJoin);
                                                            }
                                                        }
                                                    }
            }
        }
        
        List<Opportunity> opptiesListToSendEmail=new List<Opportunity>();
        List<Opportunity> opportunities = [SELECT Id,Channel_Partner_First_Name__c,AccountId,Account.Name,Channel_Partner_Email__c,Account.Integration_Channel__c,(SELECT Id,Category__r.Name FROM AppliationCategories__r)
        FROM Opportunity opp
        WHERE AccountId in :setAccId];
        
        Set<Id> setOppIdHavingApplicationCategories=new Set<Id>();
        
        for(Opportunity opp:opportunities){
            System.debug('@Developer --> opp :' + opp);
            opptiesListToSendEmail.add(opp);
            if(!opp.AppliationCategories__r.isEmpty()){
                setOppIdHavingApplicationCategories.add(opp.Id);
            }
        }
        
        List<Category_Mapping__c> categoryOwners =[SELECT Category_Name__c,Category_Owner__c,Id From Category_Mapping__c];
        // List<CategoryOwner__mdt> categoryOwners=[SELECT CategoryName__c,CategoryOwnerName__c,DeveloperName,Id,Label FROM CategoryOwner__mdt];
        Map<String,String> mapCategoryNameToOwner=new Map<String,String>();
        Set<String> setCategoryOwner=new Set<String>(); // catowner name
        
        for(Default_Cat_Manager__c dcm : [Select Id,UserName__c,User_Id__c From Default_Cat_Manager__c Where Active__c = true limit 1]){
            mapCategoryNameToOwner.put(null,dcm.User_Id__c);
        }
        System.debug('@Developer --> mapCategoryNameToOwner :' + mapCategoryNameToOwner);
        System.debug('@Developer --> categoryOwners :' + categoryOwners);
        for(Category_Mapping__c catOwn:categoryOwners){
            mapCategoryNameToOwner.put(catOwn.Category_Name__c,catOwn.Category_Owner__c);
            setCategoryOwner.add(catOwn.Category_Owner__c);
        }
        
        opportunities=[SELECT Id,opp.Account.Cat_Mgr_Owner__c,
        (SELECT Id,Percentage_of_Annual_Sales__c,Category__c,Category__r.Name
        FROM AppliationCategories__r
        ORDER BY Percentage_of_Annual_Sales__c desc
        )
        FROM Opportunity opp
        WHERE Id in :setOppIdHavingApplicationCategories];
        
        Map<String,String> opptyToCatOwnerMap=new Map<String,String>();
        List<Account> acctLst=new List<Account>();
        for(Opportunity opp:opportunities){
            
            List<Decimal> lstDecimals=new List<Decimal>();
            for(Integer i=0;i<setCategoryOwner.size();i++){
                lstDecimals.add(0);
            }
            
            for(ApplicationCategories__c apc:opp.AppliationCategories__r){
                for(Integer i=0;i<setCategoryOwner.size();i++){
                    if(mapCategoryNameToOwner.containsKey(apc.Category__r.Name)){
                        if(mapCategoryNameToOwner.get(apc.Category__r.Name).equals(new List<String>(setCategoryOwner)[i])){
                            lstDecimals[i]+=apc.Percentage_of_Annual_Sales__c;
                        }
                    }
                }
            }
            if(lstDecimals.size()>0){
                System.debug('@Developer --> lstDecimals :' + lstDecimals);
                Decimal smallest=lstDecimals[0];
                Decimal largest=lstDecimals[0];
                Integer largestIndex=0;
                System.debug('Largest is ---'+largest);
                System.debug('smallest is---'+smallest);
                for(Integer i=1;i<lstDecimals.size();i++){
                    if(lstDecimals[i]>largest){
                        largest=lstDecimals[i];
                        largestIndex=i;
                    }
                    else if(lstDecimals[i]<smallest){
                        smallest=lstDecimals[i];
                    }
                }
                for(Integer i=0;i<setCategoryOwner.size();i++){
                    if(largest==lstDecimals[i]){
                        opptyToCatOwnerMap.put(opp.Id,new List<String>(setCategoryOwner)[i]);
                    }
                }
            }
            
            
            if(opptyToCatOwnerMap.containsKey(opp.Id)){
                opp.Account.Cat_Mgr_Owner__c= opptyToCatOwnerMap.get(opp.Id);
                System.debug('@Developer --> opp.Account.Cat_Mgr_Owner__c :' + opp.Account.Cat_Mgr_Owner__c);
            }
            else{
                opp.Account.Cat_Mgr_Owner__c= mapCategoryNameToOwner.get(null);
                System.debug('@Developer --> default opp.Account.Cat_Mgr_Owner__c :' + opp.Account.Cat_Mgr_Owner__c);
            }
            
            acctLst.add(opp.Account);
        }
        
        if(!isUpdating && !acctLst.isEmpty()){
            isUpdating=true;
            update acctLst;
            System.debug('acctLst'+acctLst);
        }
        system.debug('@Developer --> lstPartnerJoinToInsert:'+lstPartnerJoinToInsert);
        if(lstPartnerJoinToInsert.size()>0){
            insert lstPartnerJoinToInsert;
        }
        system.debug('@Developer --> mapPartnerJoinToUpdate:'+mapPartnerJoinToUpdate);
        if(mapPartnerJoinToUpdate.size()>0){
            update mapPartnerJoinToUpdate.values();
        }
        system.debug('@Developer --> lstPartnerJoinToDelete:'+lstPartnerJoinToDelete);
        if(lstPartnerJoinToDelete.size()>0){
            delete lstPartnerJoinToDelete;
        }
        if(setAccountIdRemove.size()>0 ||setAccountIdAdd.size()>0){
            ManageAccountShare(mapIdWiseAccountToAdd,mapIdWiseAccountToRemove,setChannelPartner);
        }
        if(!opptiesListToSendEmail.isEmpty() && setAccId.size() > 0){
            sendEmail(opptiesListToSendEmail,'Channel_Partner_Close_Opportunity_Email');
        }
    }
    
    public void sendEmail(List<Opportunity> opptyList,String emailTemplateName){
        System.debug('@Developer --> sendEmail :');
        
        List<Messaging.SingleEmailMessage> maillist = new List<Messaging.SingleEmailMessage>();
        try
        {
            List<OrgWideEmailAddress> orgWideAddress=[
            SELECT  Address,ID,DisplayName
            FROM    OrgWideEmailAddress
            WHERE   Address='bdmplace@walmart.com'];
            
            EmailTemplate ET = [SELECT  Id,DeveloperName,Subject,Body,HtmlValue,BrandTemplateId
            FROM    EmailTemplate
            WHERE   DeveloperName=:emailTemplateName limit 1];
            System.debug('@Developer --> ET.HtmlValue:' + ET.HtmlValue);    
            System.debug('@Developer --> ET.BrandTemplateId:' + ET.BrandTemplateId);    
            
            BrandTemplate BT =  [SELECT id,value 
            FROM BrandTemplate 
            WHERE id = :ET.BrandTemplateId limit 1];
            System.debug('@Developer --> BT.value :' + BT.value);    
            
            
                
            
            Set<ID> userIds=new Set<ID>();
            Map<ID,ID> mapRVMemberThApprovedByUserId=new Map<ID,ID>();
            
            /*Set<Id> contactIds=new Set<Id>();
            for(Opportunity opp:opptyList){
            if(opp.Primary_Contact__c!=null){
            contactIds.add(opp.Primary_Contact__c);
            }
            }
            Map<Id,Contact> mapContacts=new Map<Id,Contact>([SELECT Id,Email,Name FROM Contact WHERE Id In :contactIds]);
            */
            
            for(Opportunity opp:opptyList){
                System.debug('@Developer --> opp :' + opp);
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(ET.Id, null, opp.Id);
                
                String subject  = mail.getSubject(); 
                String htmlBody = mail.getHtmlBody();
                
                //String plainTextBody = ET.Body;
                
                //System.debug('@Developer --> htmlBody :' + htmlBody);
                //System.debug('@Developer --> plainTextBody :' + plainTextBody);
                
                //plainTextBody=(opp.Channel_Partner_First_Name__c!=null && opp.Channel_Partner_First_Name__c!= '' )?plainTextBody.replace('{SalesProfessional!}', opp.Channel_Partner_First_Name__c):plainTextBody.replace('{SalesProfessional!}','Sales Professional');
                //htmlBody=opp.Channel_Partner_First_Name__c!=null?htmlBody.replace('{SalesProfessional!}',opp.Channel_Partner_First_Name__c):htmlBody.replace('{SalesProfessional!}','Sales Professional');
                
                if(opp.Channel_Partner_First_Name__c!=null && opp.Channel_Partner_First_Name__c!= '' ){
                    //plainTextBody = plainTextBody.replace('{SalesProfessional!}', opp.Channel_Partner_First_Name__c);
                    htmlBody = htmlBody.replace('{SalesProfessional!}', opp.Channel_Partner_First_Name__c);
                }
                else{
                    //plainTextBody = plainTextBody.replace('{SalesProfessional!}', 'Sales Professional');
                    htmlBody = htmlBody.replace('{SalesProfessional!}', 'Sales Professional');
                }
                
                subject=opp.AccountId!=null?subject.replace('{CompanyName!}',opp.Account.Name):subject.replace('{CompanyName!}','');
                //plainTextBody=opp.AccountId!=null?plainTextBody.replace('{CompanyName!}',opp.Account.Name):plainTextBody.replace('{CompanyName!}','');
                htmlBody=opp.AccountId!=null?htmlBody.replace('{CompanyName!}',opp.Account.Name):htmlBody.replace('{CompanyName!}','');
                
                //htmlBody = htmlBody.replace('\n', '<br/>');
                
                List<String> toAddress=new List<String>();
                if(opp.Channel_Partner_Email__c!=null){
                    toAddress.add(opp.Channel_Partner_Email__c);
                }
                
                //List<String> ccAddress=new List<String>();
                //if(opp.Primary_Contact__c!=null && mapContacts.get(opp.Primary_Contact__c).Email!=null){
                //  ccAddress.add(mapContacts.get(opp.Primary_Contact__c).Email);
                //}
                
                
                System.debug('@Developer --> orgWideAddress[0] :' + orgWideAddress[0]);
                mail.setOrgWideEmailAddressId(orgWideAddress[0].id);
                //setSenderDisplayName('BD Market Place');
                
                System.debug('@Developer --> toAddress :' + toAddress);
                mail.setToAddresses(toAddress);
               // mail.setTemplateId(ET.id);

                mail.setSubject(subject);
                
                // mail.setplainTextBody(plainTextBody);
                System.debug('@Developer --> htmlBody :' + htmlBody);    
                
                /*String sLetterHead = '';
                
                if(BT != null && BT.value != null){
                    sLetterHead = BT.value;
                    System.debug('@Developer --> sLetterHead :' + sLetterHead);
                 if(sLetterHead.startsWith('<body class="setupTab" >')){
                  sLetterHead = sLetterHead.removeStart('<body class="setupTab" >');
                 }
                 if(sLetterHead.endsWith('</body>')){
                  sLetterHead = sLetterHead.removeEnd('</body>');
                 }
                }
                System.debug('@Developer --> sLetterHead :' + sLetterHead);
                 
                 htmlBody = sLetterHead + htmlBody ;
                 System.debug('@Developer --> htmlBody 1:' + htmlBody);
                 
                 htmlBody = htmlBody.replaceAll('<\\!\\[CDATA\\[','');
                                                                    htmlBody = htmlBody.replaceAll('\\]\\]>','');
                
                System.debug('@Developer --> htmlBody 2:' + htmlBody);*/
                mail.setHtmlBody(htmlBody);
                
                //System.debug('@Developer --> ccAddress :' + ccAddress);
                //mail.setCCAddresses(ccAddress);
                System.debug('@Developer --> opp.Channel_Partner_Email__c:' + opp.Channel_Partner_Email__c);
                
                if(opp.Channel_Partner_Email__c!=null ){
                    maillist.add(mail);
                }
                System.debug('@Developer --> mailList.size() :' + mailList.size());
            }
            System.debug('@Developer --> mailList.size() :' + mailList.size());
            if(!maillist.isEmpty()){
                Messaging.sendEmail(mailList);
            }
        }
        catch(Exception e){
            throw e;
        }
    }
    /*
    private void AutoAssignIEandSL(Account a,Map<Id,Account> oldAccountMap,list<EngineerMapping> lstEngineerMapping,map<Id,Engineer_Mapping__c> mapUserWiseEngineerMapping,set<string> setStatus,string sIntegrationChannel,UpdateStatusWrapper oUpdateStatusWrapper,boolean bMatchEngineerAccount,Id idIntegrationMethod,boolean bSecondTime){
        //boolean bIntegrationEngineerCountUpdated=false;
        //boolean bSellerLiaisonCountUpdated=false;
        if((a.Integration_Engineer__c != oldAccountMap.get(a.Id).Integration_Engineer__c) &&(setStatus.contains(a.Seller_Onboarding_Status__c)) && !bSecondTime){
            Account oldAccount = oldAccountMap.get(a.Id);
            Engineer_Mapping__c tmpEM;
            if(oldAccount.Integration_Engineer__c!=null && mapUserWiseEngineerMapping.containsKey(oldAccount.Integration_Engineer__c)){
                tmpEM = mapUserWiseEngineerMapping.get(oldAccount.Integration_Engineer__c);
                if(tmpEM.No_of_Accounts_working_on__c != null){
                 tmpEM.No_of_Accounts_working_on__c--;
                 if(tmpEM.No_of_Accounts_working_on__c < 0){
                    tmpEM.No_of_Accounts_working_on__c = 0;
                 }
                }
                else{
                    tmpEM.No_of_Accounts_working_on__c = 0;
                }
                System.debug('@Developer --> CountUpdated 1 :');
                mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
            }
            
            if(a.Integration_Engineer__c !=null && mapUserWiseEngineerMapping.containsKey(a.Integration_Engineer__c)){
                 oUpdateStatusWrapper.IntegrationEngineerCountUpdated = true;
                 tmpEM = mapUserWiseEngineerMapping.get(a.Integration_Engineer__c);
                 if(tmpEM.No_of_Accounts_working_on__c != null){
                  tmpEM.No_of_Accounts_working_on__c++;
                 }
                 else{
                    tmpEM.No_of_Accounts_working_on__c = 1;
                 }
                 System.debug('@Developer --> CountUpdated 2 :');
                 mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
            }
        }
        
        if((a.Seller_Liaison__c != oldAccountMap.get(a.Id).Seller_Liaison__c) &&(setStatus.contains(a.Seller_Onboarding_Status__c)) && !bSecondTime){
            Account oldAccount = oldAccountMap.get(a.Id);
            Engineer_Mapping__c tmpEM;
            if(oldAccount.Seller_Liaison__c!=null && mapUserWiseEngineerMapping.containsKey(oldAccount.Seller_Liaison__c)){
                tmpEM = mapUserWiseEngineerMapping.get(oldAccount.Seller_Liaison__c);
                if(tmpEM.No_of_Accounts_working_on__c != null){
                 tmpEM.No_of_Accounts_working_on__c--;
                 if(tmpEM.No_of_Accounts_working_on__c < 0){
                    tmpEM.No_of_Accounts_working_on__c = 0;
                 }
                }
                else{
                    tmpEM.No_of_Accounts_working_on__c = 0;
                }
                System.debug('@Developer --> CountUpdated 3 :');
                mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
            }
            
            if(a.Seller_Liaison__c!=null && mapUserWiseEngineerMapping.containsKey(a.Seller_Liaison__c)){
                 oUpdateStatusWrapper.SellerLiaisonCountUpdated = true;
                 tmpEM = mapUserWiseEngineerMapping.get(a.Seller_Liaison__c);
                 if(tmpEM.No_of_Accounts_working_on__c != null){
                  tmpEM.No_of_Accounts_working_on__c++;
                 }
                 else{
                    tmpEM.No_of_Accounts_working_on__c = 1;
                 }
                 System.debug('@Developer --> CountUpdated 4 :');
                 mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
            }
        }
        
        if(a.Seller_Onboarding_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Status__c){
            string sOldOnboardingStatus = oldAccountMap.get(a.Id).Seller_Onboarding_Status__c;
            if(setStatus.contains(a.Seller_Onboarding_Status__c) &&((sOldOnboardingStatus=='On hold')||(sOldOnboardingStatus=='Abandoned')||(sOldOnboardingStatus=='Live on Site' && oldAccountMap.get(a.Id).Seller_Onboarding_Live_Status__c != 'Ops Ready')) && !bSecondTime){
                if(!oUpdateStatusWrapper.IntegrationEngineerCountUpdated && a.Integration_Engineer__c!=null && mapUserWiseEngineerMapping.containsKey(a.Integration_Engineer__c)){
                    oUpdateStatusWrapper.IntegrationEngineerCountUpdated = true;
                 Engineer_Mapping__c tmpEM = mapUserWiseEngineerMapping.get(a.Integration_Engineer__c);
                 if(tmpEM.No_of_Accounts_working_on__c != null){
                  tmpEM.No_of_Accounts_working_on__c++;
                 }
                 else{
                    tmpEM.No_of_Accounts_working_on__c = 1;
                 }
                 System.debug('@Developer --> CountUpdated 5 :');
                 mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
                }
            
                if(!oUpdateStatusWrapper.SellerLiaisonCountUpdated && a.Seller_Liaison__c!=null && mapUserWiseEngineerMapping.containsKey(a.Seller_Liaison__c)){
                 oUpdateStatusWrapper.SellerLiaisonCountUpdated = true;
                 Engineer_Mapping__c tmpEM = mapUserWiseEngineerMapping.get(a.Seller_Liaison__c);
                 if(tmpEM.No_of_Accounts_working_on__c != null){
                  tmpEM.No_of_Accounts_working_on__c++;
                 }
                 else{
                    tmpEM.No_of_Accounts_working_on__c = 1;
                 }
                 System.debug('@Developer --> CountUpdated 6 :');
                 mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
                }
            }
            
            lstEngineerMapping.sort();
            System.debug('@Developer --> lstEngineerMapping :' + lstEngineerMapping);
            for(EngineerMapping em : lstEngineerMapping){
                System.debug('@Developer --> em.oEM.User_Type__c :' + em.oEM.User_Type__c);
                if(a.Seller_Onboarding_Status__c == 'Seller Setup'){
                    System.debug('@Developer --> a.Integration_Engineer__c :' + a.Integration_Engineer__c);
                    if(a.Integration_Engineer__c == null && !oUpdateStatusWrapper.IntegrationEngineerMethodFound){
                        if(em.oEM.User_Type__c == 'Integration Engineer'){
                            if(em.oEM.Integration_Channel__c == sIntegrationChannel){
                                System.debug('@Developer --> em.oEM.User__r.Name :' + em.oEM.User__r.Name);
                                decimal nWorkingAccount=(em.oEM.No_of_Accounts_working_on__c==null)?0:em.oEM.No_of_Accounts_working_on__c;
                                nWorkingAccount++;
                                decimal nMax = (em.oEM.Maximum__c==null)?0:em.oEM.Maximum__c;
                                //if(nWorkingAccount <= nMax){
                                    boolean bAssign = false;
                                    if(bMatchEngineerAccount && idIntegrationMethod!=null){
                                        
                                        if(em.oEM.Engineer_Accounts__r!=null){
                                            for(Engineer_Account__c oEngineerAccount:em.oEM.Engineer_Accounts__r){
                                                if(oEngineerAccount.Channel_Partner_Name__c==idIntegrationMethod){
                                                    bAssign = true;
                                                    oUpdateStatusWrapper.IntegrationEngineerMethodFound = true;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        bAssign = true;
                                    }
                                                if(bAssign && (nWorkingAccount <= nMax)){
                                        mapUserWiseEngineerMapping.put(em.oEM.User__c,em.oEM);
                                        a.Integration_Engineer__c = em.oEM.User__c;
                                        em.oEM.No_of_Accounts_working_on__c = nWorkingAccount;
                                        System.debug('@Developer --> CountUpdated 7 :');
                                        oUpdateStatusWrapper.IntegrationEngineerCountUpdated= true;
                                                }
                                //}
                            }
                            /*else if(em.oEM.Integration_Channel__c == 'Partner'){
                            
                            }* /
                        }
                    }
                    else{
                        if(!oUpdateStatusWrapper.IntegrationEngineerCountUpdated && mapUserWiseEngineerMapping.containsKey(a.Integration_Engineer__c)){
                            oUpdateStatusWrapper.IntegrationEngineerCountUpdated = true;
                         Engineer_Mapping__c tmpEM = mapUserWiseEngineerMapping.get(a.Integration_Engineer__c);
                         if(tmpEM.No_of_Accounts_working_on__c != null){
                          tmpEM.No_of_Accounts_working_on__c++;
                         }
                         else{
                            tmpEM.No_of_Accounts_working_on__c = 1;
                         }
                         System.debug('@Developer --> CountUpdated 8 :');
                         mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
                        }
                    }
                    
                    if(a.Seller_Liaison__c == null && !oUpdateStatusWrapper.SellerLiaisonMethodFound){
                        if(em.oEM.User_Type__c == 'Seller Liasion'){
                            if(em.oEM.Integration_Channel__c == sIntegrationChannel){
                                System.debug('@Developer --> em.oEM.User__r.Name :' + em.oEM.User__r.Name);
                                decimal nWorkingAccount=(em.oEM.No_of_Accounts_working_on__c==null)?0:em.oEM.No_of_Accounts_working_on__c;
                                nWorkingAccount++;
                                decimal nMax = (em.oEM.Maximum__c==null)?0:em.oEM.Maximum__c;
                                //if(nWorkingAccount <= nMax){
                                    boolean bAssign = false;
                                    if(bMatchEngineerAccount && idIntegrationMethod!=null){
                                        if(em.oEM.Engineer_Accounts__r!=null){
                                            for(Engineer_Account__c oEngineerAccount:em.oEM.Engineer_Accounts__r){
                                                if(oEngineerAccount.Channel_Partner_Name__c==idIntegrationMethod){
                                                    bAssign = true;
                                                    oUpdateStatusWrapper.SellerLiaisonMethodFound = true;
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        bAssign = true;
                                    }
                                                if(bAssign && (nWorkingAccount <= nMax)){
                                        mapUserWiseEngineerMapping.put(em.oEM.User__c,em.oEM);
                                        a.Seller_Liaison__c = em.oEM.User__c;
                                        em.oEM.No_of_Accounts_working_on__c = nWorkingAccount;
                                        System.debug('@Developer --> CountUpdated 9 :');
                                        oUpdateStatusWrapper.SellerLiaisonCountUpdated = true;
                                                }
                                //}
                            }
                        }
                    }
                    else{
                        if(!oUpdateStatusWrapper.SellerLiaisonCountUpdated && mapUserWiseEngineerMapping.containsKey(a.Seller_Liaison__c)){
                         oUpdateStatusWrapper.SellerLiaisonCountUpdated = true;
                         Engineer_Mapping__c tmpEM = mapUserWiseEngineerMapping.get(a.Seller_Liaison__c);
                         if(tmpEM.No_of_Accounts_working_on__c != null){
                          tmpEM.No_of_Accounts_working_on__c++;
                         }
                         else{
                            tmpEM.No_of_Accounts_working_on__c = 1;
                         }
                         System.debug('@Developer --> CountUpdated 10 :');
                         mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
                        }
                    }
                }
                
            }
        }
        
        boolean bProceed = false;
        string sOldStatus=oldAccountMap.get(a.Id).Seller_Onboarding_Status__c;
        if(a.Seller_Onboarding_Status__c == 'Live on Site'){
            if((a.Seller_Onboarding_Live_Status__c == 'Ops Ready' && sOldStatus!='Live on Site' && sOldStatus!='On hold' && sOldStatus!='Abandoned') ||
               (a.Seller_Onboarding_Live_Status__c == 'Ops Ready' && a.Seller_Onboarding_Live_Status__c != oldAccountMap.get(a.Id).Seller_Onboarding_Live_Status__c)
            ){
                bProceed = true;
            }
        }
        else if((a.Seller_Onboarding_Status__c == 'On hold' || a.Seller_Onboarding_Status__c == 'Abandoned') && 
            (sOldStatus!='Live on Site' && sOldStatus!='On hold' && sOldStatus!='Abandoned')){
                bProceed = true;
            }
            System.debug('@Developer --> a.Seller_Onboarding_Status__c :' + a.Seller_Onboarding_Status__c);
            System.debug('@Developer --> sOldStatus :' + sOldStatus);
            System.debug('@Developer --> bProceed :' + bProceed);
            if(bProceed && !bSecondTime){
                Engineer_Mapping__c tmpEM;
                System.debug('@Developer --> a.Integration_Engineer__c :' + a.Integration_Engineer__c);
                if(mapUserWiseEngineerMapping.containsKey(a.Integration_Engineer__c)){
                    System.debug('@Developer --> mapUserWiseEngineerMapping.contains Integration_Engineer :');
                 tmpEM = mapUserWiseEngineerMapping.get(a.Integration_Engineer__c);
                 if(tmpEM.No_of_Accounts_working_on__c != null){
                    system.debug('@developer --> IE No_of_Accounts_working_on__c:'+tmpEM.No_of_Accounts_working_on__c );
                  tmpEM.No_of_Accounts_working_on__c--;
                  system.debug('@developer --> IE  No_of_Accounts_working_on__c:'+tmpEM.No_of_Accounts_working_on__c );
                  if(tmpEM.No_of_Accounts_working_on__c<0){
                    tmpEM.No_of_Accounts_working_on__c = 0;
                  }
                 }
                 else{
                    tmpEM.No_of_Accounts_working_on__c = 0;
                 }
                 mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
                }
                System.debug('@Developer --> a.Seller_Liaison__c :' + a.Seller_Liaison__c);
                if(mapUserWiseEngineerMapping.containsKey(a.Seller_Liaison__c)){
                    System.debug('@Developer --> mapUserWiseEngineerMapping.contains Seller_Liaison :');
                 tmpEM = mapUserWiseEngineerMapping.get(a.Seller_Liaison__c);
                 if(tmpEM.No_of_Accounts_working_on__c != null){
                    system.debug('@developer --> No_of_Accounts_working_on__c:'+tmpEM.No_of_Accounts_working_on__c );
                  tmpEM.No_of_Accounts_working_on__c--;
                    system.debug('@developer --> No_of_Accounts_working_on__c:'+tmpEM.No_of_Accounts_working_on__c );
                  if(tmpEM.No_of_Accounts_working_on__c<0){
                    tmpEM.No_of_Accounts_working_on__c = 0;
                  }
                 }
                 else{
                    tmpEM.No_of_Accounts_working_on__c = 0;
                 }
                 mapUserWiseEngineerMapping.put(tmpEM.User__c,tmpEM);
                }
            }
                
    }
    */
    private void ManageAccountShare(map<Id,Account> mapIdWiseAccountToAdd,map<Id,Account> mapIdWiseAccountToRemove,set<Id> setChannelPartner){
        
        set<Id> setContacts = new set<Id>();
        map<Id,Account> mapAccountWiseContact = new map<Id,Account>();
        List<AccountShare> lstAccountShareToInsert = new List<AccountShare>();
        string sDeleteCondition;
        for(Account oAccount :[Select Id,(Select Id From Contacts) From Account where id in :setChannelPartner]){
            mapAccountWiseContact.put(oAccount.Id,oAccount);
            if(oAccount.Contacts!=null){
                for(Contact oContact:oAccount.Contacts){
                    setContacts.add(oContact.Id);
                }
            }
        }
        map<Id,Id> mapContactWiseUser = new map<Id,Id>();
                for(User oUser:[Select Id,contactid From User Where contactid in :setContacts]){
                    mapContactWiseUser.put(oUser.contactid,oUser.Id);
                }
        for(Id IdAccount:mapIdWiseAccountToAdd.keySet()){
            Account oAccount = mapIdWiseAccountToAdd.get(IdAccount);
            if(oAccount.Channel_Partner__r!=null){
                for(Partner_Join__c oPartnerJoin:oAccount.Channel_Partner__r){
                    if(oPartnerJoin.Channel_Partner__c!=null){
                        if(mapAccountWiseContact.containsKey(oPartnerJoin.Channel_Partner__c)){
                            Account oAccountWithContact = mapAccountWiseContact.get(oPartnerJoin.Channel_Partner__c);
                            for(Contact oContact : oAccountWithContact.Contacts){
                                if(mapContactWiseUser.containsKey(oContact.Id)){
                                    Id IdUser=mapContactWiseUser.get(oContact.Id);
                                    AccountShare oAccountShare = new AccountShare();
                                                oAccountShare.AccountAccessLevel='Edit';
                                                oAccountShare.OpportunityAccessLevel='Edit';
                                                //oAccountShare.ContactAccessLevel='Edit';
                                                oAccountShare.CaseAccessLevel='Edit';
                                                oAccountShare.AccountId= IdAccount;
                                                oAccountShare.UserOrGroupId = IdUser;
                                                lstAccountShareToInsert.add(oAccountShare);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for(Id IdAccount:mapIdWiseAccountToRemove.keySet()){
            Account oAccount = mapIdWiseAccountToRemove.get(IdAccount);
            if(oAccount.Channel_Partner__r!=null){
                for(Partner_Join__c oPartnerJoin:oAccount.Channel_Partner__r){
                    if(oPartnerJoin.Channel_Partner__c!=null){
                        if(mapAccountWiseContact.containsKey(oPartnerJoin.Channel_Partner__c)){
                            Account oAccountWithContact = mapAccountWiseContact.get(oPartnerJoin.Channel_Partner__c);
                            for(Contact oContact : oAccountWithContact.Contacts){
                                if(mapContactWiseUser.containsKey(oContact.Id)){
                                    Id IdUser=mapContactWiseUser.get(oContact.Id);
                                    if(sDeleteCondition==null){
                                                    sDeleteCondition = ' Where ';
                                                }
                                                else{
                                                    sDeleteCondition += ' or ';
                                                }
                                                sDeleteCondition += '(AccountId=\''+IdAccount+'\' and UserOrGroupId=\''+IdUser+'\')';
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if(sDeleteCondition!=null){
                    string sQuery = 'Select Id From AccountShare'+sDeleteCondition;
                    List<AccountShare> lstAccountShareToDelete = database.query(sQuery);
                    if(lstAccountShareToDelete.size()>0){
                        delete lstAccountShareToDelete;
                    }
                }
        
        if(lstAccountShareToInsert.size()>0){
            insert lstAccountShareToInsert;
        }
        
    }
    
  /*  class UpdateStatusWrapper{
        public boolean SellerLiaisonCountUpdated = false;
        public boolean IntegrationEngineerCountUpdated = false;
        public boolean SellerLiaisonMethodFound = false;
                    public boolean IntegrationEngineerMethodFound = false;
    }
    class EngineerMapping implements Comparable{
        public Engineer_Mapping__c oEM;
        public decimal nPercentage{
            get{
                if(oEM != null){
                    if(oEM.No_of_Accounts_working_on__c != null && oEM.No_of_Accounts_working_on__c != 0 &&
                    oEM.Maximum__c != null && oEM.Maximum__c != 0
                    ){
                        return (oEM.No_of_Accounts_working_on__c / oEM.Maximum__c ) * 100;
                    }
                }
                return 0;
            }
            set;
        }
        public EngineerMapping(Engineer_Mapping__c em){
            oEM = em;
            nPercentage = oEM.Percentage__c;
            //System.debug('@Developer --> nPercentage :' + nPercentage);
        }
        
        public Integer compareTo(Object toCompare) {
            EngineerMapping oEMToCompare = (EngineerMapping) toCompare;
            //System.debug('@Developer --> nPercentage :' + nPercentage);
            //System.debug('@Developer --> oEMToCompare.nPercentage :' + oEMToCompare.nPercentage);
            if(nPercentage > oEMToCompare.nPercentage){
                return 1 ;
            }
            else if(nPercentage < oEMToCompare.nPercentage){
                return -1 ;
            }
            return 0;
        }
    }
    */
    
    public void updateContactType(list<Account> newList, map<id, Account> oldmap)
    {
        set<string> contactIdSet = new set<string>();
        Id idMpRecordType;
        for(recordtype rt : rtMap.values()){
            if(rt.DeveloperName == 'MP_Account') {
                idMpRecordType = rt.Id;
            }
        }

        for(Account a : newList){
            if(a.recordTypeId==idMpRecordType && a.Primary_Contact__c != null && (oldmap == null || oldmap.get(a.Id).Primary_Contact__c != a.Primary_Contact__c))
            {
                contactIdSet.add(a.Primary_Contact__c);
            }
        }
        
        if(contactIdSet.size() > 0)
        {
            list<Contact> contactList = [select id, Name, Contact_Type__c from Contact where id in : contactIdSet and Contact_Type__c excludes ('Marketplace Business Manager')];
            
            for(Contact c : contactList)
            {
                if(c.Contact_Type__c != null && c.Contact_Type__c.trim().length() > 0)
                    c.Contact_Type__c += ';Marketplace Business Manager';
                else
                    c.Contact_Type__c = 'Marketplace Business Manager';
            }
            
            if(contactList.size() > 0)
                update contactList;
        }
    }
    
}