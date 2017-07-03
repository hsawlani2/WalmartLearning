@isTest
private class OnboardCumulative_Test {
   // static boolean isUpdating=false;
    static testMethod void test() {
        List<Onboard_Forecast__c> InsertList = new List<Onboard_Forecast__c>();
        List<Onboard_Forecast__c> updateList = new List<Onboard_Forecast__c>();
         List<Onboard_Forecast__c> updateList1 = new List<Onboard_Forecast__c>();

        for (Integer i=1;i<53;i++) {
            Onboard_Forecast__c Onb = new Onboard_Forecast__c();
            Onb.Actual__c = i;
            Onb.Week__c = i;
            Onb.Planned__c= i +5;
            Onb.Cumulative_Actual__c=0;
            Onb.Cumulative_Revised_Forecast__c=0;
            Onb.Revised_Forecast__c= i +2;
            Onb.Year__c = 2016;
            Onb.Integration_Channel__c = 'Direct';
            InsertList.add(Onb);
                
        }
          
        for (Integer i=1;i<53;i++) {
            Onboard_Forecast__c Onb1 = new Onboard_Forecast__c();
            Onb1.Actual__c = i;
            Onb1.Week__c = i;
            Onb1.Year__c = 2016;
            Onb1.Cumulative_Actual__c=0;
            Onb1.Cumulative_Revised_Forecast__c=0;
            Onb1.Planned__c= i +2;
            Onb1.Revised_Forecast__c= i +5;
            Onb1.Integration_Channel__c = 'Partner';
            InsertList.add(Onb1);
                
        }
        
        insert InsertList;
        
        updateList = [select id, name,Actual__c, Cumulative_Actual__c, Week__c from Onboard_Forecast__c WHERE Year__c =2016 AND Integration_Channel__c ='Direct' AND Week__c =1];
        
        for( Onboard_Forecast__c up :updateList ){
            up.Planned__c= 10;
            
            }
      
           update updateList;
           
           updateList[0].Actual__c = 0;
           updateList[0].Planned__c= 0;
           updateList[0].Revised_Forecast__c= 0;
           
           update updateList;
           

        updateList1 = [select id, name,Actual__c, Cumulative_Actual__c, Week__c from Onboard_Forecast__c WHERE Year__c =2016 AND Integration_Channel__c ='Partner' AND Week__c =10];
        
        for( Onboard_Forecast__c up :updateList1 ){
            up.Planned__c= 10;
            
            }
      
           update updateList1;
           
           updateList1[0].Actual__c = 0;
           updateList1[0].Planned__c= 0;
           updateList1[0].Revised_Forecast__c= 0;
           
           update updateList1;
           
        
    }
    
  }