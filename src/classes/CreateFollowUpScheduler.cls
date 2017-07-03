global class CreateFollowUpScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new CreateEmailFollowUp_Batch());
    }

}