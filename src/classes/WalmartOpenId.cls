/**
 * @Author: Srinivas Koduru
 * @Copyright: Cloud Sherpas.  This code is customized to suite Walmart requirements.
 * @Version: Custom OpenId Connector for Salesforce
 * @Description: This class is the controller class for Walmart OpenId Connector
 * @History: First created by Srini on 02/24/2016
 * @         02/26/2016 - Srini added code for 'initiate' method to call mock server
 *           03/24/2016 - shadjinoor code clean up - used custom settings for some hard coded values
 * */
public class WalmartOpenId implements Auth.AuthProviderPlugin{
    
    //private static final String privateKey_in_production = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALko19xXFibZrOOG0SzYW1wcydLCYfNoOLppPLdpkC0pswVkRymQnrrRES5pcGj0jTtFNvG0pEOyAzBeuWxe+Af6Jgv2BQWhUWq9ACGvtyR5eq09M9PhwwnS4Pzo32pJyJbK40an0iPo+f7Npo2fPU8+EYcGaV/6KEyQX6LvVEU7AgMBAAECgYBYRFozFejfeGFszbYl1LYowSiNKlEbghGY+9YP8Wjjvr8y0M0DyYeBs2ynXWhTAFHbcXFx5BVymAfhJSbrvJIsG75UEqfUlB9LEHZ1CbXYhMElVQh0/aEsQt8BLa8RN6+Eoc4Q2ug5iUl8wuXIhkgce70tJyna80jrg22gGH+H0QJBAN1jJSe1WcCU59hYVfjSc3SIuzXI1qT7DzCh8Ofez+sJk1iMXoGqMYtmNBAU3tGrLdmt1W70zP04S96Whp9PcmcCQQDWG7Xx00IspcVqNO9bfTbsHqbWpfyMZMg9XdcD5qtkKiP3Y7eM0bmNOc3Rfh673cnY/oWm7xdlM0UL+hUZyxoNAkEAmRHRAciI+ve56cMCBl10SJG1ZzWq+z0/Pm/pwlgzSB5By4qaWWrUgL60pp3Xhf6mYAiqNuJ5zWccRhWrlQD4ZwJBAI+Kmmtax7WpGXX/sSz0AHtCfXXQaEUzV++UVw99eRA5FE3J44ecHzroMu0tEau/oJBC6xWkm1m0iqjh632UZY0CQGe3PoTaAP8qI/GW5AhK+b5j3GCP5Q2SOXDMjCHSGs/4I4jb6hCIJ62uZhS0CTniKTv8/NotAn17D8sFxCuyhE8=';
  
