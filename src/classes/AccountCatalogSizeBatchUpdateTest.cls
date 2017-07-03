@isTest(seeAllData=false)
public class AccountCatalogSizeBatchUpdateTest {
static testMethod void AccountCatalogSizeBatchUpdate(){ 
        
        Test.StartTest();
        
        date mydate = date.parse('12/27/2009');
        Id mPAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MP Account').getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(integer i = 0;i<5;i++){
            Account tempAcc = new Account(Name = 'TestfName'+i,Active__c = true,RecordTypeID = mPAccountRecordTypeId);
            accList.add(tempAcc);
        }
        
        insert accList;
        
        
        Opportunity tempOpp = new Opportunity(Name ='TestOppo',StageName = 'Closed Won',AccountId = accList[0].Id,CloseDate= mydate);
        insert tempOpp;
        
        
        Application__c tempApp = new Application__c(Legal_Company_Name__c='Accenture',Primary_Contact_First_Name__c = 'XYZ',Primary_Contact_Last_Name__c='PQR',Primary_Contact_Email__c='neha@gmail.com',Account__c=accList[0].Id,Opportunity__c=tempOpp.Id);
       insert tempApp;
       
       ApplicationCategories__c tempAppCat = new ApplicationCategories__c(Application__c=tempApp.Id,Opportunity__c=tempOpp.Id,No_of_SKU_s_to_be_sold_at_Walmart__c=6);
       insert tempAppCat;
       
        
        Opportunity tempOpp1 = new Opportunity(Name ='TestOppo',StageName = 'Closed Won',AccountId = accList[1].Id,CloseDate= mydate);
        insert tempOpp1;
        
        Opportunity tempOpp2 = new Opportunity(Name ='TestOppo',StageName = 'Closed Won',AccountId = accList[2].Id,CloseDate= mydate);
        insert tempOpp2;
        
        Application__c tempApp1 = new Application__c(Legal_Company_Name__c='Accenture',Primary_Contact_First_Name__c = 'XYZ',Primary_Contact_Last_Name__c='PQR',Primary_Contact_Email__c='neha@gmail.com',Account__c=accList[2].Id,Opportunity__c=tempOpp2.Id);
       insert tempApp1;
       
       ApplicationCategories__c tempAppCat1 = new ApplicationCategories__c(Application__c=tempApp1.Id,Opportunity__c=tempOpp2.Id,No_of_SKU_s_to_be_sold_at_Walmart__c=0);
       insert tempAppCat1;
       
        
        Opportunity tempOpp3 = new Opportunity(Name ='TestOppo',StageName = 'Closed Won',AccountId = accList[3].Id,CloseDate= mydate);
        insert tempOpp3 ;
        
        Application__c tempApp2 = new Application__c(Legal_Company_Name__c='Accenture',Primary_Contact_First_Name__c = 'XYZ',Primary_Contact_Last_Name__c='PQR',Primary_Contact_Email__c='neha@gmail.com',Account__c=accList[3].Id,Opportunity__c=tempOpp3.Id);
       insert tempApp2;
        
        AccountCatalogSizeBatchUpdate per1 = new AccountCatalogSizeBatchUpdate ();      
        Database.QueryLocator ql = per1 .start(null);
        per1.execute(null,accList);   
        per1.Finish(null);
        
        /*
        AccountCatalogSizeBatchUpdateScheduler sh1 = new AccountCatalogSizeBatchUpdateScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, sh1);
        */
        Test.StopTest();
        }
}