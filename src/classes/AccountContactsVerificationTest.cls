@isTest
public class AccountContactsVerificationTest{

    public static testMethod void unitTest(){
        
         // creating account record ...
        recordtype rec = [select id from recordtype where developername='MP_Account']; 
        Account acc = new Account(Name='Tes Acc', Type='Seller',Customer_Service_Email__c='test@test.com',RecordtypeID=rec.ID);
        insert acc;
         Contact con = new Contact(LastName='Test Con', AccountId=acc.Id, Contact_Type__c = 'Test');
        insert con;
         Contact_Types__c ct = new Contact_Types__c(Name='Test');
        insert ct;
     ApexPages.currentPage().getParameters().put('ac', acc.Id);
         AccountContactsVerification obj = new AccountContactsVerification();
        
        
    }
}