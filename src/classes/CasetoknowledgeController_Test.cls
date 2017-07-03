@isTest(seealldata=true)
private class CasetoknowledgeController_Test {

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
    
    List<Case_Initiation__c> cintlist = new List<Case_Initiation__c>();
    
    for(integer i =1;i<10;i++){
        Case_Initiation__c ca = new Case_Initiation__c();
        ca.Account__c= acc.id;
        ca.Case__c= caseList[1].id;
        ca.Case_Type__c= 'Operations';
        ca.Deflected__c = false;

        cintlist.add(ca);
        }

        for(integer i =11;i<20;i++){
        Case_Initiation__c ca1 = new Case_Initiation__c();
        ca1.Account__c= acc.id;
      
        ca1.Case_Type__c= 'Operations';
        ca1.Deflected__c = true;

        cintlist.add(ca1);
        }

      insert cintlist;

     CasetoknowledgeController pcCaseController = new CasetoknowledgeController();
     String str = 'Test';
     Integer int1 =10;
     String str1 = 'Test1';
     Integer int2 =15;
     CasetoknowledgeController.CutsomPieWidget  pData = new CasetoknowledgeController.CutsomPieWidget(str,int1,int2,str1);
     pcCaseController.sDate = Date.today() -10;
     pcCaseController.eDate = Date.today()+10;
     //pcCaseController.Percantage_Non_Deflected = 50.00;
     pcCaseController.count_Non_Deflected = 100.00;
     //pcCaseController.Percantage_Deflected = 50.00;
     pcCaseController.count_Deflected= 12;
     pcCaseController.count_All_Cases= 11;

     pcCaseController.dummyfunction();
     pcCaseController.getPieData();
    

     
      pcCaseController.PopulateChartData();

    }
    
 }