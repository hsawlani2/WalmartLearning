/***********************************************************
Class Name:WALCreateSubscriberListBatchScheduler
Purpose: Schedule the WALCreateSubscriberListBatch class
Version 1.0 8th Sept 2016 Draft
/***********************************************************/
global class WALCreateSubscriberListBatchScheduler implements Schedulable {
    /** Scheduling the class**/
    global void execute(SchedulableContext sc) {
        WALCreateSubscriberListBatch subscriberListBatch = new WALCreateSubscriberListBatch();
        Database.executeBatch(subscriberListBatch, 100);          
    }
}