/*
 * Walmart 
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            09/06/2016
 * @description     Scheduler class to delete Performance Snapshot data older than 5 days.
 */
global class WalPerfomanceListDeletionScheduler implements Schedulable {
/*
 * Walmart 
 * @author          Mayur Srivastava
 * @version         1.0
 * @date            09/06/2016
 */
    global void execute(SchedulableContext sc) {
        WalPerfomanceListDeletion pl = new WalPerfomanceListDeletion();
        Database.executeBatch(pl, 200);          
   }
}