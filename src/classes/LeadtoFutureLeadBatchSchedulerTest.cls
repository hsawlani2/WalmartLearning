@isTest

Private class LeadtoFutureLeadBatchSchedulerTest{
          public static String CRON_EXP = '0 0 0 15 5 ? 2021';

         static testMethod void testschedule() {

          Test.StartTest();
          LeadtoFutureLeadBatchScheduler sf = new LeadtoFutureLeadBatchScheduler ();
          
          System.schedule('ScheduleApexClassTest',CRON_EXP,sf);
          Test.stopTest();
          }
}