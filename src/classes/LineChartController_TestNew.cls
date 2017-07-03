@isTest
private class LineChartController_TestNew {

    static testMethod void test() {
    List<Onboard_Forecast__c> onbList = new List<Onboard_Forecast__c>();
    List<Onboard_Forecast__c> onbList1 = new List<Onboard_Forecast__c>();
        

    for(integer i =1; i<52; i++){
        Onboard_Forecast__c ca = new Onboard_Forecast__c();
        ca.Actual__c = 3 + i;
        ca.Week__c= i;
        ca.Planned__c = 10 +i ; 
        ca.Revised_Forecast__c =5 + i;
        ca.Year__c = 2016;
        ca.Integration_Channel__c = 'Direct';
        onbList.add(ca);
        
        }
        
        Onboard_Forecast__c caa = new Onboard_Forecast__c();
        caa.Actual__c = null;
        caa.Week__c= 52;
        caa.Planned__c = null ; 
        caa.Revised_Forecast__c =5;
        caa.Year__c = 2016;
        caa.Integration_Channel__c = 'Direct';
        onbList.add(caa);
        

    insert onbList;

    for(integer i =1; i<52; i++){
        Onboard_Forecast__c ca1 = new Onboard_Forecast__c();
        ca1.Actual__c = 3 + i;
        ca1.Week__c= i;
        ca1.Planned__c = 10 +i ; 
        ca1.Revised_Forecast__c =5 + i;
        ca1.Year__c = 2016;
        ca1.Integration_Channel__c = 'Partner';
        onbList1.add(ca1);
        
        }

        Onboard_Forecast__c caa1 = new Onboard_Forecast__c();
        caa1.Actual__c = null;
        caa1.Week__c= 52;
        caa1.Planned__c = null; 
        caa1.Revised_Forecast__c =5;
        caa1.Year__c = 2016;
        caa1.Integration_Channel__c = 'Partner';
        onbList1.add(caa1);
    

    insert onbList1;    
    
     LineChartController lcChartController = new LineChartController();
     Integer name = 1;
     Integer actual = 5;
     Integer revisedforecast= 10;
     Integer planned = 15;
     LineChartController.Data  pData = new LineChartController.Data(name,actual,revisedforecast,planned);
    // LineChartController.getRemoteData();
     LineChartController.getChartData();
     LineChartController.getChartData2();
     LineChartController.getData();
     LineChartController.getData2();

     //LineChartController.DataWrapper  pData1 = new LineChartController.DataWrapper(name,actual,planned);
     LineChartController.getChartData3();
     LineChartController.getData3();
    }
    
 }