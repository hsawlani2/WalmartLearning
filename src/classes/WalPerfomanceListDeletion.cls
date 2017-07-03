/*
 * Walmart 
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            09/06/2016
 * @description     batch class to delete Performannce Snapshot data older than 5 days.
 */
global with sharing class WalPerfomanceListDeletion implements Database.Batchable<sObject>{
    global String query;
    Date daycount =  Date.today().addDays(-Integer.valueof(system.label.Snapshot_Day_Count));
 /*Start method for the batch class*/
global Database.QueryLocator start(Database.BatchableContext BC)
{ 
 query = 'SELECT Id from wal_Performance_Snapshot__c where wal_Snapshot_Date__c <: daycount AND wal_Snapshot_Date__c != NULL';
 return Database.getQueryLocator(query);    
}
 /*Execute method for the batch class to delete Performannce Snapshot data older than 5 days*/
global void execute(Database.BatchableContext BC,List<sObject> scope){
    //delete scope;
    List <wal_Performance_Snapshot__c> PSList= (List<wal_Performance_Snapshot__c>)scope;
    Database.DeleteResult [] snapshot = Database.delete(PSList);    
 }
/*Finish method for the batch class*/
global void finish(Database.BatchableContext BC){
   }
}