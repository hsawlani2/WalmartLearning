/***********************************************************
Class Name:WalCreateDeptContactScheduler
Purpose: Schedule the WalCreateDeptContact class
Version 1.0 15th Sept 2016 Draft
/***********************************************************/
global class WalCreateDeptContactScheduler implements Schedulable {
    /** Scheduling the class**/
    global void execute(SchedulableContext sc) {
        WalCreateDeptContact createDeptContact = new WalCreateDeptContact();
        Database.executeBatch(createDeptContact, 50);          
    }
}