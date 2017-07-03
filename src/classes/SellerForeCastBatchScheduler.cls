global class SellerForeCastBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      SellerForeCastBatchchange_New b = new SellerForeCastBatchchange_New (); 
      database.executebatch(b,8000);
   }
}