    private static final String privateKey = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALko19xXFibZrOOG0SzYW1wcydLCYfNoOLppPLdpkC0pswVkRymQnrrRES5pcGj0jTtFNvG0pEOyAzBeuWxe+Af6Jgv2BQWhUWq9ACGvtyR5eq09M9PhwwnS4Pzo32pJyJbK40an0iPo+f7Npo2fPU8+EYcGaV/6KEyQX6LvVEU7AgMBAAECgYBYRFozFejfeGFszbYl1LYowSiNKlEbghGY+9YP8Wjjvr8y0M0DyYeBs2ynXWhTAFHbcXFx5BVymAfhJSbrvJIsG75UEqfUlB9LEHZ1CbXYhMElVQh0/aEsQt8BLa8RN6+Eoc4Q2ug5iUl8wuXIhkgce70tJyna80jrg22gGH+H0QJBAN1jJSe1WcCU59hYVfjSc3SIuzXI1qT7DzCh8Ofez+sJk1iMXoGqMYtmNBAU3tGrLdmt1W70zP04S96Whp9PcmcCQQDWG7Xx00IspcVqNO9bfTbsHqbWpfyMZMg9XdcD5qtkKiP3Y7eM0bmNOc3Rfh673cnY/oWm7xdlM0UL+hUZyxoNAkEAmRHRAciI+ve56cMCBl10SJG1ZzWq+z0/Pm/pwlgzSB5By4qaWWrUgL60pp3Xhf6mYAiqNuJ5zWccRhWrlQD4ZwJBAI+Kmmtax7WpGXX/sSz0AHtCfXXQaEUzV++UVw99eRA5FE3J44ecHzroMu0tEau/oJBC6xWkm1m0iqjh632UZY0CQGe3PoTaAP8qI/GW5AhK+b5j3GCP5Q2SOXDMjCHSGs/4I4jb6hCIJ62uZhS0CTniKTv8/NotAn17D8sFxCuyhE8=';
    //private static final String privateKey_works_for_staging_consumer_key ='MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAI/F2XAmi0lHC7xsXmepyfMzAAC5hs8UHPZ27fbMMwYeiQTY6tg6V9XC9xLQ89+0UEzRLvgLPTRERtnGlUq7r+7bkuDQAeazYFU1vD/ZsGiD1yDSyKtnD4tNUz/d4XcjtAEwAohpzIwG8MD3aC1aRM5OzuK2kqGjJMTjPc8Offr5AgMBAAECgYAT8Gt8e0v76Kd/BUR+efSxDtSkRRamJ3Lw14OfI6i744Y7Lt47CLRfx/8+E86OqtIsJSKvcdeWJRXyY/EWgTsf3Or/ljNEgYPo+d//2+11tB8ExJ/jZm2Ykb6lw51QDWdD3vS0Oys+gxAyZestu6WMY1gLfhDNzg1njpG1izc3UQJBAP5GGJELDOz0DLFx99suh1bRIS9j6VLwiImGLp09oKAEjItrtOWUgSAped8tlQzAmBdj6pqeAeyS0h9jx0uTGE0CQQCQv7aNWqaajpNU3ATnrxild/053ZbVwwyVzMywdN3YdLGdrB1JXe9KS/uFsYylo8Gydmi92Ero3lhjbqieekNdAkEAv/uYzNp1FetmMgwEwd6tnOUlkyxynIaz8HH5fAtt3aPRoeremIC5xdjLBbDa2tgHfZGZLsiiV0a7k6u4a91R+QJBAI0rvPIdwDEq7nwr3UjMl4ACB2FhQROYGHUc+WD7icXrAbNiQmnkiFVwx407fY2qqWXRYBQPl/eHqrLHIQL3AS0CQQCfnhj6pmHzsfH+0D1RQYv4jKVuEDc+FnCvD7yGnhgvOp7fue4hqCdUN2EBrQX049J7Z2CwHnbQSYTOlggp3Dq5';
    public String redirectUrl; //This is a call back url that we will pass on. Will put it in the metadata
    private String key;
    private String secret;
    private String authUrl; // application redirection to the Concur website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from concur  using the GET verb
    private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
    private String userAPIUrl; // api url to access the user in Walmart
    private String userAPIVersionUrl; // version of the user api url to access data     from Walmart
    public Walmart_Open_Id__c walmartSettings = Walmart_Open_Id__c.getValues('WalmartOpenId');// get hard coded values from custom settings, added shadjinoor 3/24/2016
    
    public class tokenResponse{
        public String id_token{get;set;}
        public String token_type{get;set;}
        public Integer expires_in{get;set;}
        public String errorDescription{get;set;}
    }
    /**
     * @Description: Config constructor. This is the method that populate custom fields on Walmart OpenId Auth. Provider form
     * @History: 02/25/2016 - Srini created this method
     *           03/24/2016 - shadjinoor update to use custom settings for authprovider
    */    
    public String getCustomMetadataType(){
        String authProvider = walmartSettings.Auth_Provider__c;
        return authProvider;
    }
    
