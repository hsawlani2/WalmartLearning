/*
 * Walmart 
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            09/06/2016
 * @description     Scheduler class to delete Subscriber List data older than 5 days.
 */
global class WalSubscriberListDeletionScheduler implements Schedulable {
/*
 * Walmart 
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            09/06/2016
 */
    global void execute(SchedulableContext sc) {
        WalSubscriberListDeletion sl = new WalSubscriberListDeletion();
        Database.executeBatch(sl, 200);          
   }
}