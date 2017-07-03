/*
 * Walmart 
 * @author          Narendra Singh
 * @version         1.0
 * @date            13/12/2016
 * @description     Scheduler class to run PerformanceSnapshot batch class.
 */
global class PerformanceSnapshotSchedular implements Schedulable {
/*
 * Walmart 
 * @author          Narendra Singh
 * @version         1.0
 * @date            13/12/2016
 */
    global void execute(SchedulableContext sc) {
        PerformanceSnapshot pl = new PerformanceSnapshot();
        Database.executeBatch(pl);          
   }
}