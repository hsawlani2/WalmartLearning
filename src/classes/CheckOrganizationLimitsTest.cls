@isTest
public class CheckOrganizationLimitsTest{
    public static testmethod void testCheckOrganizationLimits(){
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockCheckOrganizationLimits());
        
        CheckOrganizationLimits.CheckLimits();
    }
}