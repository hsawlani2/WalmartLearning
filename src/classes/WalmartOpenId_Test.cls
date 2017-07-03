/**
 * AUTHOR       : Lennard Santos(Cloud Sherpas)
 * DESCRIPTION  : Test class for auth provider plugin
 * HISTORY      : 03.MAR.2014 - Created (LSantos)
 * */
@isTest
private class WalmartOpenId_Test {
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for setting up test data that will be used throughout the test coverage methods
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    @testSetup static void setupTestData(){
        Id adminProfId = [Select id from Profile WHERE Name=:'System Administrator'].Id;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User adminUser = walmartDataUtility.buildTestUser('walmartadmin@walmart.com.test', adminProfId);
        adminUser.UserRoleId = portalRole.Id;
        insert adminUser;
        
        System.runAs(adminUser){
            Walmart_Open_Id__c walmartSettings = new Walmart_Open_Id__c();
            walmartSettings.Link__c = 'https://phase3dev-walmartsupport.cs51.force.com/cases';
            walmartSettings.Auth_Provider__c = 'Walmart_OpenId__mdt';
            walmartSettings.SFDC_Network_Id__c = '0DB61000000PBLZ';
            walmartSettings.Profile_Name__c = 'Seller Community User';
            walmartSettings.Error_Page_Link__c   = 'http://sfdc.koduru.we.bs/error.php';
            walmartSettings.Name = 'WalmartOpenId';
            insert walmartSettings;

            Account testAccount = walmartDataUtility.buildTestAccount('Walmart Seller');
            insert testAccount;
            Contact testContact = walmartDataUtility.buildTestContact('walmart', 'SellerContact', testAccount.Id);
            insert testContact;
            Id commProfId = [Select id from Profile WHERE Name=:'Seller Community User'].Id;
            User communityUser = walmartDataUtility.buildTestUser('walmartSellerContact@walmart.com.test',commProfId);
            communityUser.ContactId = testContact.Id;
            insert communityUser;
        }
    }
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for testing sso initiation method
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    static testMethod void testInitiate() {
        String initiateURLBefore = '';
        String initiateURLAfter = '';
        Test.startTest();
        WalmartOpenId openId = new WalmartOpenId();
        System.assertEquals('Walmart_OpenId__mdt', openId.getCustomMetadataType());
        Map<String,String> authProviderConfig = new Map<String,String>();
        for(Walmart_OpenId__mdt wo : [SELECT AuthorizeEndpointURL__c,Callback_Url__c,CONSUMER_KEY__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName,Response_Type__c,TokenEndpointURL__c,WM_CONSUMER_ID__c,WM_CONSUMER_SECRET__c,WM_SEC_KEY_VERSION__c,WM_SVC_ENV__c,WM_SVC_NAME__c,WM_SVC_VERSION__c FROM Walmart_OpenId__mdt LIMIT 1]){
            authProviderConfig = new Map<String,String>();
            authProviderConfig.put('AuthorizeEndpointURL__c',wo.AuthorizeEndpointURL__c);
            authProviderConfig.put('Callback_Url__c',wo.Callback_Url__c);
            authProviderConfig.put('CONSUMER_KEY__c',wo.CONSUMER_KEY__c);
            authProviderConfig.put('DeveloperName',wo.DeveloperName);
            authProviderConfig.put('Id',wo.Id); 
            authProviderConfig.put('Label',wo.Label);
            authProviderConfig.put('Language',wo.Language);
            authProviderConfig.put('MasterLabel',wo.MasterLabel);
            authProviderConfig.put('NamespacePrefix',wo.NamespacePrefix);
            authProviderConfig.put('QualifiedApiName',wo.QualifiedApiName);
            authProviderConfig.put('Response_Type__c',wo.Response_Type__c);
            authProviderConfig.put('TokenEndpointURL__c',wo.TokenEndpointURL__c);
            authProviderConfig.put('WM_CONSUMER_ID__c',wo.WM_CONSUMER_ID__c);
            authProviderConfig.put('WM_CONSUMER_SECRET__c',wo.WM_CONSUMER_SECRET__c);
            authProviderConfig.put('WM_SEC_KEY_VERSION__c',wo.WM_SEC_KEY_VERSION__c);
            authProviderConfig.put('WM_SVC_ENV__c',wo.WM_SVC_ENV__c);
            authProviderConfig.put('WM_SVC_NAME__c',wo.WM_SVC_NAME__c);
            authProviderConfig.put('WM_SVC_VERSION__c',wo.WM_SVC_VERSION__c);
        }
        Test.setMock(HttpCalloutMock.class, new walmartOpenIdTokenMockSuccess());
        if(authProviderConfig.size()>0){
            //CALL BACK
            initiateURLBefore = ApexPages.currentPage().getUrl();
            Test.setCurrentPageReference(openId.initiate(authProviderConfig,EncodingUtil.base64Encode(Blob.valueOf('teststate'))));
            initiateURLAfter = ApexPages.currentPage().getUrl();
        }
        Test.stopTest();
        System.assertNotEquals(initiateURLBefore, initiateURLAfter);
    }
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for testing sso callback method
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     *                23.MAR.2016 - Updated to handle the call back
     **/
    static testMethod void testHandleCallBack(){
        Test.startTest();
        WalmartOpenId openId = new WalmartOpenId();
        System.assertEquals('Walmart_OpenId__mdt', openId.getCustomMetadataType());
        Map<String,String> authProviderConfig = new Map<String,String>();
        for(Walmart_OpenId__mdt wo : [SELECT AuthorizeEndpointURL__c,Callback_Url__c,CONSUMER_KEY__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName,Response_Type__c,TokenEndpointURL__c,WM_CONSUMER_ID__c,WM_CONSUMER_SECRET__c,WM_SEC_KEY_VERSION__c,WM_SVC_ENV__c,WM_SVC_NAME__c,WM_SVC_VERSION__c FROM Walmart_OpenId__mdt LIMIT 1]){
            authProviderConfig = new Map<String,String>();
            authProviderConfig.put('AuthorizeEndpointURL__c',wo.AuthorizeEndpointURL__c);
            authProviderConfig.put('Callback_Url__c',wo.Callback_Url__c);
            authProviderConfig.put('CONSUMER_KEY__c',wo.CONSUMER_KEY__c);
            authProviderConfig.put('DeveloperName',wo.DeveloperName);
            authProviderConfig.put('Id',wo.Id);
            authProviderConfig.put('Label',wo.Label);
            authProviderConfig.put('Language',wo.Language);
            authProviderConfig.put('MasterLabel',wo.MasterLabel);
            authProviderConfig.put('NamespacePrefix',wo.NamespacePrefix);
            authProviderConfig.put('QualifiedApiName',wo.QualifiedApiName);
            authProviderConfig.put('Response_Type__c',wo.Response_Type__c);
            authProviderConfig.put('TokenEndpointURL__c',wo.TokenEndpointURL__c);
            authProviderConfig.put('WM_CONSUMER_ID__c',wo.WM_CONSUMER_ID__c);
            authProviderConfig.put('WM_CONSUMER_SECRET__c',wo.WM_CONSUMER_SECRET__c);
            authProviderConfig.put('WM_SEC_KEY_VERSION__c',wo.WM_SEC_KEY_VERSION__c);
            authProviderConfig.put('WM_SVC_ENV__c',wo.WM_SVC_ENV__c);
            authProviderConfig.put('WM_SVC_NAME__c',wo.WM_SVC_NAME__c);
            authProviderConfig.put('WM_SVC_VERSION__c',wo.WM_SVC_VERSION__c);
        }
        Test.setMock(HttpCalloutMock.class, new walmartOpenIdTokenMockSuccess());
        if(authProviderConfig.size()>0){
            //CALL BACK
            walmartOpenIdTokenMockSuccess mockSuccess = new walmartOpenIdTokenMockSuccess();
            HTTPResponse callBackResponse = mockSuccess.respond(new HTTPRequest());
            Map<String,String> headerMap = new Map<String,String>();
            for(String key : callBackResponse.getHeaderKeys()){
                headerMap.put(key,callBackResponse.getHeader(key));
            }
            openId.handleCallback(authProviderConfig,new Auth.AuthProviderCallbackState(headerMap,callBackResponse.getBody(),new Map<String,String>()));

        }
        Test.stopTest();
    }

    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for testing sso user info method
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    static testMethod void testGetUserInfo(){
        Test.startTest();
        WalmartOpenId openId = new WalmartOpenId();
        System.assertEquals('Walmart_OpenId__mdt', openId.getCustomMetadataType());
        Map<String,String> authProviderConfig = new Map<String,String>();
        for(Walmart_OpenId__mdt wo : [SELECT AuthorizeEndpointURL__c,User_Info_Endpoint_URL__c, Callback_Url__c,CONSUMER_KEY__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName,Response_Type__c,TokenEndpointURL__c,WM_CONSUMER_ID__c,WM_CONSUMER_SECRET__c,WM_SEC_KEY_VERSION__c,WM_SVC_ENV__c,WM_SVC_NAME__c,WM_SVC_VERSION__c FROM Walmart_OpenId__mdt LIMIT 1]){
            authProviderConfig = new Map<String,String>();
            authProviderConfig.put('AuthorizeEndpointURL__c',wo.AuthorizeEndpointURL__c);
            authProviderConfig.put('Callback_Url__c',wo.Callback_Url__c);
            authProviderConfig.put('CONSUMER_KEY__c',wo.CONSUMER_KEY__c);
            authProviderConfig.put('DeveloperName',wo.DeveloperName);
            authProviderConfig.put('Id',wo.Id);
            authProviderConfig.put('Label',wo.Label);
            authProviderConfig.put('Language',wo.Language);
            authProviderConfig.put('MasterLabel',wo.MasterLabel);
            authProviderConfig.put('NamespacePrefix',wo.NamespacePrefix);
            authProviderConfig.put('QualifiedApiName',wo.QualifiedApiName);
            authProviderConfig.put('Response_Type__c',wo.Response_Type__c);
            authProviderConfig.put('TokenEndpointURL__c',wo.TokenEndpointURL__c);
            authProviderConfig.put('WM_CONSUMER_ID__c',wo.WM_CONSUMER_ID__c);
            authProviderConfig.put('WM_CONSUMER_SECRET__c',wo.WM_CONSUMER_SECRET__c);
            authProviderConfig.put('WM_SEC_KEY_VERSION__c',wo.WM_SEC_KEY_VERSION__c);
            authProviderConfig.put('WM_SVC_ENV__c',wo.WM_SVC_ENV__c);
            authProviderConfig.put('WM_SVC_NAME__c',wo.WM_SVC_NAME__c);
            authProviderConfig.put('WM_SVC_VERSION__c',wo.WM_SVC_VERSION__c);
            authProviderConfig.put('User_Info_Endpoint_URL__c',wo.User_Info_Endpoint_URL__c);
        }
        Test.setMock(HttpCalloutMock.class, new WalmartOpenIdUserInfoMockSuccess());
        if(authProviderConfig.size()>0){
            //CALL BACK
            WalmartOpenIdUserInfoMockSuccess mockSuccess = new WalmartOpenIdUserInfoMockSuccess();
            //HTTPResponse callBackResponse = mockSuccess.respond(new HTTPRequest());
            HTTPResponse callBackResponse2 = mockSuccess.respond(new HTTPRequest());
            Map<String,String> headerMap = new Map<String,String>();
            for(String key : callBackResponse2.getHeaderKeys()){
                headerMap.put(key,callBackResponse2.getHeader(key)); 
            }
            String tokenId = 'eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJkNzdlMzJkMC0xMWMzLTQwZTItOTRmYy0wYTZkNTA2N2VmMjYiLCJhdWQiOlsiNmEwZDhlMDMtMmExZi00NzQ4LTk2MjktZGFiNTczMTE2ZDgyIl0sImxvZ2luSWQiOiJzYW52ZWthcis1MDAxQGdtYWlsLmNvbSIsInNjb3BlIjoib3BlbmlkIiwiaXNzIjoiaHR0cHM6XC9cL2lkcC5xYS5zc28ucGxhdGZvcm0ucWEud2FsbWFydC5jb21cL3BsYXRmb3JtLXNzby1zZXJ2ZXJcLyIsImlhbS10b2tlbiI6ImJTRHRyYmlRTXVBT2NmXC95VHduTGx3ekZWbDV0OUUwQ3Bvc3NCWjh2VVwvc1Q2TlJkc3V0MUtPVElGUWhLTjJ3OXNMNWRnY20rbDllOTN3blpQVzVhbXpjT0JYVDFSWHpjNXpFbW9xb2lKMmo4VW5EV29IOTRUZFlPZnlaNnk5U2lBWnloSnczVVBLSTJDRGp6elNmQ1o2aU8zM3ZPdUVRNHh1VXFWWlRPeExaYVFSTVwvamRJMlwvYUNLMEFOVjZPdmNMdHpsTTExdWptUkN3N21maDI0QVBYZzBPd3d4bnFXTERBdlVPbnpjQjUrdm9DNDE0TXVad0Z4NlpkWEV2bmRaWnN3Y0pjeFVOeXhaNHRqRUpINStNRDlxN3dJTlRSUVE0a0tcL09SbXg0ajQzNWhFeERKK3ZHRU1uVTNHXC91bVwvdSIsInR5cCI6IkJlYXJlciIsImV4cCI6MTQ1ODY3ODgxMSwibm9uY2UiOiJpODh3QVViY1o1WWkzNEJYeDEiLCJpYXQiOjE0NTg2NzcwMTF9.AQXFFzg5gV_Zeky8ygGweHbr37IDHlFTQx-4a82Uy0-UZ5uM9AB12bLkkKeuI8b47yz9zv7fXSDaNqZhpaMk4xy9QN9bn_nqvOcfvLGXpggME0JKD0rkBGX6lePvSPohASKRk5wHI41iykySWDwWB6_SLXE_zNk9abT58B4uf0w';
            openId.getUserInfo(authProviderConfig,new Auth.AuthProviderTokenResponse('walmartOpenId', tokenId, 'oauthSecretOrRefreshToken', 'state'));
           
        }
        Test.stopTest();
    }
    
