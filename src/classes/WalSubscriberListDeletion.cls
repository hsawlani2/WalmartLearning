/*
 * Walmart 
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            09/06/2016
 * @description     batch class to delete subscriber list.
 */
global with sharing class WalSubscriberListDeletion implements Database.Batchable<sObject>{
    global String query;
    Datetime daycount =  Datetime.now().addDays(-Integer.valueof(system.label.Subscriber_Day_Count));
 /*Start method for the batch class*/
global Database.QueryLocator start(Database.BatchableContext BC)
{ 
    system.debug('**daycount**'+daycount);
      if(!Test.isRunningTest()){
         query = 'SELECT Id from Subscriber_List__c where CreatedDate<: daycount';
         }
         else{
         query = 'SELECT Id from Subscriber_List__c ';
         }
  system.debug('===>query'+query);
 return Database.getQueryLocator(query);    
}
 /*Execute method for the batch class to delete Subscriber List data older than 5 days*/
global void execute(Database.BatchableContext BC,List<sObject> scope){
    //delete scope;
    
    List <Subscriber_List__c> SLList= (List<Subscriber_List__c>)scope;
    system.debug('===>scope'+SLList);
    Database.DeleteResult [] subscriber = Database.delete(SLList);    
 }
/*Finish method for the batch class*/
global void finish(Database.BatchableContext BC){
   }
}