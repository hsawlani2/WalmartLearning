/*
    @Author             : Rayson Landeta (CloudSherpas)
    @Date Created       : 6-JAN-2016
    @Description        : Test class for CS_ApplicationTrigger
*/

@isTest
private class CS_ApplicationTriggerTest {
    
    static testMethod void testAfterInsert(){
        Account acc = DataBuilder.createAcc();
        List<Department__c> depList = DataBuilder.createDepartment(1);
        Account_Department__c accdep = DataBuilder.createAccDepartment(acc.Id, depList[0].Id);
        //User usr =  DataBuilder.createUsers();
        Opportunity opp = DataBuilder.createOpp(acc.Id,'DSV',accdep.Id);
        Application__c app = DataBuilder.createApplication(acc.Id, opp.Id);
        test.startTest();
            insert app;
        test.stopTest();
    }
}