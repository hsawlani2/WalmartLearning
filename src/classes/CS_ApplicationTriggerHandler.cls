/*
    Author              : Rayson Landeta
    Email               : rayson.landeta@cloudsherpas.com
    Company             : Cloud Sherpas
    Date Created        : 05-JAN-2016
    Description         : 1st Handler class of trigger for Application.
*/

public with sharing class CS_ApplicationTriggerHandler {
    /*
        Author              : Rayson Landeta
        Email               : rayson.landeta@cloudsherpas.com
        Company             : Cloud Sherpas
        Date Created        : 05-JAN-2016
        Description         : Method for after insert of application object.
    */
    public void afterInsert(List<Application__c> applicationList){
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> oppId = new List<String>();
        Map<String, Application__c> appMap = new Map<String, Application__c>();
        for(Application__c a : applicationList){
            if(a.Opportunity__c != null){
                oppId.add(a.Opportunity__c);
                appMap.put(a.Opportunity__c, a);
            }
        }
        if(!oppId.isEmpty()){
            oppList = [SELECT Id, Latest_Application_ID__c FROM Opportunity WHERE Id IN : oppId];
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            
            if(!oppList.isEmpty()){
                for(Opportunity o: oppList){
                    if(appMap.containskey(o.Id)){
                        Application__c app = appMap.get(o.Id);
                        o.Latest_Application_ID__c = app.Id;
                        o.Latest_Application_SFDC_ID__c = String.valueOf(app.Id);
                        oppListToUpdate.add(o);
                    }
                }
                
                if(!oppListToUpdate.isEmpty()){
                    // LQ: This causes an error still
                    update oppListToUpdate;
                }
            } 
        }
    }
}