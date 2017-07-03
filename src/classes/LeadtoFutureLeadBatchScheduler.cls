global class LeadtoFutureLeadBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      LeadtoFutureLeadBatch b = new LeadtoFutureLeadBatch (); 
      database.executebatch(b,8000);
   }
}