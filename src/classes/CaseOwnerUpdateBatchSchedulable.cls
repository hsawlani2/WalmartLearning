/**
 * A batch Schedulable that will call the batch to update the Case owner with the Account integration engineer lookup
 * 
 * @createddate 27/07/2016
 */ 
global class CaseOwnerUpdateBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        CaseOwnerUpdateBatch b = new CaseOwnerUpdateBatch(); 
        database.executebatch(b);
    }
}