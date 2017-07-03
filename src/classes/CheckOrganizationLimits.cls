public class CheckOrganizationLimits{
    
    public static LimitResponseWrapper CheckLimits()
    {
        Http h = new Http();
        HttpRequest req = new httprequest();
        
        string domainName = URL.getSalesforceBaseUrl().toExternalForm();
        string endPointURL = domainName+'/services/data/v37.0/limits';
        req.setendpoint(endPointURL); 
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setMethod('GET');
        
        HTTPResponse res = h.send(req);
        
        if(res.getStatusCode() == 200)
        {
            LimitResponseWrapper lmtResponse = (LimitResponseWrapper) JSON.deserialize(res.getbody(), LimitResponseWrapper.class);
            
            system.debug('lmtResponse :::::' + lmtResponse);
            
            return lmtResponse;
        }
        
        return null;
    }
    
    public class LimitResponseWrapper{
        public LimitWrapper ConcurrentAsyncGetReportInstances;
        public LimitWrapper ConcurrentSyncReportRuns;
        public LimitWrapper DailyApiRequests;
        public LimitWrapper DailyAsyncApexExecutions;
        public LimitWrapper DailyBulkApiRequests;
        public LimitWrapper DailyDurableGenericStreamingApiEvents;
        public LimitWrapper DailyDurableStreamingApiEvents;
        public LimitWrapper DailyGenericStreamingApiEvents;
        public LimitWrapper DailyStreamingApiEvents;
        public LimitWrapper DailyWorkflowEmails;
        public LimitWrapper DataStorageMB;
        public LimitWrapper DurableStreamingApiConcurrentClients;
        public LimitWrapper FileStorageMB;
        public LimitWrapper HourlyAsyncReportRuns;
        public LimitWrapper HourlyDashboardRefreshes;
        public LimitWrapper HourlyDashboardResults;
        public LimitWrapper HourlyDashboardStatuses;
        public LimitWrapper HourlyODataCallout;
        public LimitWrapper HourlySyncReportRuns;
        public LimitWrapper HourlyTimeBasedWorkflow;
        public LimitWrapper MassEmail;
        public LimitWrapper SingleEmail;
        public LimitWrapper StreamingApiConcurrentClients;
    }
    
    public class LimitWrapper{
        public integer Max;
        public integer Remaining;
    }
}