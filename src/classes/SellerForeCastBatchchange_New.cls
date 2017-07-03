/**
* This class is a batch class that will go query all accounts and update "Onboarding Forecast" object
 
 * ======================================================================
 * @author  Ashok Panbuchelvam
 * Date        Purpose
 * 04/30/2016  Initial version.
 * ======================================================================
 **/

 global class SellerForeCastBatchchange_New implements Database.Batchable<sObject>,Database.Stateful{ 

        Integer sellerSetupCount = 0;
        Integer itemSetupCount = 0;
        Integer txsReadinessCount = 0;
        Integer launchReadinessCount = 0;
        Integer onholdCount = 0;
        Integer abandonedCount = 0;
        Integer preSellerSetupCount =0;  
        
        Integer actualCount = 0;
        Integer forecastCount1 = 0;
        Integer forecastCount2 = 0;
        Integer forecastCount3 = 0;
        Integer forecastCount4 = 0;
        Integer sellersInjectedCount = 0;
        // Partner Channel Variables
        
        Integer sellerSetupCount_Partner = 0;
        Integer itemSetupCount_Partner = 0;
        Integer txsReadinessCount_Partner = 0;
        Integer launchReadinessCount_Partner = 0;
        Integer onholdCount_Partner = 0;
        Integer abandonedCount_Partner = 0;
        Integer preSellerSetupCount_Partner =0;  
        
        Integer actualCount_Partner = 0;
        Integer forecastCount1_Partner = 0;
        Integer forecastCount2_Partner = 0;
        Integer forecastCount3_Partner = 0;
        Integer forecastCount4_Partner = 0;
        Integer sellersInjectedCount_Partner = 0;
        
        Integer cWeek = 0;
    Integer cWeek1 = 0;
    Integer cWeek2 = 0;
    Integer cWeek3 = 0;
    Integer cWeek4 = 0;
    
    Integer cYear = 0;
    Integer cYear1 = 0;
        Integer cYear2 = 0;
        Integer cYear3 = 0;
        Integer cYear4 = 0;
    map<string,Onboard_Forecast__c> mapOnboardForecast = new map<string,Onboard_Forecast__c>();
    
    boolean bSellerSetupFound = false;
        boolean bItemSetupFound = false;
        boolean bTransactionReadinessFound = false;
        boolean bLaunchReadinessFound = false;
    set<Integer> setWeeks;
    Date dtLastDateOfWeek;
    Date dtFirstDateofWeek;
    date dtFirstDateOfNextWeek;
    global SellerForeCastBatchchange_New(){
    
       
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        // query our object and process none successful records
            Map<String,Integer> onboardingCountbyChannel = new Map<String,Integer>();

        cWeek = GetWeekNumberFromDate(System.now());
         // To find the last and first day of the week 
           dtLastDateOfWeek = getLastDayOfWeek(cWeek,system.now().year());
           System.debug('@Developer --> ### Last day of week date only:' + dtLastDateOfWeek);
        dtFirstDateofWeek = dtLastDateOfWeek.adddays(-6);
        system.debug('@Developer --> ### First day of week date only:' + dtFirstDateofWeek);  
        system.debug('@Developer --> CurWeek:'+cWeek);
        
        Integer currentYear = System.Today().year();
        
        datetime dtStartOfYear = getLastDayOfWeek(1,system.now().year());
        dtStartOfYear=dtStartOfYear.addDays(-6);
        if(System.now().date()<dtStartOfYear){
          currentYear--;
        }
        
        Integer nextYear = currentYear + 1;
        List<Integer> yearList = new List<Integer>();
        cYear = currentYear;
        yearList.add(currentYear);
        yearList.add(nextYear);

        system.debug('yearList:'+yearList);
        List<Forecastweeks__c> forecastweeks = Forecastweeks__c.getAll().values();
        for(Forecastweeks__c forcast : forecastweeks){
            if(forcast.Name == 'Seller Setup'){
                    datetime dtTempdatetime=system.now().addDays(7* Integer.valueof(forcast.No_of_Weeks__c));
                cWeek1 = GetWeekNumberFromDate(dtTempdatetime);
                cYear1 = dtTempdatetime.year();
                datetime dtTempStartOfYear = getLastDayOfWeek(1,cYear1);
                        dtTempStartOfYear=dtTempStartOfYear.addDays(-6);
                        if(dtTempdatetime<dtTempStartOfYear){
                          cYear1--;
                        }
            }
            if(forcast.Name == 'Item Setup'){
                datetime dtTempdatetime=system.now().addDays(7* Integer.valueof(forcast.No_of_Weeks__c));
                cWeek2 = GetWeekNumberFromDate(dtTempdatetime);
                cYear2 = dtTempdatetime.year();
                datetime dtTempStartOfYear = getLastDayOfWeek(1,cYear2);
                        dtTempStartOfYear=dtTempStartOfYear.addDays(-6);
                        if(dtTempdatetime<dtTempStartOfYear){
                          cYear2--;
                        }
            }
            if(forcast.Name == 'Transaction Readiness'){
                datetime dtTempdatetime=system.now().addDays(7* Integer.valueof(forcast.No_of_Weeks__c));
                cWeek3 = GetWeekNumberFromDate(dtTempdatetime);
                cYear3 = dtTempdatetime.year();
                datetime dtTempStartOfYear = getLastDayOfWeek(1,cYear3);
                        dtTempStartOfYear=dtTempStartOfYear.addDays(-6);
                        if(dtTempdatetime<dtTempStartOfYear){
                          cYear3--;
                        }
            }
            if(forcast.Name == 'Launch Readiness'){
                datetime dtTempdatetime=system.now().addDays(7* Integer.valueof(forcast.No_of_Weeks__c));
                cWeek4 = GetWeekNumberFromDate(dtTempdatetime);
                cYear4 = dtTempdatetime.year();
                datetime dtTempStartOfYear = getLastDayOfWeek(1,cYear4);
                        dtTempStartOfYear=dtTempStartOfYear.addDays(-6);
                        if(dtTempdatetime<dtTempStartOfYear){
                          cYear4--;
                        }
            }
        }
    
            system.debug('cWeek:'+cWeek);
        system.debug('cWeek1:'+cWeek1);
        system.debug('cWeek2:'+cWeek2);
        system.debug('cWeek3:'+cWeek3);
        system.debug('cWeek4:'+cWeek4);
        system.debug('cYear:'+cYear);
        system.debug('cYear1:'+cYear1);
        system.debug('cYear2:'+cYear2);
        system.debug('cYear3:'+cYear3);
        system.debug('cYear4:'+cYear4);
        
        setWeeks = new set<Integer>();
        setWeeks.add(cWeek);
        setWeeks.add(cWeek1);
        setWeeks.add(cWeek2);
        setWeeks.add(cWeek3);
        setWeeks.add(cWeek4);
          
        List<Onboard_Forecast__c> oForecastTempList = [Select id,Year__c,Name,Integration_Channel__c from Onboard_Forecast__c where Week__c  = 1 AND (Year__c =: currentYear OR Year__c =: nextYear)];  
         
        if(oForecastTempList.size()>0){
           /*for(Onboard_Forecast__c oForecast: oForecastTempList){
               string strkey = string.valueof(oForecast.year__c)+'-'+oForecast.Integration_Channel__c;
               if(onboardingCountbyChannel.containskey(strkey)){
                  onboardingCountbyChannel.put(strkey,onboardingCountbyChannel.get(strkey)+1);  
               }
               else{
                  onboardingCountbyChannel.put(strkey,1);
               }

            } 
            system.debug('onboardingCountbyChannel:'+onboardingCountbyChannel);*/
            system.debug('@Developer --> Forecast data exists:');
            for(Onboard_Forecast__c oOnboardForecast : [Select id,Name,Week__c,Year__c,Actual__c,Forecast__c,Integration_Channel__c,Planned__c,Sellers_Injected__c,Variance__c,Week_Date__c 
                                                                                                    From Onboard_Forecast__c Where Week__c in : setWeeks AND (Year__c =: currentYear OR Year__c =: nextYear)]){
              string sKey=oOnboardForecast.Week__c+'|'+oOnboardForecast.Year__c+'|'+oOnboardForecast.Integration_Channel__c;
              mapOnboardForecast.put(sKey,oOnboardForecast);
            }
            system.debug('@Developer --> mapOnboardForecast.size():'+mapOnboardForecast.size());
        }
        else{
                system.debug('@Developer --> Forecast data does not exists:');
            for(Integer int1 : yearList){
                for(integer i=01;i<53;i++){
                 Onboard_Forecast__c oForeCast_temp = new Onboard_Forecast__c();
                 oForeCast_temp.Week__c= i;
                 oForeCast_temp.Year__c= int1;
                 oForeCast_temp.Integration_Channel__c= 'Direct';
                 oForeCast_temp.Actual__c= null;
                 //oFInsertList.add(oForeCast_temp); //use map mapOnboardForecast
                 string sKey=oForeCast_temp.Week__c+'|'+oForeCast_temp.Year__c+'|'+oForeCast_temp.Integration_Channel__c;
                      mapOnboardForecast.put(sKey,oForeCast_temp);
                }

                for(integer i=01;i<53;i++){
                 Onboard_Forecast__c oForeCast_temp1 = new Onboard_Forecast__c();
                 oForeCast_temp1.Week__c= i;
                 oForeCast_temp1.Year__c= int1;
                 oForeCast_temp1.Integration_Channel__c= 'Partner';
                 //oFInsertList.add(oForeCast_temp1); //use map mapOnboardForecast
                 string sKey=oForeCast_temp1.Week__c+'|'+oForeCast_temp1.Year__c+'|'+oForeCast_temp1.Integration_Channel__c;
                      mapOnboardForecast.put(sKey,oForeCast_temp1);
                }
            }
            system.debug('@Developer --> mapOnboardForecast.size():'+mapOnboardForecast.size()); 
        }
                dtFirstDateOfNextWeek = dtLastDateOfWeek.addDays(1);
        //system.debug('oFInsertList:'+oFInsertList);
        String mprecordType='MP_Account';
        String soqlString = 'Select Id,Name,Integration_Channel__c,Seller_Onboarding_Status__c,Seller_OBS_Last_Modified_Date__c From Account Where Type =\'Seller\' and Seller_OBS_Last_Modified_Date__c>= :dtFirstDateofWeek and Seller_OBS_Last_Modified_Date__c<:dtFirstDateOfNextWeek AND  RecordType.DeveloperName=:mprecordType limit 45000';
        system.debug('Query:'+soqlString);
        return Database.getQueryLocator(soqlString);
    }

    global void execute(Database.BatchableContext bc, List<sObject> accRecords){
        List<Account> accList = (List<Account>)accRecords;
        system.debug('@Developer --> accList.size():'+accList.size()); 
        Date acc_dt = null;

        Boolean isUpdate = false;
        system.debug('@Developer --> dtFirstDateofWeek:'+dtFirstDateofWeek);
        system.debug('@Developer --> dtLastDateOfWeek:'+dtLastDateOfWeek);
        system.debug('@Developer --> dtFirstDateOfNextWeek:'+dtFirstDateOfNextWeek);
         
        for(Account acc : accList){
            system.debug('Acc Name:'+ acc.Name);
            acc_dt = null;
            system.debug('@Developer --> acc.Seller_OBS_Last_Modified_Date__c:'+acc.Seller_OBS_Last_Modified_Date__c);
            if(acc.Seller_OBS_Last_Modified_Date__c != null){
                acc_dt = acc.Seller_OBS_Last_Modified_Date__c.date();
            }
            system.debug('@Developer --> acc_dt:'+acc_dt);    
            if(acc.Integration_Channel__c == 'Direct'){
              if(acc_dt != null && (acc_dt>=dtFirstDateofWeek && acc_dt<dtFirstDateOfNextWeek)){
                if(acc.Seller_Onboarding_Status__c == 'Live on Site'){
                    actualCount++;  
                    system.debug('actualCountTest:'+actualCount); 
                }
                if(acc.Seller_Onboarding_Status__c == 'Ready to Onboard'){
                    sellersInjectedCount++; 
                    system.debug('sellersInjectedCountTest:'+sellersInjectedCount);
                }
                if(acc.Seller_Onboarding_Status__c == 'Pre Seller Setup'){
                     preSellerSetupCount++; 
                     system.debug('preSellerSetupCountTest:'+preSellerSetupCount);
                }
                
                if(acc.Seller_Onboarding_Status__c == 'Seller Setup'){
                   sellerSetupCount++; 
                   system.debug('sellerSetupCountTest:'+sellerSetupCount);
                 }
                if(acc.Seller_Onboarding_Status__c == 'Item Setup'){
                    itemSetupCount++;
                    system.debug('itemSetupCountTest:'+itemSetupCount); 
                }
                if(acc.Seller_Onboarding_Status__c == 'Transaction Readiness'){
                    txsReadinessCount++;
                    system.debug('txsReadinessCountTest:'+txsReadinessCount); 
                }
                if(acc.Seller_Onboarding_Status__c == 'Launch Readiness'){
                    launchReadinessCount++; 
                    system.debug('launchReadinessCountTest:'+launchReadinessCount);
                }
                if(acc.Seller_Onboarding_Status__c == 'On hold'){
                    onholdCount++; 
                    system.debug('onholdCountTest:'+onholdCount);
                }
                if(acc.Seller_Onboarding_Status__c == 'Abandoned'){
                    abandonedCount++; 
                       system.debug('abandonedCountTest:'+abandonedCount);
                }
              }

              if(acc.Seller_Onboarding_Status__c == 'Seller Setup'){
                  forecastCount1++;
                  bSellerSetupFound = true;
              }
              if(acc.Seller_Onboarding_Status__c == 'Item Setup'){
                  forecastCount2++;
                  bItemSetupFound = true;
              }
              if(acc.Seller_Onboarding_Status__c == 'Transaction Readiness'){
                  forecastCount3++;
                  bTransactionReadinessFound = true;
              }
              if(acc.Seller_Onboarding_Status__c == 'Launch Readiness'){
                  forecastCount4++;
                  bLaunchReadinessFound = true;
              }
            }
            else if(acc.Integration_Channel__c == 'Partner'){
              if(acc_dt != null && (acc_dt>=dtFirstDateofWeek && acc_dt<dtFirstDateOfNextWeek)){
                if(acc.Seller_Onboarding_Status__c == 'Live on Site'){
                    actualCount_Partner++;
                    system.debug('actualCount_Partner_Test:'+actualCount_Partner);   
                }
                if(acc.Seller_Onboarding_Status__c == 'Ready to Onboard'){
                    sellersInjectedCount_Partner++; 
                    system.debug('sellersInjectedCount_Partner_Test:'+sellersInjectedCount_Partner);  
                }
                if(acc.Seller_Onboarding_Status__c == 'Pre Seller Setup'){
                     preSellerSetupCount_Partner++; 
                     system.debug('preSellerSetupCount_Partner_Test:'+preSellerSetupCount_Partner);  
                }
                if(acc.Seller_Onboarding_Status__c == 'Seller Setup'){
                   sellerSetupCount_Partner++; 
                    system.debug('sellerSetupCount_Partner_Test:'+sellerSetupCount_Partner);  
                 }
                if(acc.Seller_Onboarding_Status__c == 'Item Setup'){
                    itemSetupCount_Partner++; 
                    system.debug('itemSetupCount_Partner_Test:'+itemSetupCount_Partner);  
                }
                if(acc.Seller_Onboarding_Status__c == 'Transaction Readiness'){
                    txsReadinessCount_Partner++; 
                    system.debug('txsReadinessCount_Partner_Test:'+txsReadinessCount_Partner);  
                }
                if(acc.Seller_Onboarding_Status__c == 'Launch Readiness'){
                    launchReadinessCount_Partner++;
                    system.debug('launchReadinessCount_Partner_Test:'+launchReadinessCount_Partner);   
                }
                if(acc.Seller_Onboarding_Status__c == 'On hold'){
                    onholdCount_Partner++; 
                    system.debug('onholdCount_Partner_Test:'+onholdCount_Partner);  
                }
                if(acc.Seller_Onboarding_Status__c == 'Abandoned'){
                    abandonedCount_Partner++; 
                    system.debug('abandonedCount_Partner_Test:'+abandonedCount_Partner);  
                }
              }
              if(acc.Seller_Onboarding_Status__c == 'Seller Setup'){
                  forecastCount1_Partner++;
                  bSellerSetupFound = true;
              }
              if(acc.Seller_Onboarding_Status__c == 'Item Setup'){
                  forecastCount2_Partner++;
                  bItemSetupFound = true;
              }
              if(acc.Seller_Onboarding_Status__c == 'Transaction Readiness'){
                  forecastCount3_Partner++;
                  bTransactionReadinessFound = true;
              }
              if(acc.Seller_Onboarding_Status__c == 'Launch Readiness'){
                  forecastCount4_Partner++;
                  bLaunchReadinessFound = true;
              }
            }
        }
        system.debug('Item Setup:'+itemSetupCount_Partner);
    }
    
    private Integer GetWeekNumberFromDate(DateTime tmpDateTime){
            Integer cWeek = Integer.valueOf(tmpDateTime.format('w'));
        integer nYear = tmpDateTime.year();
        if(tmpDateTime.month()==1){
            nYear--;
            Integer nPastWeeks =  Integer.valueOf(DateTime.newInstance(nYear,12,31).format('w'));
            if(nPastWeeks ==1){
                nPastWeeks=52;
            }
            cWeek +=nPastWeeks;
        }
        DateTime janDateTime = DateTime.newInstance(nYear,1,31);
        Date janDate = Date.newInstance(nYear,1,31);
        Integer janWeeks = Integer.valueOf(janDateTime.format('w'));
            cWeek -= janWeeks ;
        if(janDate.toStartOfWeek().addDays(6) > janDate){
         cWeek ++;
        }
        integer nWeekday = Integer.valueOf(tmpDateTime.format('u'));
        Date DateStartofWeek = janDate.toStartOfWeek();
        DateTime dtStartofWeek = DateTime.newInstance(DateStartofWeek.year(),DateStartofWeek.month(),DateStartofWeek.day());
        System.debug('dtStartofWeek:'+dtStartofWeek);
        integer nStartofWeek = Integer.valueOf(dtStartofWeek.format('u'));
        if(nWeekday==6 ||(nWeekday==7 && nStartofWeek==1)){
            cWeek +=1;
        }
        if(cWeek>52){
            cWeek = cWeek-52; 
        }
        return cWeek;
    }

    /*private  DateTime ParseStringToDatetime(String sTempDate){
        DateTime tmpDateTime;
        system.debug('sTempDate:'+sTempDate);
        if(sTempDate != null && sTempDate!=''){
            list<String> lstDt = sTempDate.split('/');
            system.debug('lstDt:'+lstDt);
            if(lstDt.size()>2){
                tmpDateTime = DateTime.newInstance(Integer.valueOf(lstDt[2].split(' ')[0]),Integer.valueOf(lstDt[0]),Integer.valueOf(lstDt[1]));
            }
        }
        return tmpDateTime;
    }*/
    
    public Date getLastDayOfWeek(integer week,Integer nYear) {
          date retDate;
          Date baseDate = Date.newInstance(nYear,2,01);
          retDate = baseDate;
          if(week>0){
            integer nDaysToAdd = (week-1)*7;
            date weekdate = baseDate.addDays(nDaysToAdd);
            date dStartOfWeek = weekdate.toStartOfWeek();
            datetime dtStartOfWeek = DateTime.newInstance(dStartOfWeek.year(),dStartOfWeek.month(),dStartOfWeek.day());
            integer nStartofWeek = Integer.valueOf(dtStartofWeek.format('u'));
            integer nAdditionalDaysToAdd = 5;
            if(nStartofWeek==1){
              nAdditionalDaysToAdd = 4;
            }
            retDate = dStartOfWeek.addDays(nAdditionalDaysToAdd);
          }
          return retDate;
        }

    global void finish(Database.BatchableContext bc){
      system.debug('@Developer --> finish:');
              if(mapOnboardForecast.size()>0){    
        string sKey = cWeek+'|'+cYear+'|'+'Direct';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Actual__c = actualCount;
          of1.Sellers_Injected__c= sellersInjectedCount;
          of1.Pre_Seller_Set_Up__c =preSellerSetupCount;
          of1.Abandoned__c = abandonedCount;
          of1.Item_Setup__c = itemSetupCount;
          of1.Launch_Readiness__c = launchReadinessCount;
          of1.On_hold__c = onholdCount;
          of1.Seller_Setup__c = sellerSetupCount;
          of1.Transaction_Readiness__c = txsReadinessCount;
          of1.Week_Date__c = dtFirstDateofWeek;
        }
        
        sKey = cWeek+'|'+cYear+'|'+'Partner';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Actual__c = actualCount_Partner;
          of1.Sellers_Injected__c= sellersInjectedCount_Partner;
          of1.Pre_Seller_Set_Up__c =preSellerSetupCount_Partner;
          of1.Abandoned__c = abandonedCount_Partner;
          of1.Item_Setup__c = itemSetupCount_Partner;
          of1.Launch_Readiness__c = launchReadinessCount_Partner;
          of1.On_hold__c = onholdCount_Partner;
          of1.Seller_Setup__c = sellerSetupCount_Partner;
          of1.Transaction_Readiness__c = txsReadinessCount_Partner;
          of1.Week_Date__c = dtFirstDateofWeek;
        }
        
        sKey = cWeek1+'|'+cYear1+'|'+'Direct';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount1;
        }
        
        sKey = cWeek1+'|'+cYear1+'|'+'Partner';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount1_Partner;
        }
        
        sKey = cWeek2+'|'+cYear2+'|'+'Direct';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount2;
        }
        
        sKey = cWeek2+'|'+cYear2+'|'+'Partner';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount2_Partner;
        }
        
        sKey = cWeek3+'|'+cYear3+'|'+'Direct';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount3;
        }
        
        sKey = cWeek3+'|'+cYear3+'|'+'Partner';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount3_Partner;
        }
        
        sKey = cWeek4+'|'+cYear4+'|'+'Direct';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount4;
        }
        
        sKey = cWeek4+'|'+cYear4+'|'+'Partner';
        if(mapOnboardForecast.containsKey(sKey)){
          Onboard_Forecast__c of1 = mapOnboardForecast.get(sKey);
          of1.Forecast__c = forecastCount4_Partner;
        }
        
        try {
          upsert mapOnboardForecast.values();
            }
            catch(Exception ex) {
          System.debug('Dev: Error is ' + ex.getMessage());                   
            }
              }
    }
}