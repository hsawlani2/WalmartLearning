@isTest
global class walmartOpenIdTokenMockSuccess implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        WalmartOpenId.tokenResponse tokenResponse = new WalmartOpenId.tokenResponse();
        tokenResponse.token_Type = 'Bearer';
        tokenResponse.expires_in = 1800;
        tokenResponse.id_token = 'eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJkNzdlMzJkMC0xMWMzLTQwZTItOTRmYy0wYTZkNTA2N2VmMjYiLCJhdWQiOlsiNmEwZDhlMDMtMmExZi00NzQ4LTk2MjktZGFiNTczMTE2ZDgyIl0sImxvZ2luSWQiOiJzYW52ZWthcis1MDAxQGdtYWlsLmNvbSIsInNjb3BlIjoib3BlbmlkIiwiaXNzIjoiaHR0cHM6XC9cL2lkcC5xYS5zc28ucGxhdGZvcm0ucWEud2FsbWFydC5jb21cL3BsYXRmb3JtLXNzby1zZXJ2ZXJcLyIsImlhbS10b2tlbiI6ImJTRHRyYmlRTXVBT2NmXC95VHduTGx3ekZWbDV0OUUwQ3Bvc3NCWjh2VVwvc1Q2TlJkc3V0MUtPVElGUWhLTjJ3OXNMNWRnY20rbDllOTN3blpQVzVhbXpjT0JYVDFSWHpjNXpFbW9xb2lKMmo4VW5EV29IOTRUZFlPZnlaNnk5U2lBWnloSnczVVBLSTJDRGp6elNmQ1o2aU8zM3ZPdUVRNHh1VXFWWlRPeExaYVFSTVwvamRJMlwvYUNLMEFOVjZPdmNMdHpsTTExdWptUkN3N21maDI0QVBYZzBPd3d4bnFXTERBdlVPbnpjQjUrdm9DNDE0TXVad0Z4NlpkWEV2bmRaWnN3Y0pjeFVOeXhaNHRqRUpINStNRDlxN3dJTlRSUVE0a0tcL09SbXg0ajQzNWhFeERKK3ZHRU1uVTNHXC91bVwvdSIsInR5cCI6IkJlYXJlciIsImV4cCI6MTQ1ODY3ODgxMSwibm9uY2UiOiJpODh3QVViY1o1WWkzNEJYeDEiLCJpYXQiOjE0NTg2NzcwMTF9.AQXFFzg5gV_Zeky8ygGweHbr37IDHlFTQx-4a82Uy0-UZ5uM9AB12bLkkKeuI8b47yz9zv7fXSDaNqZhpaMk4xy9QN9bn_nqvOcfvLGXpggME0JKD0rkBGX6lePvSPohASKRk5wHI41iykySWDwWB6_SLXE_zNk9abT58B4uf0w';
         
        response.setHeader('Content-Type','application/json');
        response.setBody(JSON.serializePretty(tokenResponse));
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
        
    }
}