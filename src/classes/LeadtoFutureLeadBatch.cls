/**
* This class is a batch class that will go query all leads and update the lead type to future lead which were not modified for last 45 days.
 
 * ======================================================================
 * @author  Ashok Panbuchelvam
 * Date        Purpose
 * 04/30/2016  Initial version.
 * ======================================================================
 **/

 global class LeadtoFutureLeadBatch implements Database.Batchable<sObject>{ 

    global LeadtoFutureLeadBatch(){
    
       
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        // query our object and process none successful records
           
        String mprecordType='MP_Account';
        String soqlString = 'SELECT Id,LastModifiedDate,Name,Status FROM Lead WHERE LastModifiedDate <= N_DAYS_AGO:45 AND Status = \'LEAD\'  AND  RecordType.DeveloperName=:mprecordType limit 45000';
        system.debug('Query:'+soqlString);
        return Database.getQueryLocator(soqlString);
    }
global void execute(Database.BatchableContext bc, List<sObject> leadRecords){
        List<Lead> leadList = (List<Lead>)leadRecords; 
        // Partner Channel Variables

       
        List<Lead> oFUpdateList = new List<Lead>();

        for(Lead le : leadList){
            if(le.LastModifiedDate != null){
                le.Status ='Future Lead';
                oFUpdateList.add(le);
            }

        }
        try{
            database.update(oFUpdateList,false);
        }
        catch(Exception ex){

            System.debug('Dev: Error is ' + ex.getMessage()); 
        }
    }
    global void finish(Database.BatchableContext bc){

    }
}