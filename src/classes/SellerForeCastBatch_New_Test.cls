@isTest
private class SellerForeCastBatch_New_Test {

    static testMethod void test() {
       
       List<Account> accList = new List<Account>();
       List<Account> accList1 = new List<Account>();
       List<Account> channelPartnerAccList = new List<Account>();
       List<Partner_Join__c> pjList = new List<Partner_Join__c>();
       
       
       
       List<Forecastweeks__c> lstforecast = new List<Forecastweeks__c>();//bulk List of custom setting object for bulk insert

       Forecastweeks__c csForecastFields = new Forecastweeks__c(); //Custom Setting for Contact Fields
       csForecastFields.Name='Seller Setup';//Static record 1 of custom setting
       csForecastFields.No_of_Weeks__c= 5;
       lstforecast.add(csForecastFields);

       Forecastweeks__c csForecastFields1 = new Forecastweeks__c(); //Custom Setting for Contact Fields
       csForecastFields1.Name='Item Setup';//Static record 1 of custom setting
       csForecastFields1.No_of_Weeks__c= 4;
       lstforecast.add(csForecastFields1);

       Forecastweeks__c csForecastFields2 = new Forecastweeks__c(); //Custom Setting for Contact Fields
       csForecastFields2.Name='Transaction Readiness';//Static record 1 of custom setting
       csForecastFields2.No_of_Weeks__c= 3;
       lstforecast.add(csForecastFields2);
       
       Forecastweeks__c csForecastFields3 = new Forecastweeks__c(); //Custom Setting for Contact Fields
       csForecastFields3.Name='Launch Readiness';//Static record 1 of custom setting
       csForecastFields3.No_of_Weeks__c= 2;
       lstforecast.add(csForecastFields3);
       
       insert lstforecast;
       

       for (Integer i=5;i<51;i++) {
           
          if(i<20){
            Account acc = new Account();
            acc.Name = 'TestAcc' + String.valueof(i);
            acc.ShippingStreet              = '1 Main St.';
            acc.ShippingState               = 'Alaska';
            acc.ShippingPostalCode          = '12345';
            acc.ShippingCountry             = 'United States';
            acc.ShippingCity                = 'Anytown';
            acc.Description                 = 'This is a test account';
            acc.BillingStreet               = '1 Main St.';
            acc.BillingState                = 'Alaska';
            acc.BillingPostalCode           = '12345';
            acc.BillingCountry              = 'United States';
            acc.BillingCity                 = 'Anytown';
            acc.Integration_Channel__c      = 'Direct';
            acc.Category__c                 = 'Baby';
            acc.Seller_Onboarding_Status__c = 'Launch Readiness';
            acc.Type = 'Seller';
            accList.add(acc);
          } 

          else if(i>20&& i<40){
             Account acc1 = new Account();
            acc1.Name = 'TestAcc' + String.valueof(i);
            acc1.ShippingStreet              = '1 Main St.';
            acc1.ShippingState               = 'Alaska';
            acc1.ShippingPostalCode          = '12345';
            acc1.ShippingCountry             = 'United States';
            acc1.ShippingCity                = 'Anytown';
            acc1.Description                 = 'This is a test account';
            acc1.BillingStreet               = '1 Main St.';
            acc1.BillingState                = 'Alaska';
            acc1.BillingPostalCode           = '12345';
            acc1.BillingCountry              = 'United States';
            acc1.BillingCity                 = 'Anytown';
            acc1.Integration_Channel__c      = 'Direct';
            acc1.Category__c                 = 'Baby';
            acc1.Seller_Onboarding_Status__c = 'Transaction Readiness';
            acc1.Type = 'Seller';
            accList.add(acc1);
          }  

          else  {
             Account acc2 = new Account();
            acc2.Name = 'TestAcc' + String.valueof(i);
            acc2.ShippingStreet              = '1 Main St.';
            acc2.ShippingState               = 'Alaska';
            acc2.ShippingPostalCode          = '12345';
            acc2.ShippingCountry             = 'United States';
            acc2.ShippingCity                = 'Anytown';
            acc2.Description                 = 'This is a test account';
            acc2.BillingStreet               = '1 Main St.';
            acc2.BillingState                = 'Alaska';
            acc2.BillingPostalCode           = '12345';
            acc2.BillingCountry              = 'United States';
            acc2.BillingCity                 = 'Anytown';
            acc2.Integration_Channel__c      = 'Direct';
            acc2.Category__c                 = 'Baby';
            acc2.Seller_Onboarding_Status__c = 'Item Setup';
            acc2.Type = 'Seller';

            accList.add(acc2);
 

          }

          
          

       }
       insert accList;

       for(integer i = 1; i<7;i++){
          Account acc3 = new Account();
            acc3.Name = 'TestChannelAcc' + String.valueof(i);
            acc3.ShippingStreet              = '1 Main St.';
            acc3.ShippingState               = 'Alaska';
            acc3.ShippingPostalCode          = '12345';
            acc3.ShippingCountry             = 'United States';
            acc3.ShippingCity                = 'Anytown';
            acc3.Description                 = 'This is a test account';
            acc3.BillingStreet               = '1 Main St.';
            acc3.BillingState                = 'Alaska';
            acc3.BillingPostalCode           = '12345';
            acc3.BillingCountry              = 'United States';
            acc3.BillingCity                 = 'Anytown';
            acc3.Integration_Channel__c      = 'Direct';
            acc3.Category__c                 = 'Baby';
            //acc3.Seller_Onboarding_Status__c = 'Item Setup';
            acc3.Type = 'Channel Partner';
            channelPartnerAccList.add(acc3);
       }
       Insert  channelPartnerAccList;
       //Creating Partner Joint Records to update Account records (Integratio channel = Partner)
       
          Partner_Join__c pj = new Partner_Join__c();
          pj.Seller__c = accList[0].id;
          pj.Channel_Partner__c = channelPartnerAccList[0].id;

          pjList.add(pj);

          Partner_Join__c pj1 = new Partner_Join__c();
          pj1.Seller__c = accList[21].id;
          pj1.Channel_Partner__c = channelPartnerAccList[1].id;

          pjList.add(pj1);

          Partner_Join__c pj2 = new Partner_Join__c();
          pj2.Seller__c = accList[42].id;
          pj2.Channel_Partner__c = channelPartnerAccList[2].id;

          pjList.add(pj2);

          Partner_Join__c pj3 = new Partner_Join__c();
          pj3.Seller__c = accList[16].id;
          pj3.Channel_Partner__c = channelPartnerAccList[3].id;

          pjList.add(pj3);

          Partner_Join__c pj4 = new Partner_Join__c();
          pj4.Seller__c = accList[10].id;
          pj4.Channel_Partner__c = channelPartnerAccList[4].id;

          pjList.add(pj4);


          //Insert pjList;
       

       accList1 = [Select Name,Seller_Onboarding_Status__c from Account];
       for(Account acc: accList1){
          if(acc.Name == 'TestAcc1'){
            acc.Seller_Onboarding_Status__c = 'Item Setup';
          }
          else if(acc.Name == 'TestAcc2'){
            acc.Seller_Onboarding_Status__c = 'Seller Setup';
          }
          else if(acc.Name == 'TestAcc3'){
            acc.Seller_Onboarding_Status__c = 'Transaction Readiness';
          }
          else if(acc.Name == 'TestAcc4'){
            acc.Seller_Onboarding_Status__c = 'Launch Readiness';
          }
          else if(acc.Name == 'TestAcc5'){
            acc.Seller_Onboarding_Status__c = 'Live on Site';
          }
          else if(acc.Name == 'TestAcc6'){
            acc.Seller_Onboarding_Status__c = 'Ready to Onboard';
          }
          else if(acc.Name == 'TestAcc7'){
            acc.Seller_Onboarding_Status__c = 'Pre Seller Setup';
          }
          else if(acc.Name == 'TestAcc8'){
            acc.Seller_Onboarding_Status__c = 'On hold';
            acc.On_hold_Reason__c = 'Seller Request';            
          }
          else if(acc.Name == 'TestAcc9'){
            acc.Seller_Onboarding_Status__c = 'Abandoned';
          }  
          else if(acc.Name == 'TestAcc21'){
            acc.Seller_Onboarding_Status__c = 'Seller Setup';
          }
          else if(acc.Name == 'TestAcc31'){
            acc.Seller_Onboarding_Status__c = 'Seller Setup';
          }
          else if(acc.Name == 'TestAcc41'){
            acc.Seller_Onboarding_Status__c = 'Seller Setup';
          }
          else if(acc.Name == 'TestAcc17'){
            acc.Seller_Onboarding_Status__c = 'Seller Setup';
          }
          else if(acc.Name == 'TestAcc11'){
            acc.Seller_Onboarding_Status__c = 'Item Setup';
          }
          else if(acc.Name == 'TestAcc43'){
            acc.Seller_Onboarding_Status__c = 'Transaction Readiness';
          }
          else if(acc.Name == 'TestAcc41'){
            acc.Seller_Onboarding_Status__c = 'Launch Readiness';
          }
          acc.Seller_Onboarding_Live_Status__c = 'Launched';
       }


       update accList1;

       List<Onboard_Forecast__c> oForecastList = new List<Onboard_Forecast__c>();
       Integer yr = Date.today().Year();
       for(integer i=1;i<52;i++){

            Onboard_Forecast__c oForeCast_temp1 = new Onboard_Forecast__c();
            oForeCast_temp1.Year__c = yr;
            oForeCast_temp1.Week__c = i;
            oForeCast_temp1.Integration_Channel__c = 'Partner';
            oForecastList.add(oForeCast_temp1);
           
       }

       for(integer i=1;i<52;i++){
          
            Onboard_Forecast__c oForeCast_temp3 = new Onboard_Forecast__c();
            oForeCast_temp3.Year__c = yr;
            oForeCast_temp3.Week__c = i;
            oForeCast_temp3.Integration_Channel__c = 'Direct';
            oForecastList.add(oForeCast_temp3);
            
       }



       Insert oForecastList;


       Test.startTest();
       SellerForeCastBatchchange_New batch = new SellerForeCastBatchchange_New();
       Database.executeBatch(batch, 200);
       Test.stopTest();

    }
    
    
}