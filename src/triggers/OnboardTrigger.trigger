trigger OnboardTrigger on Onboard_Forecast__c (after update,before update) {

         if(trigger.isBefore){
                
                //OnboardCumulative.getCumulative(trigger.new);
                
            }
        if(trigger.isAfter){
            
            OnboardCumulative.performCumulativeCalculation(trigger.new);
        }    
    


}