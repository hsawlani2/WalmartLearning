@isTest
private class CumulativeLineChartController_Test {

    static testMethod void test() {
    List<Onboard_Forecast__c> onbList = new List<Onboard_Forecast__c>();
     List<Onboard_Forecast__c> onbList1 = new List<Onboard_Forecast__c>();
    for(integer i =0; i<30; i++){
        Onboard_Forecast__c ca = new Onboard_Forecast__c();
        ca.Actual__c = 3 + i;
        ca.Week__c= i;
        ca.Planned__c = 10 +i ; 
        ca.Year__c = 2016;
        ca.Revised_Forecast__c=5 + i;
        ca.Integration_Channel__c= 'Direct';
        onbList.add(ca);
        }
        
        for(integer i =31; i<53; i++){
        Onboard_Forecast__c ca = new Onboard_Forecast__c();
        ca.Actual__c = null;
        ca.Week__c= i;
        ca.Planned__c = null ; 
        ca.Year__c = 2016;
        ca.Revised_Forecast__c=null;
        ca.Integration_Channel__c= 'Direct';
        onbList.add(ca);
        }
                
       insert onbList;
       
    for(integer i =0; i<30; i++){
        Onboard_Forecast__c ca1 = new Onboard_Forecast__c();
        ca1.Actual__c = 3 + i;
        ca1.Week__c= i;
        ca1.Planned__c = 10 +i ; 
        ca1.Revised_Forecast__c=5 + i;
        ca1.Year__c = 2016;
        ca1.Integration_Channel__c= 'Partner';
        onbList1.add(ca1);
        } 
        
        for(integer i =31; i<53; i++){
        Onboard_Forecast__c ca1 = new Onboard_Forecast__c();
        ca1.Actual__c = null;
        ca1.Week__c= i;
        ca1.Planned__c = null ; 
         ca1.Year__c = 2016;
        ca1.Revised_Forecast__c=null;
        ca1.Integration_Channel__c= 'Partner';
        onbList1.add(ca1);
        }    
    insert onbList1;
    
   
    
     CumulativeLineChartController lcChartController = new CumulativeLineChartController ();
     Integer name = 1;
     Integer actual = 5;
     Integer revisedforecast= 10;
     Integer variance = 15;
     CumulativeLineChartController.Data  pData = new CumulativeLineChartController.Data(name,actual,revisedforecast,variance);
     CumulativeLineChartController.getChartData2();
     CumulativeLineChartController.getChartData3();
     CumulativeLineChartController.getChartData();
     CumulativeLineChartController.getData();

    }
    
 }