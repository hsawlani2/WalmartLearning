/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Account_RHIDTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Account_RHIDTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Account_RHID__c());
    }
}