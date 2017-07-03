@isTest
Private class SelectSpecialitypartnerController_Test{
    Static testmethod void test(){
    				RecordType rt = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Partner_Account'];

								list<Account> lstAccount = new list<Account>();
    				Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.RecordTypeid = rt.id;
        acc.Partner_Type__c = 'Specialty Partner';
        acc.Partner_Onboarding_Status__c = 'Live';
        //insert acc;
        lstAccount.add(acc);
        
        Account acc2 = new Account();
        acc2.Name = 'TestAcc2';
        acc2.RecordTypeid = rt.id;
        acc2.Partner_Type__c = 'Specialty Partner';
        acc2.Partner_Onboarding_Status__c = 'Live';
        //insert acc;
        lstAccount.add(acc2);
        
        insert lstAccount;
        
        test.startTest();

        PageReference pageRef = Page.SelectSpecialitypartner;
        RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='MP_Account'];
        Account acc1 = new Account();
        //acc1.Integration_Channel__c ='Direct';
        //acc1.Integration_Method__c ='API';
        acc1.Name = 'TestAcc1';
        acc1.RecordTypeid = rt1.id;
        acc1.Specialitypartner__c = acc2.Name;
    				acc1.SpecialitypartnerIds__c = acc2.Id;
        insert acc1;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc1.id;
        insert con;

        Opportunity oppo = new Opportunity();
        oppo.Name ='TestOppo';
        oppo.Accountid= acc1.id;
        oppo.Primary_Contact__c = con.id;
        oppo.CloseDate = date.today();
        oppo.StageName = 'Opportunity';
        insert oppo;

        Application__c app = new Application__c();
        app.Account__c = acc1.id;
        app.Opportunity__c = oppo.id;
        app.Primary_Contact_First_Name__c = 'Test1';
        app.Primary_Contact_Last_Name__c = 'Test2';
        app.Primary_Contact_Email__c ='asd@gmail.com';
        app.Legal_Company_Name__c = 'testing';
        insert app;
        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',acc1.id);
        pageRef.getParameters().put('type','account');

        ApexPages.StandardController sc = new ApexPages.standardController(acc1);
       
        SelectSpecialitypartnerController spc = new SelectSpecialitypartnerController();
        //String str = 'Test';
        //String str1 = 'Test1';
        //SelectSpecialitypartnerController.SpecialitypartnerWrapper spw = new SelectSpecialitypartnerController.SpecialitypartnerWrapper(str,str1);
        spc.sSelectedSpecialitypartner = acc.Name+',';
        spc.sSelectedSpecialitypartnerIds = acc.Id;
        spc.save();
        test.stopTest();
    }

    Static testmethod void test2(){
    				RecordType rt = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Partner_Account'];

    				list<Account> lstAccount = new list<Account>();
    				Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.RecordTypeid = rt.id;
        acc.Partner_Type__c = 'Specialty Partner';
        acc.Partner_Onboarding_Status__c = 'Live';
        //insert acc;
        lstAccount.add(acc);
        
        Account acc2 = new Account();
        acc2.Name = 'TestAcc2';
        acc2.RecordTypeid = rt.id;
        acc2.Partner_Type__c = 'Specialty Partner';
        acc2.Partner_Onboarding_Status__c = 'Live';
        //insert acc;
        lstAccount.add(acc2);
        
        insert lstAccount;

        test.startTest();

        PageReference pageRef = Page.SelectSpecialitypartner;
        RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='MP_Account'];
        Account acc1 = new Account();
        //acc1.Integration_Channel__c ='Direct';
        //acc1.Integration_Method__c ='API';
        acc1.Name = 'TestAcc1';
        acc1.RecordTypeid = rt1.id;
        insert acc1;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc1.id;
        insert con;

        Opportunity oppo = new Opportunity();
        oppo.Name ='TestOppo';
        oppo.Accountid= acc1.id;
        oppo.Primary_Contact__c = con.id;
        oppo.CloseDate = date.today();
        oppo.StageName = 'Opportunity';
        oppo.Specialitypartner__c = acc2.Name;
    				oppo.SpecialitypartnerIds__c = acc2.Id;
        insert oppo;

        Application__c app = new Application__c();
        app.Account__c = acc1.id;
        app.Opportunity__c = oppo.id;
        app.Primary_Contact_First_Name__c = 'Test1';
        app.Primary_Contact_Last_Name__c = 'Test2';
        app.Primary_Contact_Email__c ='asd@gmail.com';
        app.Legal_Company_Name__c = 'testing';
        insert app;
        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',oppo.id);
        pageRef.getParameters().put('type','Opportunity');

        ApexPages.StandardController sc = new ApexPages.standardController(oppo);

       
        SelectSpecialitypartnerController spc = new SelectSpecialitypartnerController();
        //String str = 'Test';
        //String str1 = 'Test1';
        //SelectSpecialitypartnerController.SpecialitypartnerWrapper spw = new SelectSpecialitypartnerController.SpecialitypartnerWrapper(str,str1);
        spc.sSelectedSpecialitypartner = acc.Name +',';
        spc.sSelectedSpecialitypartnerIds = acc.Id;
        spc.save();
        test.stopTest();
    }

    Static testmethod void test3(){
    				RecordType rt = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='Partner_Account'];

    				list<Account> lstAccount = new list<Account>();
    				Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.RecordTypeid = rt.id;
        acc.Partner_Type__c = 'Specialty Partner';
        acc.Partner_Onboarding_Status__c = 'Live';
        //insert acc;
        lstAccount.add(acc);
        
        Account acc2 = new Account();
        acc2.Name = 'TestAcc2';
        acc2.RecordTypeid = rt.id;
        acc2.Partner_Type__c = 'Specialty Partner';
        acc2.Partner_Onboarding_Status__c = 'Live';
        //insert acc;
        lstAccount.add(acc2);
        
        insert lstAccount;

        test.startTest();

        PageReference pageRef = Page.SelectSpecialitypartner;
        RecordType rt1 = [Select id,developerName from RecordType where sObjectType='Account' And developerName ='MP_Account'];
        Account acc1 = new Account();
        //acc1.Integration_Channel__c ='Direct';
        //acc1.Integration_Method__c ='API';
        acc1.Name = 'TestAcc1';
        acc1.RecordTypeid = rt1.id;
        insert acc1;
        
        Contact con = new Contact();
        con.lastname = 'Test name';
        con.Accountid= acc1.id;
        insert con;

        Opportunity oppo = new Opportunity();
        oppo.Name ='TestOppo';
        oppo.Accountid= acc1.id;
        oppo.Primary_Contact__c = con.id;
        oppo.CloseDate = date.today();
        oppo.StageName = 'Opportunity';
        insert oppo;

        Application__c app = new Application__c();
        app.Account__c = acc1.id;
        app.Opportunity__c = oppo.id;
        app.Primary_Contact_First_Name__c = 'Test1';
        app.Primary_Contact_Last_Name__c = 'Test2';
        app.Primary_Contact_Email__c ='asd@gmail.com';
        app.Legal_Company_Name__c = 'testing';
        app.Specialitypartner__c = acc2.Name;
    				app.SpecialitypartnerIds__c = acc2.Id;
        insert app;
        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',app.id);
        pageRef.getParameters().put('type','Application');

        ApexPages.StandardController sc = new ApexPages.standardController(app);


        SelectSpecialitypartnerController spc = new SelectSpecialitypartnerController();
        //String str = 'Test';
        //String str1 = 'Test1';
        //SelectSpecialitypartnerController.SpecialitypartnerWrapper spw = new SelectSpecialitypartnerController.SpecialitypartnerWrapper(str,str1);
        spc.sSelectedSpecialitypartner = acc.Name +',';
        spc.sSelectedSpecialitypartnerIds = acc.Id;
        spc.save();
        test.stopTest();
    }


}