@isTest

private class AccontTrigger_Test {

    
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

    private static list<Account> setUpAccountsWRecordTypes() {
        List<Account> accountList = new List<Account>();
        Map<ID, RecordType> rtMap = new Map<ID, RecordType>([Select Id, DeveloperName, SObjectType from RecordType Where SObjectType = 'Account']);
        for (Integer i = 0; i < 200; i++) {
            if(i<100){
                accountList.add(new Account(Name=ACCOUNT_PREFIX+i, RecordTypeId=rtMap.get('012610000002gtz').Id));  //Seller Account RecordType            
            } else{
                accountList.add(new Account(Name=ACCOUNT_PREFIX+i, RecordTypeId=rtMap.get('012610000002gtu').Id));  //Supplier Account RecordType
            }
        }
        accountList.add(new Account(Name='ACCOUNT_PREFIX 1', Partner_Space__c='Marketplace', RecordTypeId=rtMap.get('012610000002hXk').Id));
        insert accountList;
        String whereClause = '%'+ACCOUNT_PREFIX+'%';
        accountList = [SELECT Id FROM Account WHERE Name LIKE :whereClause];
        return accountList;
    }


    private static testMethod void testbeforeUpdate(){
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
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Onboarding Queue';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Ready to Onboard';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Pre Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
       /* for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        accountList[0].Seller_Onboarding_Status__c = 'Item Setup';
        accountList[1].Seller_Onboarding_Status__c = 'Transaction Readiness';
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
                
        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Live on Site';
            anAccount.Seller_Onboarding_Live_Status__c = 'Ops Ready';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;*/

   }
   
     private static testMethod void testbeforeUpdate5(){
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
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

       /* for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Onboarding Queue';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Ready to Onboard';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Pre Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;*/
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        accountList[0].Seller_Onboarding_Status__c = 'Item Setup';
        accountList[1].Seller_Onboarding_Status__c = 'Transaction Readiness';
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
                
        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Live on Site';
            anAccount.Seller_Onboarding_Live_Status__c = 'Ops Ready';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

   }
   
    private static testMethod void testbeforeUpdate2(){
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
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Onboarding Queue';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Ready to Onboard';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Pre Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        /*for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Item Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Transaction Readiness';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;*/
        accountList[0].Seller_Onboarding_Status__c = 'Item Setup';
        accountList[1].Seller_Onboarding_Status__c = 'Transaction Readiness';
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Abandoned';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        test.starttest();
        
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Launch Readiness';
            anAccount.per_of_assortment_manufacturedby_company__c = 10;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        /*for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Closed';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;*/
        
        
        
        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Closed';
            anAccount.Integration_Engineer__c = users[1].Id;
            anAccount.Seller_Liaison__c = users[11].Id;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
            anAccount.Integration_Engineer__c = users[2].Id;
            anAccount.Seller_Liaison__c = users[12].Id;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        /*
        for(Account anAccount :accountList){
            anAccount.Integration_Engineer__c = users[2].Id;
            anAccount.Seller_Liaison__c = users[12].Id;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        */
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'On hold';
            anAccount.On_hold_Reason__c='Seller Request';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        test.stoptest();
   }
   
   
    private static testMethod void testbeforeUpdate3(){
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
            e.Integration_Channel__c = 'Partner';
            e.Maximum__c = 50;
            e.No_of_Accounts_working_on__c= 0;
            e.User__c = users[i].id;
            e.User_Type__c = 'Integration Engineer';
            em.add(e);
        }
        for (Integer i =11; i< 16;i++){
            Engineer_Mapping__c  e1= new Engineer_Mapping__c();
            e1.Active__c = True;
            e1.Integration_Channel__c = 'Partner';
            e1.Maximum__c = 50;
            e1.No_of_Accounts_working_on__c= 0;
            e1.User__c = users[i].id;
            e1.User_Type__c = 'Seller Liasion';
            em.add(e1);
        }
        insert em;
            
        Account channelPartner = new Account();
        channelPartner.Name = 'Test';  
        channelPartner.Type = 'Channel Partner';
        //channelPartner.Sub_Type__c = 'Specialty Service';
        insert channelPartner;
         
         test.starttest();
            
