@isTest

private class IntegrationLookupController_Test {

    static testMethod void test() {
    RecordType rt = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Partner_Account'];
    List<IntegrationMethodDirectMapping__c> imdlst = new List<IntegrationMethodDirectMapping__c>();
    IntegrationMethodDirectMapping__c imd = new IntegrationMethodDirectMapping__c();
    imd.IsActive__c = True;
    imd.Name ='IM1';
    imd.MethodName__c = 'API';
    imdlst.add(imd);
    IntegrationMethodDirectMapping__c imd2 = new IntegrationMethodDirectMapping__c();
    imd2.IsActive__c = True;
    imd2.Name ='IM2';
    imd2.MethodName__c = 'Bulk';
    imdlst.add(imd2);

    insert imdlst;


    Account acc = new Account();

        acc.Name = 'TestAcc';
        acc.RecordTypeid = rt.id;
        acc.Partner_Type__c = 'Full Service Partner';
        acc.Partner_Onboarding_Status__c = 'Live';
        insert acc;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc.id;
        insert con;

        Opportunity oppo = new Opportunity();
        oppo.Name ='TestOppo';
        oppo.Accountid= acc.id;
        oppo.Primary_Contact__c = con.id;
        oppo.CloseDate = date.today();
        oppo.StageName = 'Opportunity';
        insert oppo;

        Application__c app = new Application__c();
        app.Account__c = acc.id;
        app.Opportunity__c = oppo.id;
        app.Primary_Contact_First_Name__c = 'Test1';
        app.Primary_Contact_Last_Name__c = 'Test2';
        app.Primary_Contact_Email__c ='asd@gmail.com';
        app.Legal_Company_Name__c = 'testing';
        insert app;

        test.startTest();

        PageReference pageRef = Page.IntegrationLookup;
        RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='MP_Account'];
        Account acc1 = new Account();
        acc1.Integration_Channel__c ='Direct';
        acc1.Integration_Method__c ='API';
        acc1.Name = 'TestAcc1';
        acc1.RecordTypeid = rt1.id;
        insert acc1;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',acc1.id);
        pageRef.getParameters().put('type','account');

        ApexPages.StandardController sc = new ApexPages.standardController(acc1);


       // IntegrationLookupController ilc = new IntegrationLookupController(sc);