    /**
     * AUTHOR       : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION  : method for testing sso user info method
     * PARAM        : None
     * RETURN       : None
     * HISTORY      : 03.MAR.2014 - Created (LSantos)
     **/
    static testMethod void testGetUserInfoError(){
        Test.startTest();
        WalmartOpenId openId = new WalmartOpenId();
        System.assertEquals('Walmart_OpenId__mdt', openId.getCustomMetadataType());
        Map<String,String> authProviderConfig = new Map<String,String>();
        for(Walmart_OpenId__mdt wo : [SELECT AuthorizeEndpointURL__c,User_Info_Endpoint_URL__c, Callback_Url__c,CONSUMER_KEY__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName,Response_Type__c,TokenEndpointURL__c,WM_CONSUMER_ID__c,WM_CONSUMER_SECRET__c,WM_SEC_KEY_VERSION__c,WM_SVC_ENV__c,WM_SVC_NAME__c,WM_SVC_VERSION__c FROM Walmart_OpenId__mdt LIMIT 1]){
            authProviderConfig = new Map<String,String>();
            authProviderConfig.put('AuthorizeEndpointURL__c',wo.AuthorizeEndpointURL__c);
            authProviderConfig.put('Callback_Url__c',wo.Callback_Url__c);
            authProviderConfig.put('CONSUMER_KEY__c',wo.CONSUMER_KEY__c);
            authProviderConfig.put('DeveloperName',wo.DeveloperName);
            authProviderConfig.put('Id',wo.Id);
            authProviderConfig.put('Label',wo.Label);
            authProviderConfig.put('Language',wo.Language);
            authProviderConfig.put('MasterLabel',wo.MasterLabel);
            authProviderConfig.put('NamespacePrefix',wo.NamespacePrefix);
            authProviderConfig.put('QualifiedApiName',wo.QualifiedApiName);
            authProviderConfig.put('Response_Type__c',wo.Response_Type__c);
            authProviderConfig.put('TokenEndpointURL__c',wo.TokenEndpointURL__c);
            authProviderConfig.put('WM_CONSUMER_ID__c',wo.WM_CONSUMER_ID__c);
            authProviderConfig.put('WM_CONSUMER_SECRET__c',wo.WM_CONSUMER_SECRET__c);
            authProviderConfig.put('WM_SEC_KEY_VERSION__c',wo.WM_SEC_KEY_VERSION__c);
            authProviderConfig.put('WM_SVC_ENV__c',wo.WM_SVC_ENV__c);
            authProviderConfig.put('WM_SVC_NAME__c',wo.WM_SVC_NAME__c); 
            authProviderConfig.put('WM_SVC_VERSION__c',wo.WM_SVC_VERSION__c);
            authProviderConfig.put('User_Info_Endpoint_URL__c',wo.User_Info_Endpoint_URL__c);
        }
        Test.setMock(HttpCalloutMock.class, new walmartOpenIdTokenMockSuccess());
        if(authProviderConfig.size()>0){
            //CALL BACK
            walmartOpenIdTokenMockSuccess mockSuccess = new walmartOpenIdTokenMockSuccess();
            //HTTPResponse callBackResponse = mockSuccess.respond(new HTTPRequest());
            HTTPResponse callBackResponse2 = mockSuccess.respond(new HTTPRequest());
            Map<String,String> headerMap = new Map<String,String>();
            for(String key : callBackResponse2.getHeaderKeys()){
                headerMap.put(key,callBackResponse2.getHeader(key)); 
            }
            String tokenId = 'eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJkNzdlMzJkMC0xMWMzLTQwZTItOTRmYy0wYTZkNTA2N2VmMjYiLCJhdWQiOlsiNmEwZDhlMDMtMmExZi00NzQ4LTk2MjktZGFiNTczMTE2ZDgyIl0sImxvZ2luSWQiOiJzYW52ZWthcis1MDAxQGdtYWlsLmNvbSIsInNjb3BlIjoib3BlbmlkIiwiaXNzIjoiaHR0cHM6XC9cL2lkcC5xYS5zc28ucGxhdGZvcm0ucWEud2FsbWFydC5jb21cL3BsYXRmb3JtLXNzby1zZXJ2ZXJcLyIsImlhbS10b2tlbiI6ImJTRHRyYmlRTXVBT2NmXC95VHduTGx3ekZWbDV0OUUwQ3Bvc3NCWjh2VVwvc1Q2TlJkc3V0MUtPVElGUWhLTjJ3OXNMNWRnY20rbDllOTN3blpQVzVhbXpjT0JYVDFSWHpjNXpFbW9xb2lKMmo4VW5EV29IOTRUZFlPZnlaNnk5U2lBWnloSnczVVBLSTJDRGp6elNmQ1o2aU8zM3ZPdUVRNHh1VXFWWlRPeExaYVFSTVwvamRJMlwvYUNLMEFOVjZPdmNMdHpsTTExdWptUkN3N21maDI0QVBYZzBPd3d4bnFXTERBdlVPbnpjQjUrdm9DNDE0TXVad0Z4NlpkWEV2bmRaWnN3Y0pjeFVOeXhaNHRqRUpINStNRDlxN3dJTlRSUVE0a0tcL09SbXg0ajQzNWhFeERKK3ZHRU1uVTNHXC91bVwvdSIsInR5cCI6IkJlYXJlciIsImV4cCI6MTQ1ODY3ODgxMSwibm9uY2UiOiJpODh3QVViY1o1WWkzNEJYeDEiLCJpYXQiOjE0NTg2NzcwMTF9.AQXFFzg5gV_Zeky8ygGweHbr37IDHlFTQx-4a82Uy0-UZ5uM9AB12bLkkKeuI8b47yz9zv7fXSDaNqZhpaMk4xy9QN9bn_nqvOcfvLGXpggME0JKD0rkBGX6lePvSPohASKRk5wHI41iykySWDwWB6_SLXE_zNk9abT58B4uf0w';
            openId.getUserInfo(authProviderConfig,new Auth.AuthProviderTokenResponse('walmartOpenId', tokenId, 'oauthSecretOrRefreshToken', 'state'));
           
        }
        Test.stopTest();
    }
}