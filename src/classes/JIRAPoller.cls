global class JIRAPoller implements Schedulable{
    /**
     * whenever a Case's status is changed in Salesforce 
     * @param caseId    the case id representing the case record being updated
     */
    global static void execute(SchedulableContext SC) {
        testJIRAConnection();
        JIRAPoller.start();
        // abort me and start again
        System.abortJob( SC.getTriggerId() );            
    }

    @future(callout=true)
    public static void testJIRAConnection()
    {
        system.debug('[JIRAPoller] Polling JIRA Server ');
        JIRA_CONFIG__c jiraConfig = JIRA_CONFIG__c.getValues('CONFIG');
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String endpoint = jiraConfig.URL__c + '/rest/api/2/serverInfo';
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        if(!test.isrunningtest())
        {
            try {
                res = http.send(req);
                if(res.getStatusCode()!=200)
                {
                    sendAlertEmail(jiraConfig);                
                }
            } catch(System.CalloutException e) {
                System.debug('[JIRAPoller] Error calling JIRA server - ' + res.toString());
                sendAlertEmail(jiraConfig);
            }
        }
        
   
    }
    
    static void start()
    {
        // start keepalive again in 5 mins
        Datetime sysTime = System.now().addSeconds( 300 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'SelfSchedule ' + sysTime, chronExpression, new JIRAPoller() );
    }
    
    public static void sendAlertEmail(JIRA_CONFIG__c jiraConfig)
    {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailAddress = jiraConfig.alertsRecipient__c; 
        if(emailAddress==null)
            emailAddress = 'CATDEVSA10@email.wal-mart.com';
        String[] toAddresses = new String[] {emailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('GeCRM Salesforce Org');
        mail.setSubject('Salesforce JIRA connectivity down');
        mail.setUseSignature(false);
        mail.setPlainTextBody('Detected connectivity issue between Salesforce and JIRA at: ' + System.now() + '. Case <> JIRA issue updates during this time may be impacted');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}