@isTest
public class WalmartMissingContactsCntrlTest{

    public static testMethod void unitTest(){
        
        // creating account record ...
        Account acc = new Account(Name='Tes Acc', 
                                  Type='Seller',
                                  Customer_Service_Email__c='test@test.com',
                                  Seller_Onboarding_Status__c = 'Live on Site',
                                  Seller_Onboarding_Live_Status__c = 'Launched',
                                  Platform__c = 'GMP',
                                  RecordTypeId = [select id from RecordType where DeveloperName = 'MP_Account' limit 1].Id);
        insert acc;
        
        Contact con = new Contact(LastName='Test Con',AccountId=acc.Id);
        insert con;
        
        // creating custom setting record ...
        Contact_Types__c ct = new Contact_Types__c(Name='Test');
        insert ct;
    
        WalmartMissingContactsCntrl obj = new WalmartMissingContactsCntrl();
        obj.selAccId = acc.Id;
        obj.SendAction();
        obj.next();
        obj.prev();
        obj.callStartWith();
        
        for(list<WalmartMissingContactsCntrl.AccountModal> accModList : obj.accModListofList){
            for(WalmartMissingContactsCntrl.AccountModal a : accModList){
                a.isChecked = true;
            }
        }
        
        obj.SendAllAction();
    }
}