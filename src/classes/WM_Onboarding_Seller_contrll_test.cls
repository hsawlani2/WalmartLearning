@isTest 
private class WM_Onboarding_Seller_contrll_test{
    static testMethod void submitmethod() {
       Account acc = new Account(name='test Account',Integration_Channel__c='Direct',Integration_Method__c='API');
       insert acc;
       recordtype rec = [Select id from recordtype where developername='Partner_Account'];
       //partner account
       Account partnacc = new Account(name='testpartner account',Partner_Type__c='Full Service Partner',Partner_Onboarding_Status__c = 'Live',recordtypeid=rec.id);
       insert partnacc;
       contact con = new contact(firstname='test',lastname='contact',accountid=acc.id,contact_type__c='Marketplace Business Manager',email='test@test.com',phone='99009900990');
       insert con;
       Application__c app = new application__c(account__c = acc.id,Legal_Company_Name__c = acc.name,Primary_Contact_Email__c= con.email,Primary_Contact_First_Name__c = con.firstname,Primary_Contact_Last_Name__c=con.lastname);
       insert app;
       ApexPages.currentPage().getParameters().put('Token',app.id);
       WM_Onboarding_Seller_contrll testcon = new WM_Onboarding_Seller_contrll();
       ApexPages.currentPage().getParameters().put('Startdate','2017-03-24');
       ApexPages.currentPage().getParameters().put('Intgrationmethod','Partner');
       ApexPages.currentPage().getParameters().put('Integrationspecific',partnacc.name);
       testcon.TotalSKU = '100';
       testcon.LaunchSKU = '10';
       testcon.submit11();
       testcon.con.firstname = 'test2';
       testcon.submitweek();
    }
}