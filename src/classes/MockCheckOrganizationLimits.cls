@isTest
global class MockCheckOrganizationLimits implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('GET', req.getMethod());
        
        CheckOrganizationLimits.LimitResponseWrapper lw = new CheckOrganizationLimits.LimitResponseWrapper();
        
        CheckOrganizationLimits.LimitWrapper lmw = new CheckOrganizationLimits.LimitWrapper();
        lmw.Max = 12;
        lmw.Remaining = 21;
        
        lw.SingleEmail = lmw;
        
        string body = JSON.serialize(lw);
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}