    /**
     * @Description: Init method. This method initiate an Auth call to Auth endpoint.
     *               as of 02/26/2016 now we are redirecting to koduru.we.bs.  
     *               We need to change this to MPP Server once MPP server is ready
     * @History: 02/26/2016 - Srini created this method.
     * @Process Flow Step: Step 1 - Auth Endpoint
    */
    public System.PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate){
       
        authUrl = authProviderConfiguration.get('AuthorizeEndpointURL__c');
        key = authProviderConfiguration.get('CONSUMER_KEY__c');
        redirectUrl = authProviderConfiguration.get('Callback_Url__c');
        String responseType = authProviderConfiguration.get('Response_Type__c');
        String scope = authProviderConfiguration.get('Scope__c');
        String url = authUrl + '?client_id='+ key +'&scope='+ scope + '&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate + '&response_type=' + responseType + '&nonce=' + genNonce();
        System.debug('Auth URL : ' + url);
        return new PageReference(url);
    }
    
    /**
     * @Description: Init method. This method takes care of second step i.e. token endpoint call to get JWT token.
     *               
     * @History: 02/26/2016 - Srini created this method.
     *           
     * @Process Flow Step: Step 2 - JWT Token Endpoint
    */
    public Auth.AuthProviderTokenResponse handleCallback(Map<String,String> authProviderConfiguration, Auth.AuthProviderCallbackState state){
        System.debug('Inside handleCallback ');
        Long SystemtimeStamp = DateTime.now().getTime();
        String timeStampString = String.valueof(SystemtimeStamp);
        String code = 'FALSDIUFLKFJALF'; //dummy code. Thanks to SFDC internal bugs. What the hell man.
        
        //pick up the code and state to get JwT token
        Map<String,String> queryParams = state.queryParameters;
        /*if(queryParams.containsKey('cskv') == true){ //Thanks to SFDC internal bugs. What the hell man.
            code = queryParams.get('code');
        }*/
        code = queryParams.get('code');
        
        String sfdcState = queryParams.get('state');
 
        String consumerId = authProviderConfiguration.get('WM_CONSUMER_ID__c');
        String consumerKey = authProviderConfiguration.get('CONSUMER_KEY__c'); //changed the label to CLIENT.ID in configuration as needed by Sriram
        String consumerSecret = authProviderConfiguration.get('WM_CONSUMER_SECRET__c');
        String tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointURL__c');
        
        String callBackUrl = authProviderConfiguration.get('Callback_Url__c');
        
        String formattedInput = '';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpointUrl);
        
        req.setMethod('POST');
        
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('WM_QOS.CORRELATION_ID', string.valueOf((math.random() * 5).intValue()));//put a random math function here
        System.debug('WM_QOS.CORRELATION_ID:'+ authProviderConfiguration.get('WM_SVC_ENV__c'));
        req.setHeader('WM_SVC.ENV', authProviderConfiguration.get('WM_SVC_ENV__c'));
        System.debug('WM_SVC.ENV:'+ authProviderConfiguration.get('WM_SVC_ENV__c'));
        req.setHeader('WM_CONSUMER.ID', consumerId);
        System.debug('WM_CONSUMER:'+ consumerId);
        req.setHeader('WM_SVC.VERSION', authProviderConfiguration.get('WM_SVC_VERSION__c'));
        System.debug('WM_SVC.VERSION'+ authProviderConfiguration.get('WM_SVC_VERSION__c'));
        req.setHeader('WM_SVC.NAME', authProviderConfiguration.get('WM_SVC_NAME__c'));
        System.debug('WM_SVC.NAME:'+ authProviderConfiguration.get('WM_SVC_NAME__c'));
        req.setHeader('WM_CONSUMER.INTIMESTAMP', timeStampString);
        System.debug('timestamp:' + timeStampString);
        req.setHeader('WM_SEC.KEY_VERSION', authProviderConfiguration.get('WM_SEC_KEY_VERSION__c'));
        System.debug('KEY VERSION:' + authProviderConfiguration.get('WM_SEC_KEY_VERSION__c'));
        String basicAuthHeader = genBasicAuth(consumerKey, consumerSecret);
        req.setHeader('Authorization', basicAuthHeader);
        System.debug('basicAuthHeader:' + basicAuthHeader);
        
        formattedInput += consumerId + '\n' + timeStampString + '\n' + authProviderConfiguration.get('WM_SEC_KEY_VERSION__c') + '\n';
        String authSignature = generateAuthSignature(formattedInput);
        req.setHeader('WM_SEC.AUTH_SIGNATURE', authSignature);
        System.debug('authsignature: ' + authSignature);
        
        System.debug('redirect_uri:' + callBackUrl);
        System.debug('code:' + code);
        System.debug('grant_type' + 'authorization_code');
        
        String body = '{"redirect_uri":"' + callBackUrl +'","code":"'+ code + '","grant_type":"authorization_code"}';
        System.debug('Getting authProvierConfig ');
        req.setBody(body);
        
        try{
            Http http = new Http();
            System.debug('Before sending the token request... callback url ' + callBackUrl);
            HttpResponse response = http.send(req);
            System.debug('Response from token call...status is ' + response.getStatusCode() );
            if(response.getStatusCode() == 200){
                //PARSE JSON RESPONSE. 
                tokenResponse responseDeserialized = (tokenResponse)System.JSON.deserialize(response.getBody(),tokenResponse.class);
                
                String token = responseDeserialized.id_token;
                System.debug('Token:' + token);
                System.debug('Consumer secret:' + consumerSecret);
                return new Auth.AuthProviderTokenResponse('WalmartOpenId', token, consumerSecret, sfdcState);
            }else if(response.getStatusCode() == 401){
                //dummy reutn. Thanks to SFDC internal bugs. What the hell man
                return new Auth.AuthProviderTokenResponse('WalmartOpenId', 'dummy token', 'dummy consumerSecret', sfdcState);
            }else{
                reDirectToAnErrorPage();
                return null;    
            }
        }catch(Exception e){
            //redirect to error page
            reDirectToAnErrorPage();
            return null;
        }
    }
    /**
     * @Description: This method will be automatically called in salesforce internals. But we need to construct the user data from the token
     * @History: 02/26/2016 - Srini created this method
     *           03/24/2016 - shadjinoor code clean up - used custom settings for some hard coded values
    */
    public Auth.UserData getUserInfo(Map<String,String> authProviderConfiguration, Auth.AuthProviderTokenResponse response){
        
        //Once the JWT token is there the we should be decrypt the same here to get the user details
        //Here the developer is responsible for constructing an Auth.UserData object
        
        String token = response.oauthToken;
        HttpRequest req = new HttpRequest();
        String userInfoUrl = authProviderConfiguration.get('User_Info_Endpoint_URL__c');
        
        System.debug('JwT : ' + token);
        String nonce = getKeyValue(token, 'nonce');
        String sellerEmail = getKeyValue(token, 'email');
        System.debug('Seller email : ' + sellerEmail);
        
        req.setEndpoint(userInfoUrl);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Token',token); //we need to replace with what the IAM team want it to be here.
        req.setHeader('client-id',authProviderConfiguration.get('CONSUMER_KEY__c'));
        req.setHeader('nonce',nonce); //we need to work on parsing JwT Token to pickup Nonce
        
        String urlToUserInfo = userInfoUrl + '?Content-Type=application/json'
                        + '&' + 'Accept=application/json'
                        + '&' + 'Token=' + token
                        + '&' + 'client-id=' + authProviderConfiguration.get('CONSUMER_KEY__c')
                        + '&' + 'nonce=' + nonce;
        
        try{           
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String responseBody = res.getBody();
            
            //String responseBody = WalmartUserInfoMap.testUserInfoJSON;
            
            System.debug('User Info : ' + responseBody);
            if(res.getStatusCode() == 200){
            //if(true) {
                WalmartUserInfoMap deserializeResult = WalmartUserInfoMap.parse(responseBody);
                String id = deserializeResult.payload.uuid;
                String firstName = deserializeResult.payload.firstName;
                String lastName = deserializeResult.payload.lastName;
                String flName = firstName + ' ' + lastName;
                String uname = deserializeResult.payload.loginId;
                String email = (sellerEmail != 'dummy value')?sellerEmail:deserializeResult.payload.loginId;
                String locale = 'US';
                String link = walmartSettings.Link__c;
                String provider = 'WalmartOpenId';
                //String siteLoginUrl = 'https://sk-walmartsupport.cs3.force.com/cases/login';//Network.getLoginUrl('0DM61000000QIYA');//this should come from custom settings
                String siteLoginUrl;
                Map<String,String> provMap = new Map<String,String>();
                provMap.put('uuid', deserializeResult.payload.uuid);
                provMap.put('email', deserializeResult.payload.loginId);
                provMap.put('sfdc_networkid', walmartSettings.SFDC_Network_Id__c);
                
                provMap.put('partnerId', deserializeResult.payload.partnerId);
                provMap.put('orgId', deserializeResult.payload.orgId);
                provMap.put('partnerType',deserializeResult.payload.partnerType);
                System.debug('user info prov map:' + provMap);
                Auth.UserData userData= new Auth.UserData(id,firstName,lastName,flName,email, link, uname, locale, provider, siteLoginUrl, provMap);
                
                return userData;
            }else{
                //do some error handling
                reDirectToAnErrorPage();
                return null; 
            }
        }catch(Exception e){
            // redirect to error page.
            reDirectToAnErrorPage();
            return null;
        }
    }
    
    /**
     * @Description: This method generates Auth basic Base64 String.
     * @History: 02/27/2016 - Srini created this method
    */
    private static String genBasicAuth(String consumerId, String consumerSecret){
        String authBasic = 'Basic ';
        String toEncode = consumerId + ':' + consumerSecret;
        Blob authBasicBlob = Blob.valueOf(toEncode);
        authBasic = authBasic + EncodingUtil.base64Encode(authBasicBlob);
        return authBasic;
    }
    /**
     * AUTHOR : Lennard Santos(Cloud Sherpas)
     * DESCRIPTION : method that generates signed signature to be sent.
     * PARAM
     * */
    private static String generateAuthSignature(String canonicalStr){
        if(String.isNotBlank(canonicalStr)){
            Blob blobInput = Blob.valueOf(canonicalStr);
            Blob signedKey = Crypto.sign('RSA-SHA256', blobInput, EncodingUtil.base64Decode(privateKey));
            return EncodingUtil.base64Encode(signedKey);
        }else{
            return null;    
        }
        
    }
    
    /**
     * @Description: This method generates a nonce.
     *               
     * @History: 03/15/2016 - Srini created this method.
     * @Process Flow Step: Step 1 - Auth endpoint
    */
    private String genNonce(){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        Integer len = 18;
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
        
    }
    
    /**
     * @Description: This method generates a nonce.
     *               
     * @History: 03/17/2016 - Srini created this method.
     * @Process Flow Step: Step 3 - Pickup nonce from JwT token
    */
    private String getKeyValue(String token, String key){
        String value = 'dummy value';
        String[] JWTParts = token.split('\\.');
        String JWTBody = (String)EncodingUtil.base64Decode(JWTParts[1]).toString(); 
        JSONParser jp = JSON.createParser(JWTBody);
        while(jp.nextToken() != null){
            if ((jp.getCurrentToken() == JSONToken.FIELD_NAME) && (jp.getText() == key)){
                jp.nextValue();
                value = (jp.getText() != null)?jp.getText():'dummy value';
                break;
            }
        }        
        return value;    
    }
    
    /**
     * @Description: This method redirect user to an error page display
     *               
     * @History: 03/23/2016 - Srini created this method.
     *           03/24/2016 - shadjinoor code clean up - used custom settings for some hard coded values
    */
     
    public System.PageReference reDirectToAnErrorPage(){
        return new PageReference(walmartSettings.Error_Page_Link__c);
    }
}