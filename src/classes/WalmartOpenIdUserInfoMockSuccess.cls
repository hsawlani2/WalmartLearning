@isTest
global class WalmartOpenIdUserInfoMockSuccess implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        WalmartUserInfoMap userInfoMap = new WalmartUserInfoMap();
 
        userInfoMap.status = 'Success';
        String payloadParse = '{"status":\"Success\",\"payload\":{\"loginId\":\"testId\",\"firstName\":\"testFName\",\"lastName\":\"testLName\",\"uuid\":\"testuuId\",\"sellerId\":\"testSellerId\",\"partnerId\":\"testPartnerId\",\"partnerType\":\"testPartnerType\"}}';
        //WalmartUserInfoMap.parse thisPayload = new WalmartUserInfoMap.parse(payloadParse); 
        //userInfoMap.parse(payloadParse);     
        WalmartUserInfoMap userInfoResponse = WalmartUserInfoMap.parse(payloadParse); 
        userInfoResponse.status = 'OK';
        userInfoResponse.Payload.firstName = 'fName';
        userInfoResponse.Payload.lastName = 'lName';
        userInfoResponse.Payload.uuid = 'testUUID';
        userInfoResponse.Payload.sellerId = 'testSellerId';
        userInfoResponse.Payload.partnerId = 'testPartnerId'; 
        userInfoResponse.Payload.partnerType = 'testPartnerType';
        userInfoResponse.Payload.loginId = 'loginId';

        response.setHeader('Content-Type','application/json');
        response.setBody(JSON.serializePretty(userInfoResponse));
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
        
    }

    
}