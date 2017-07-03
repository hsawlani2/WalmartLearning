@isTest
public class UpdateEngineerMappingBatchTest{

      private static final String ACCOUNT_PREFIX = 'ACCT-';
      private static final String CONTACT_PREFIX = 'CONTACT-';
      private static final String OPP_PREFIX = 'OPP-';
      private static final Integer ARR_SIZE = 10;
     
      private static List<Account> setUpAccounts() {
        
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < ARR_SIZE; i++) {
            accountList.add(new Account(Name=ACCOUNT_PREFIX+i));
        }
        insert accountList;
        
        String whereClause = '%'+ACCOUNT_PREFIX+'%';
        accountList = [SELECT Id FROM Account WHERE Name LIKE :whereClause];
        
       
        
        return accountList;
        }

    static testMethod void unitTest(){

       
        List<Account>  accountList = setUpAccounts();

       List<User> users = new List<User>();
        for (Integer i = 0; i < 20; i++) {
          User u = new User();
          u.FirstName         = 'Elsa';
          u.LastName          = 'of Arendelle';
          u.Email             = 'elsa@test.com';
          u.Alias             = 'elsa' + i;
          u.Username          = 'elsa' + i + '@test.com';
          u.LocaleSidKey      = 'en_US';
          u.TimeZoneSidKey    = 'GMT';
          u.ProfileID         = '00e61000000Z6R7';
          u.LanguageLocaleKey = 'en_US';
          u.EmailEncodingKey  = 'UTF-8';
          users.add(u);
        }
        insert users;

        List<Engineer_Mapping__c> em = new List<Engineer_Mapping__c>();
        for (Integer i =0; i< 10;i++){
            Engineer_Mapping__c  e= new Engineer_Mapping__c();
            e.Active__c = True;
            e.Integration_Channel__c = 'Direct';
            e.Maximum__c = 50;
            e.No_of_Accounts_working_on__c= 0;
            e.User__c = users[i].id;
            e.User_Type__c = 'Integration Engineer';
            em.add(e);
        }
        for (Integer i =11; i< 16;i++){
            Engineer_Mapping__c  e1= new Engineer_Mapping__c();
            e1.Active__c = True;
            e1.Integration_Channel__c = 'Direct';
            e1.Maximum__c = 50;
            e1.No_of_Accounts_working_on__c= 0;
            e1.User__c = users[i].id;
            e1.User_Type__c = 'Seller Liasion';
            em.add(e1);
        }
        insert em;

        for(Account anAccount : accountList){
                anAccount.type='Seller';
                anAccount.Integration_Channel__c='Direct';
                anAccount.Seller_Onboarding_Status__c ='Seller Setup';
                anAccount.Integration_Engineer__c= users[0].id;
        }
        update accountList;
        /*string CRON_EXP = '0 0 0 15 3 ? 2022';
        System.schedule('UpdateEngineerMappingBatchSchedulable',
                         CRON_EXP, 
                         new UpdateEngineerMappingBatchSchedulable());*/
        Test.startTest();
        
        Id batchJobId = Database.executeBatch(new UpdateEngineerMappingBatch(), 10);
    
        Test.stopTest(); 
            
       } 
             
}