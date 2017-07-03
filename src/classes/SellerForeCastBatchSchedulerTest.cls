@isTest

Private class SellerForeCastBatchSchedulerTest{
          public static String CRON_EXP = '0 0 0 15 5 ? 2021';

         static testMethod void testschedule() {

          Test.StartTest();
          SellerForeCastBatchScheduler sf = new SellerForeCastBatchScheduler ();
          
          System.schedule('ScheduleApexClassTest',CRON_EXP,sf);
          Test.stopTest();
          }
}