        IntegrationLookupController ilc = new IntegrationLookupController();
        //String str = 'Test';
        //String sId = 'X1235Test';
       // IntegrationLookupController.IntegrationMethodWrapper imw = new  IntegrationLookupController.IntegrationMethodWrapper(acc.id,acc.Name);
        //IntegrationLookupController.IntegrationMethodWrapper imw1 = new  IntegrationLookupController.IntegrationMethodWrapper();
        //IntegrationLookupController.IntegrationMethodWrapper imw2 = new  IntegrationLookupController.IntegrationMethodWrapper();
        ilc.sSelectedIntegrationChannel  ='Direct';
        ilc.sSelectedIntegrationMethod   ='API';
        //ilc.sSelectedIntegrationMethodId ='123ASDEr';
        //ilc.sRecordID= acc.id;
        //ilc.sType = 'account';
        //ilc.lstIntegrationMethodList.add(imw);
        //ilc.lstIntegrationChannel.add(new SelectOption('','--None--'));
       // ilc.fetchAccountData();
        //ilc.fetchOpportunityData();
        //ilc.fetchApplicationData();
        //ilc.UpdateAccount();
        //ilc.UpdateOpportunity();
       // ilc.
       // ilc.FetchIntegrationMethods();
        ilc.selectIntegrationMethod();
        pageRef.getParameters().put('id',oppo.id);
        pageRef.getParameters().put('type','Opportunity');
        test.stopTest();
    }

    static testMethod void test2() {
    RecordType rt = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Partner_Account'];
    List<IntegrationMethodDirectMapping__c> imdlst = new List<IntegrationMethodDirectMapping__c>();
    IntegrationMethodDirectMapping__c imd = new IntegrationMethodDirectMapping__c();
    imd.IsActive__c = True;
    imd.Name ='IM1';
    imd.MethodName__c = 'API';
    imdlst.add(imd);
    IntegrationMethodDirectMapping__c imd2 = new IntegrationMethodDirectMapping__c();
    imd2.IsActive__c = True;
    imd2.Name ='IM2';
    imd2.MethodName__c = 'Bulk';
    imdlst.add(imd2);

    insert imdlst;


    Account acc = new Account();

        acc.Name = 'TestAcc';
        acc.RecordTypeid = rt.id;
        acc.Partner_Type__c = 'Full Service Partner';
        acc.Partner_Onboarding_Status__c = 'Live';
        insert acc;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc.id;
        insert con;

        Opportunity oppo = new Opportunity();
        oppo.Name ='TestOppo';
        oppo.Accountid= acc.id;
        oppo.Primary_Contact__c = con.id;
        oppo.CloseDate = date.today();
        oppo.StageName = 'Opportunity';
        insert oppo;

        Application__c app = new Application__c();
        app.Account__c = acc.id;
        app.Opportunity__c = oppo.id;
        app.Primary_Contact_First_Name__c = 'Test1';
        app.Primary_Contact_Last_Name__c = 'Test2';
        app.Primary_Contact_Email__c ='asd@gmail.com';
        app.Legal_Company_Name__c = 'testing';
        insert app;

        test.startTest();

        PageReference pageRef = Page.IntegrationLookup;
        RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='MP_Account'];
        Account acc1 = new Account();
        acc1.Name = 'TestAcc1';
        acc1.RecordTypeid = rt1.id;
        insert acc1;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',oppo.id);
        pageRef.getParameters().put('type','Opportunity');

        ApexPages.StandardController sc = new ApexPages.standardController(oppo);


       // IntegrationLookupController ilc = new IntegrationLookupController(sc);

        IntegrationLookupController ilc = new IntegrationLookupController();
        
        ilc.sSelectedIntegrationChannel  ='Direct';
        ilc.sSelectedIntegrationMethod   ='API';
        
        ilc.selectIntegrationMethod();

    }

    static testMethod void test3() {
    RecordType rt = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Partner_Account'];
    List<IntegrationMethodDirectMapping__c> imdlst = new List<IntegrationMethodDirectMapping__c>();
    IntegrationMethodDirectMapping__c imd = new IntegrationMethodDirectMapping__c();
    imd.IsActive__c = True;
    imd.Name ='IM1';
    imd.MethodName__c = 'API';
    imdlst.add(imd);
    IntegrationMethodDirectMapping__c imd2 = new IntegrationMethodDirectMapping__c();
    imd2.IsActive__c = True;
    imd2.Name ='IM2';
    imd2.MethodName__c = 'Bulk';
    imdlst.add(imd2);

    insert imdlst;


    Account acc = new Account();

        acc.Name = 'TestAcc';
        acc.RecordTypeid = rt.id;
        acc.Partner_Type__c = 'Full Service Partner';
        acc.Partner_Onboarding_Status__c = 'Live';
        insert acc;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc.id;
        insert con;

        Opportunity oppo = new Opportunity();
        oppo.Name ='TestOppo';
        oppo.Accountid= acc.id;
        oppo.Primary_Contact__c = con.id;
        oppo.CloseDate = date.today();
        oppo.StageName = 'Opportunity';
        insert oppo;

        Application__c app = new Application__c();
        app.Account__c = acc.id;
        app.Opportunity__c = oppo.id;
        app.Primary_Contact_First_Name__c = 'Test1';
        app.Primary_Contact_Last_Name__c = 'Test2';
        app.Primary_Contact_Email__c ='asd@gmail.com';
        app.Legal_Company_Name__c = 'testing';
        insert app;

        test.startTest();

        PageReference pageRef = Page.IntegrationLookup;
        RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='MP_Account'];
        Account acc1 = new Account();
        acc1.Name = 'TestAcc1';
        acc1.RecordTypeid = rt1.id;
        insert acc1;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',app.id);
        pageRef.getParameters().put('type','application');

        ApexPages.StandardController sc = new ApexPages.standardController(app);


       // IntegrationLookupController ilc = new IntegrationLookupController(sc);

        IntegrationLookupController ilc = new IntegrationLookupController();
        
        ilc.sSelectedIntegrationChannel  ='Direct';
        ilc.sSelectedIntegrationMethod   ='API';
        
        ilc.selectIntegrationMethod();

    }

        
 }