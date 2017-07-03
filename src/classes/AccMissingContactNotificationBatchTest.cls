@isTest
public class AccMissingContactNotificationBatchTest{

    public static testMethod void unitTest(){
        
        // creating account record ...
        String mprecordType='MP_Account';
        recordtype rec = [select Id from recordtype where DeveloperName=:mprecordType limit 1];
        Account acc = new Account(Name='Tes Acc', Type='Seller',Customer_Service_Email__c='test@test.com',recordtypeID= rec.ID);
        insert acc;
        
        Contact con = new Contact(LastName='Test Con', AccountId=acc.Id, Contact_Type__c = 'Test',Email='test@test1.com');
        insert con;
        
        // creating custom setting record ...
        Contact_Types__c ct = new Contact_Types__c(Name='Test');
        insert ct;
        
        ApexPages.currentPage().getParameters().put('ac', acc.Id);
        AccountContactsVerification obj = new AccountContactsVerification();
        
        obj.addNewContact();
        obj.saveContacts();
        
        Id batchJobId = Database.executeBatch(new AccountMissingContactNotificationBatch(), 10);
    }
}