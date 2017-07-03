public class OnboardCumulative{
    public static boolean isUpdating=false;
    public static void performCumulativeCalculation(List<Onboard_Forecast__c> OnboardList){
         Set<String> channel=new set<String>();
         for(Onboard_Forecast__c onb:OnboardList){
             if(onb.Integration_Channel__c!=null){
                channel.add(onb.Integration_Channel__c);
             }
         }
         List<Onboard_Forecast__c> onboardListOthers=[
                SELECT  id
                , Name
                ,Integration_Channel__c
                ,Actual__c
                ,Fiscal_Week__c
                ,Week__c
                ,Cumulative_Actual__c
                ,Cumulative_Variance__c
                ,Planned__c
                ,Variance__c
                ,Year__c 
                ,Revised_Forecast__c
                ,Cumulative_Revised_Forecast__c
                FROM Onboard_Forecast__c
                WHERE Id not in :OnboardList
                AND Integration_Channel__c IN :channel
                order by Week__c asc];
        for(Onboard_Forecast__c onb:onboardListOthers){
            System.debug('onb  week, year, Actual,Variance,Forecats are '+onb.Week__c+';'+onb.Year__c+';'+onb.Actual__c +';'+onb.Variance__c+';'+onb.Revised_Forecast__c);

        }        
        Map<Id,List<Onboard_Forecast__c>> mapOnboardOthersList=new Map<Id,List<Onboard_Forecast__c>>();
        Map<Id,List<Onboard_Forecast__c>> mapOnboardOthersBeforeList=new Map<Id,List<Onboard_Forecast__c>>(); 
        
        Map<Id,List<Onboard_Forecast__c>> mapOnboardOthersListPartner=new Map<Id,List<Onboard_Forecast__c>>();
        Map<Id,List<Onboard_Forecast__c>> mapOnboardOthersBeforeListPartner=new Map<Id,List<Onboard_Forecast__c>>();
               
            for(Onboard_Forecast__c onb:OnboardList){
                List<Onboard_Forecast__c> onboardOthersFollowing=new List<Onboard_Forecast__c>();
                List<Onboard_Forecast__c> onboardOthersBefore=new List<Onboard_Forecast__c>();
                for(Onboard_Forecast__c onbOthers:onboardListOthers){
                	if(onb.Integration_Channel__c==onbOthers.Integration_Channel__c){
                    if(onbOthers.Week__c>onb.Week__c && onbOthers.Year__c==onb.Year__c){
                        onboardOthersFollowing.add(onbOthers);
                    }
                    else if(onb.Week__c>onbOthers.Week__c && onbOthers.Year__c==onb.Year__c){
                        onboardOthersBefore.add(onbOthers);
                    }
                	}
                }
                if(onb.Integration_Channel__c=='Direct'){
	                mapOnboardOthersList.put(onb.Id,onboardOthersFollowing);
	                mapOnboardOthersBeforeList.put(onb.Id,onboardOthersBefore);
                }
                else if(onb.Integration_Channel__c=='Partner'){
                	mapOnboardOthersListPartner.put(onb.Id,onboardOthersFollowing);
	                mapOnboardOthersBeforeListPartner.put(onb.Id,onboardOthersBefore);
                }
            }    
       
        List<Onboard_Forecast__c> onboardListToUpdate=new List<Onboard_Forecast__c>();
        set<Id> setAddedId = new set<Id>();
        for(Onboard_Forecast__c onb:OnboardList){
            Onboard_Forecast__c onbOriginal=new Onboard_Forecast__c(id=onb.Id);
            List<Onboard_Forecast__c> onboardOthersFollowing;
            List<Onboard_Forecast__c> onboardOthersBefore;
            if(onb.Integration_Channel__c=='Direct'){
	            onboardOthersFollowing=mapOnboardOthersList.get(onb.Id);
	            onboardOthersBefore=mapOnboardOthersBeforeList.get(onb.Id);
            }
            else{
            	onboardOthersFollowing=mapOnboardOthersListPartner.get(onb.Id);
	            onboardOthersBefore=mapOnboardOthersBeforeListPartner.get(onb.Id);
            }
            Decimal  cumulativeActual=0;
            Decimal  cumulativeVariance=0;
            Decimal  cumulativeRevisedForecast=0;
            if(onb.Week__c==1){
                if(onb.Actual__c!=0 && onb.Actual__c!=null){
                    onbOriginal.Cumulative_Actual__c=onb.Actual__c;
                    cumulativeActual=onb.Actual__c;
                }
                else{
                    onbOriginal.Cumulative_Actual__c=0;
                    cumulativeActual=0;
                }
                
            }
            if(onb.Week__c==1){
                if(onb.Variance__c!=0 && onb.Variance__c!=null){
                    onbOriginal.Cumulative_Variance__c=onb.Variance__c;
                    cumulativeVariance=onb.Variance__c;
                }
                else{
                    onbOriginal.Cumulative_Variance__c=0;
                    cumulativeVariance=0;
                }
                
                
            }
            if(onb.Week__c==1){
                if(onb.Revised_Forecast__c!=0 && onb.Revised_Forecast__c!=null){
                    onbOriginal.Cumulative_Revised_Forecast__c=onb.Revised_Forecast__c;
                    cumulativeRevisedForecast=onb.Revised_Forecast__c;
                }
                else{
                    onbOriginal.Cumulative_Revised_Forecast__c=0;
                    cumulativeRevisedForecast=0;
                }
                
            }

            if(onb.Week__c!=1 && (onb.Actual__c==0||onb.Actual__c==null)){
                cumulativeActual=onb.Cumulative_Actual__c;
            }

            if(onb.Week__c!=1 && (onb.Variance__c==0||onb.Variance__c==null)){
                onbOriginal.Cumulative_Variance__c=cumulativeVariance;
            }
            if(onb.Week__c!=1 && (onb.Revised_Forecast__c==0||onb.Revised_Forecast__c==null)){
                onbOriginal.Cumulative_Revised_Forecast__c=cumulativeRevisedForecast;
            }  

            if(onb.Week__c!=1 && onb.Actual__c!=null && onb.Actual__c!=0 && onboardOthersBefore.isEmpty()){
                onbOriginal.Cumulative_Actual__c=cumulativeActual;
            }


            if(onb.Week__c!=1 && onb.Variance__c!=null && onb.Variance__c!=0 && onboardOthersBefore.isEmpty()){
                cumulativeVariance=onbOriginal.Cumulative_Variance__c=onb.Variance__c;
            } 

            if(onb.Week__c!=1 && onb.Revised_Forecast__c!=null && onb.Revised_Forecast__c!=0 && onboardOthersBefore.isEmpty()){
                cumulativeRevisedForecast=onbOriginal.Cumulative_Revised_Forecast__c=onb.Revised_Forecast__c;
            }         
          

            
            if(!onboardOthersBefore.isEmpty()){
                cumulativeActual=cumulativeVariance=cumulativeRevisedForecast=0;
                for(Integer i=0;i<onboardOthersBefore.size();i++){
                    cumulativeActual+=onboardOthersBefore[i].Actual__c!=null?onboardOthersBefore[i].Actual__c:0;
                    cumulativeVariance+=onboardOthersBefore[i].Variance__c!=null?onboardOthersBefore[i].Variance__c:0;
                    cumulativeRevisedForecast+=onboardOthersBefore[i].Revised_Forecast__c!=null?onboardOthersBefore[i].Revised_Forecast__c:0;
                }
                cumulativeActual=onbOriginal.Cumulative_Actual__c=onb.Actual__c!=null?cumulativeActual+onb.Actual__c:cumulativeActual;
                cumulativeVariance=onbOriginal.Cumulative_Variance__c=onb.Variance__c!=null?cumulativeVariance+onb.Variance__c:cumulativeVariance;
                cumulativeRevisedForecast=onbOriginal.Cumulative_Revised_Forecast__c=onb.Revised_Forecast__c!=null?cumulativeRevisedForecast+onb.Revised_Forecast__c:cumulativeRevisedForecast;
                //onboardListToUpdate.add(onbOriginal);
            }


            if(!onboardOthersFollowing.isEmpty()){
                for(Integer i=0;i<onboardOthersFollowing.size();i++){
                    onboardOthersFollowing[i].Cumulative_Actual__c=onboardOthersFollowing[i].Actual__c!=null && onboardOthersFollowing[i].Actual__c!=0?cumulativeActual+onboardOthersFollowing[i].Actual__c:cumulativeActual;
                    onboardOthersFollowing[i].Cumulative_Variance__c=onboardOthersFollowing[i].Variance__c!=null && onboardOthersFollowing[i].Variance__c!=0 ?cumulativeVariance+onboardOthersFollowing[i].Variance__c:cumulativeVariance;
                    onboardOthersFollowing[i].Cumulative_Revised_Forecast__c=onboardOthersFollowing[i].Revised_Forecast__c!=null && onboardOthersFollowing[i].Revised_Forecast__c!=0 ?cumulativeRevisedForecast+onboardOthersFollowing[i].Revised_Forecast__c:cumulativeRevisedForecast;
                    cumulativeActual=onboardOthersFollowing[i].Cumulative_Actual__c;
                    cumulativeVariance=onboardOthersFollowing[i].Cumulative_Variance__c;
                    cumulativeRevisedForecast=onboardOthersFollowing[i].Cumulative_Revised_Forecast__c;
                    if(!setAddedId.contains(onboardOthersFollowing[i].Id)){
                      onboardListToUpdate.add(onboardOthersFollowing[i]);
                      setAddedId.add(onboardOthersFollowing[i].Id);
                      //system.debug('@developer --> onboardOthersFollowing[i]:'+onboardOthersFollowing[i]);
                    }
                }
                /*if(onboardOthersBefore.isEmpty()){
                    onboardListToUpdate.add(onbOriginal);
                }*/
                
            }
            if(!setAddedId.contains(onbOriginal.Id)){
              onboardListToUpdate.add(onbOriginal);
              system.debug('@developer --> onbOriginal:'+onbOriginal);
              setAddedId.add(onbOriginal.Id);
            }
        }
        
        if(!onboardListToUpdate.isEmpty() && !isUpdating){
                for(Integer i=0;i<onboardListToUpdate.size();i++){
                  system.debug('@developer --> onboardListToUpdate[i]:'+onboardListToUpdate[i]);
                }
          
          
            isUpdating=true;
            update onboardListToUpdate;
        }
    }
 }