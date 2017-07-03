@isTest(seealldata=true)
private class PieChartCaseController_Test {

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
        ca.Status ='New';
        ca.Priority= 'P1';
        ca.Issue_Category__c= 'Order';
        ca.Auto_Create_JIRA_Issue__c = true;
        ca.Accountid= acc.id;
        ca.Contactid= con.id;
        ca.recordtypeid =rt.id; 
        caseList.add(ca);
        }
        
    insert caseList;
    
    List<zsfjira__ZIssue__c> Zlist = new List<zsfjira__ZIssue__c>();
    
    for(integer i =1;i<10;i++){
        zsfjira__ZIssue__c za = new zsfjira__ZIssue__c();
        za.Name= 'Test'+ String.valueof(i);
        za.zsfjira__IssueKey__c= 'Test'+ String.valueof(i);
        za.zsfjira__IssueId__c= i;
        za.zsfjira__IssueType__c = 'Order';
        Zlist.add(za);
        }
      insert Zlist;
      
     zsfjira__ZIssue_Case__c zc = new zsfjira__ZIssue_Case__c ();
     zc.Name= 'Test';
     zc.zsfjira__CaseId__c = caseList[1].id;
     zc.zsfjira__ZIssueId__c = Zlist[1].id;
     insert zc;

     PieChartCaseController pcCaseController = new PieChartCaseController();
     String str = 'Test';
     Integer int1 =10;
     PieChartCaseController.PieWedgeData  pData = new PieChartCaseController.PieWedgeData(str,int1);
     pcCaseController.sDate = Date.today() -10;
     pcCaseController.eDate = Date.today()+10;
     pcCaseController.Percantage_withoutjira = 50.00;
     pcCaseController.count_All = 100.00;
     pcCaseController.Percantage_jira = 50.00;
     pcCaseController.count_Non_Zira_Item= 12;
     pcCaseController.count_Non_Zira_Inventory= 11;
     pcCaseController.count_Non_Zira_Order= 10;
     pcCaseController.count_Non_Zira_Payment= 50;
     pcCaseController.count_Non_Zira_Reconciliation= 12;
     pcCaseController.count_Non_Zira_Other= 11;
     pcCaseController.count_Non_Zira_Portal= 10;
     
     pcCaseController.count_Zira_Item= 12;
     pcCaseController.count_Zira_Inventory= 11;
     pcCaseController.count_Zira_Order= 10;
     pcCaseController.count_Zira_Payment= 50;
     pcCaseController.count_Zira_Reconciliation= 12;
     pcCaseController.count_Zira_Other= 11;
     pcCaseController.count_Zira_Portal= 10;
     
     pcCaseController.count_All_Item= 50;
     pcCaseController.count_Non_Zira_Item= 12;
     pcCaseController.count_All_Inventory= 11;
     pcCaseController.count_All_Order= 10;
     pcCaseController.count_All_Payment= 50;
     pcCaseController.count_All_Reconciliation= 12;
     pcCaseController.count_All_Other= 11;
     pcCaseController.count_All_Portal= 10;

     pcCaseController.dummyfunction();
     pcCaseController.getPieData();
     pcCaseController.getPieData1();
     pcCaseController.getPieData2();
     
      pcCaseController.PopulateChartData();

    }
    
 }