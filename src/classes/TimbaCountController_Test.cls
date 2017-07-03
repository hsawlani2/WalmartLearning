@isTest
private class TimbaCountController_Test {

    static testMethod void test() {
    List<Case> caseList = new List<Case>();
    
        Account acc = new Account();
        acc.Name = 'TestAcc';
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
        acc.Seller_Onboarding_Status__c = 'Launch Readiness';
        acc.Type = 'Seller';
        acc.Category__c ='Baby';
        insert acc;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc.id;
        insert con;
        RecordType rt = [Select id,developerName from RecordType where sObjectType='Case' And developerName ='Seller_Community_Case'];
        
    for(integer i =1; i<10; i++){
        case ca = new case();
        ca.Status ='Closed';
        ca.Priority= 'P1';
        ca.Issue_Category__c= 'Order';
        //ca.Auto_Create_JIRA_Issue__c = true;
        ca.Accountid= acc.id;
        ca.Contactid= con.id;
        ca.recordtypeid =rt.id; 
        caseList.add(ca);
        }
        
    insert caseList;
    
    TIMBASURVEYS__Survey_Summary__c ts = new TIMBASURVEYS__Survey_Summary__c();
    ts.Name='Case Resolution Satisfaction Survey';
    
    insert ts;
    
    TimbaCountController pcCaseController = new TimbaCountController();
     String str = 'Test';
     Integer int1 =10;
     String str2 = 'Test';
     Integer int2 =10;
     TimbaCountController.CutsomPieWidget pData = new TimbaCountController.CutsomPieWidget(str,int1,int2,str2);
     pcCaseController.sDate = Date.today() -10;
     pcCaseController.eDate = Date.today()+10;
    
     
     pcCaseController.count_All_Cases= 100;
     pcCaseController.Count_unresponsive_Cases= 80;
     pcCaseController.count_Deflected= 20;
     pcCaseController.count_Non_Deflected= 50;
     pcCaseController.allCasesList = 100;
     pcCaseController.deflectedList = 20;
    
     
      pcCaseController.PopulateChartData();
       pcCaseController.getPieData();
    
    }
 }