        for(Account anAccount : accountList){
                anAccount.type='Seller';
                anAccount.Integration_Channel__c='Partner';
                anAccount.Integration_Method__c='Test';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        //
        for(Account anAccount : accountList){
                anAccount.type='Seller';
                anAccount.Integration_Channel__c='Partner';
                anAccount.Partner_Space__c='Marketplace';
                anAccount.RecordTypeId = '012610000002hXk';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        for(Account anAccount : accountList){
                anAccount.type='Seller';
                anAccount.Integration_Channel__c='Partner';
                anAccount.RecordTypeId = '012610000002gtu';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        //
        
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Onboarding Queue';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Ready to Onboard';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Pre Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        
   }
     private static testMethod void testbeforeUpdate4(){
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
            e.Integration_Channel__c = 'Partner';
            e.Maximum__c = 50;
            e.No_of_Accounts_working_on__c= 0;
            e.User__c = users[i].id;
            e.User_Type__c = 'Integration Engineer';
            em.add(e);
        }
        for (Integer i =11; i< 16;i++){
            Engineer_Mapping__c  e1= new Engineer_Mapping__c();
            e1.Active__c = True;
            e1.Integration_Channel__c = 'Partner';
            e1.Maximum__c = 50;
            e1.No_of_Accounts_working_on__c= 0;
            e1.User__c = users[i].id;
            e1.User_Type__c = 'Seller Liasion';
            em.add(e1);
        }
        insert em;
            
        Account channelPartner = new Account();
        channelPartner.Name = 'Test';  
        channelPartner.Type = 'Channel Partner';
        //channelPartner.Sub_Type__c = 'Specialty Service';
        insert channelPartner;
         
         test.starttest();
            
        for(Account anAccount : accountList){
                anAccount.type='Seller';
                anAccount.Integration_Channel__c='Partner';
                anAccount.Integration_Method__c='Test';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

         for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        /*for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Item Setup';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Transaction Readiness';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;*/
        accountList[0].Seller_Onboarding_Status__c = 'Item Setup';
        accountList[1].Seller_Onboarding_Status__c = 'Transaction Readiness';
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Abandoned';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Launch Readiness';
            anAccount.per_of_assortment_manufacturedby_company__c = 10;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        /*for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'Closed';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;*/

        
        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Closed';
            anAccount.Integration_Engineer__c = users[1].Id;
            anAccount.Seller_Liaison__c = users[11].Id;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;

        for(Account anAccount :accountList){
            anAccount.Seller_Onboarding_Status__c = 'Seller Setup';
            anAccount.Integration_Engineer__c = users[2].Id;
            anAccount.Seller_Liaison__c = users[12].Id;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
        test.stoptest();
        
        /*
        for(Account anAccount :accountList){
            anAccount.Integration_Engineer__c = users[2].Id;
            anAccount.Seller_Liaison__c = users[12].Id;
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        */
        for(Account anAccount : accountList){
            anAccount.Seller_Onboarding_Status__c = 'On hold';
            anAccount.On_hold_Reason__c='Seller Request';
        }
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList;
        
   }

    private static testMethod void testafterUpdate3(){

        List<Account> accountList = setUpAccounts();
        system.debug('accountList:'+accountList);
        List<Opportunity> oppList = new List<Opportunity>();

        Default_Cat_Manager__c defManager = new Default_Cat_Manager__c();
        defManager.Active__c =True;
        defManager.User_Id__c='005Q000000OpcX8';
        defManager.UserName__c='Ashok';
        defManager.Name = 'CM1';

        insert defManager;
        
        List<account> acc1 = new List<account>();
        for(account  a :accountList){
            a.Seller_Onboarding_Status__c = 'Closed';
            acc1.add(a);
        }
        
        Integer i = 0;
        //for (Account anAccount : accountList) {
        for (Account anAccount : acc1) {
            oppList.add(new Opportunity(
                Name=OPP_PREFIX+i,
                AccountId=anAccount.Id,
                CloseDate=Date.today(),
                StageName='Opportunity'
                ));
            i++;
        }
        
        insert oppList;
        
        
        Test.startTest();
        
       // List<Category__c> c = new List<Category__c>();

        List<String> s = new List<String>();
        s.add('Baby');
        s.add('All Others');       
        s.add('Apparel & Accessories');
        s.add('Automotive and Power Sports');
        s.add('Beauty');
        s.add('Camera & Photo');       
        s.add('Test123');
        s.add('Computer Hardware');
        s.add('Consumer Electronics');
        s.add('Electronics Accessories');       
        s.add('Grocery');
        s.add('Health & Personal Care');
        s.add('Home');
        s.add('Industrial & Scientific');       
        s.add('Jewelry');
        s.add('Large Appliance');
 

        List<Category__c> cList = new List<Category__c>();
            for(i=0;i<15;i++){
                cList.add(new Category__c(Active__c = true,Customer_Rating_Acceptable_Threshold__c= 87,Drop_Ship_Acceptable_Threshold__c= 13,Name=s[i]));

            }

        insert cList;
        
        List<ApplicationCategories__c> applcat=new List<ApplicationCategories__c>();
        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[0].id, Category__c = cList[0].id,Percentage_of_Annual_Sales__c=55));
        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[0].id, Category__c = cList[1].id,Percentage_of_Annual_Sales__c=45));

        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[1].id, Category__c = cList[0].id,Percentage_of_Annual_Sales__c=50));
        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[1].id, Category__c = cList[1].id,Percentage_of_Annual_Sales__c=50));   

        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[2].id, Category__c = cList[0].id,Percentage_of_Annual_Sales__c=30));
        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[2].id, Category__c = cList[1].id,Percentage_of_Annual_Sales__c=30)); 
        applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[2].id, Category__c = cList[2].id,Percentage_of_Annual_Sales__c=40));


      //  applcat.add(new ApplicationCategories__c( Opportunity__c = oppList[3].id, Category__c = cList[3].id,Percentage_of_Annual_Sales__c=100));

        insert applcat;
        
        
        

       
        
       List <Category_Mapping__c> caList = new List<Category_Mapping__c>();
        Category_Mapping__c ca = new Category_Mapping__c();
        ca.Category_Name__c='Baby';
        //user u = [SELECT Id, Name From User WHERE Id =:UserInfo.getUserId()];
        ca.Category_Owner__c= UserInfo.getUserId();
        caList.add(ca);
        
        Category_Mapping__c ca1 = new Category_Mapping__c();
        ca1.Category_Name__c='All Others';
        //user u = [SELECT Id, Name From User WHERE Id =:UserInfo.getUserId()];
        ca1.Category_Owner__c= UserInfo.getUserId();
        caList.add(ca1);
        
        Category_Mapping__c ca2 = new Category_Mapping__c();
        ca2.Category_Name__c='Apparel & Accessories';
        
        ca2.Category_Owner__c= UserInfo.getUserId();
        caList.add(ca2);
        
        Insert caList;    

        Account channelPartner = new Account();
        channelPartner.Name = 'Test';  
        channelPartner.Type = 'Channel Partner';
        //channelPartner.Sub_Type__c = 'Specialty Service';
        insert channelPartner;

        Partner_Join__c pj = new Partner_Join__c();
        pj.Seller__c = accountList[0].id;
        pj.Channel_Partner__c = channelPartner.id;

       // insert pj;
                                
                                List<Opportunity> opp1 = new List<Opportunity>();
        for(Opportunity opp: oppList){

            opp.StageName='Initiated';
            opp1.add(opp);
        }
         
        
        update opp1;
                                
        accountList[0].Seller_Onboarding_Status__c = 'Closed';
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update accountList[0];
        
        
        system.debug('Ashok Test:'+acc1[0].Seller_Onboarding_Status__c);
        TriggerMultipleExecutionPreventer.self.removeAllTriggerExecutionStarted();
        update acc1;

         
        Test.stopTest();

    }

    /*  
    Scenario: Create 201 accounts with specific record types.  Insert them.
    Result: The created accounts should have the appropriate value loaded in the KB_Category_Visibility__c field.
    */
    @isTest
    private static void beforeInsert(){
        setUpAccountsWRecordTypes();
        List<Account> resultList = [SELECT id, name, KB_Category_Visibility__c FROM Account];
        System.assertEquals(201, resultList.size());
        for(Account acctRow : resultList){
            if (acctRow.Name == 'ACCT-0') {
                System.assertEquals('Seller', acctRow.KB_Category_Visibility__c);
            }
            if (acctRow.Name == 'ACCT-100'){
                System.assertEquals('Supplier', acctRow.KB_Category_Visibility__c);
            }
            if (acctRow.Name == 'ACCT-200'){
                System.assertEquals('Seller', acctRow.KB_Category_Visibility__c);
            }
        }
    }
    
}