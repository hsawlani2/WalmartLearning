/**
 * @description Test class for CaseController class
 * @author Josephine Del Mundo
 * @date 09.FEB.2016
 * 
 * THIS CLASS IS NO MORE REQUIRED. THIS IS NOW ADDRESSED WITH
 * TestCaseNeedInfoController
 */    
@isTest
private class TestCaseController{ 
	
    /*private static Account acct;
    private static Contact sellerContact;
    private static Case caseRec;
    private static Case caseRecTrigger;*/
   
   
   /**
    * @description method to test on page load 
    *               when case record status is Need Info 
    *               and Infor received is true
    * @author Josephine Del Mundo
    * @date 09.FEB.2016
    */
    /*private static testMethod void testControllerMethod() {
        acct = new Account(Name = 'test Acc',
                           BillingStreet = 'test street',
                           BillingCity = 'test city',
                           BillingState = 'Alabama',
                           BillingCountry = 'United States',
                           ShippingCountry = 'United States',
                           BillingPostalCode = '012345',
                           Website = 'www.test.com');
        insert acct;
        
        sellerContact = new Contact( FirstName = 'seller',
                            LastName = 'contact',
                            Title = 'Tester',
                            Phone = '12345678',
                            Email = 'testcontact@test.com',
                            MailingCountry = 'United States',
                            AccountId = acct.id); 
        insert sellerContact;
        
        // Create case records
        caseRec = new Case(Status = 'WIP',
                           Subject = 'testCase', 
                           AccountId = acct.Id, ContactId = sellerContact.Id);
        insert caseRec; 

        
        Test.setCurrentPageReference(new PageReference('Page.caseNeedInfo')); 
        ApexPages.currentPage().getParameters().put('caseId', caseRec.Id);

        Test.startTest();
        CaseController controller = new CaseController();
        controller.sellerComments = 'Test Comments';
        controller.requestInfoFromSeller();
        controller.back();
        Test.StopTest();
    }

   /**
    * @description method to test on caseTrigger
    * @author Josephine Del Mundo
    * @date 09.FEB.2016
    */
    /*private static testMethod void testCaseTrigger(){
        caseRecTrigger = new Case(Status = 'WIP', Subject = 'testCase');
        insert caseRecTrigger; 
        
        caseRecTrigger.Status = 'Need Info';
        try {
            update caseRecTrigger;
        } catch (Exception e) {
            // ignore
        }
    }*/
}