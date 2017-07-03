global class UpdateEngineerMappingBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateEngineerMappingBatch b = new UpdateEngineerMappingBatch (); 
        database.executebatch(b);
    }
}