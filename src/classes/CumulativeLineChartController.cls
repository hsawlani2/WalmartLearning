public class CumulativeLineChartController {
   // Return a list of data points for a chart
    public static List<Data> dataList{get;set;} 
    public static List<Data> dataList2{get;set;}
    public static List<Data> dataList3{get;set;}
  
    public static Set<Id> ids=new Set<Id>();

    public static Map<Integer,Integer> mapDirectWeekToActual=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapDirectWeekToVariance=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapPartnerWeekToActual=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapPartnerWeekToVariance=new Map<Integer,Integer>();

    public static Map<Integer,Integer> mapDirectWeekToRevisedForecast=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapPartnerWeekToRevisedForecast=new Map<Integer,Integer>();

    // Make the chart data available via JavaScript remoting
   
    public CumulativeLineChartController (){
        dataList = new List<Data>();
        dataList2 = new List<Data>();

            List<Onboard_Forecast__c>  ofList = [SELECT Cumulative_Actual__c,Week__c,Cumulative_Revised_Forecast__c,Cumulative_Variance__c,Integration_Channel__c FROM Onboard_Forecast__c Where Year__c = 2016   order by Week__c asc ];
            for(Onboard_Forecast__c of1:ofList){
                if(of1.Integration_Channel__c =='Direct'){

                    ids.add(of1.Id);
                    dataList.add(new Data(Integer.valueOf(of1.Week__c),of1.Cumulative_Actual__c!=null?Integer.valueOf(of1.Cumulative_Actual__c):0,of1.Cumulative_Revised_Forecast__c!=null?Integer.valueOf(of1.Cumulative_Revised_Forecast__c):0,of1.Cumulative_Variance__c!=null?Integer.valueOf(of1.Cumulative_Variance__c):0));
                    system.debug('dataList:' +dataList);
                    if(of1.Cumulative_Actual__c!=null ){
                        mapDirectWeekToActual.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Cumulative_Actual__c));
                    }
                    if(of1.Cumulative_Actual__c==null){
                        mapDirectWeekToActual.put(Integer.valueOf(of1.Week__c),0);
                    }
                    if(of1.Cumulative_Revised_Forecast__c!=null){
                        mapDirectWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Cumulative_Revised_Forecast__c));
                    }
                    if(of1.Cumulative_Revised_Forecast__c==null){
                        mapDirectWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),0);
                    }
                    if(of1.Cumulative_Variance__c!=null){
                        mapDirectWeekToVariance.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Cumulative_Variance__c));
                    }
                    if(of1.Cumulative_Variance__c==null){
                        mapDirectWeekToVariance.put(Integer.valueOf(of1.Week__c),0);
                    }
                }
                else if (of1.Integration_Channel__c =='Partner'){
            
                    ids.add(of1.Id);
                    dataList2.add(new Data(Integer.valueOf(of1.Week__c),of1.Cumulative_Actual__c!=null?Integer.valueOf(of1.Cumulative_Actual__c):0,of1.Cumulative_Revised_Forecast__c!=null?Integer.valueOf(of1.Cumulative_Revised_Forecast__c):0,of1.Cumulative_Variance__c!=null?Integer.valueOf(of1.Cumulative_Variance__c):0));
                     system.debug('dataList2:' +dataList2);
                    if(of1.Cumulative_Actual__c!=null ){
                        mapPartnerWeekToActual.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Cumulative_Actual__c));
                    }
                    if(of1.Cumulative_Actual__c==null){
                        mapPartnerWeekToActual.put(Integer.valueOf(of1.Week__c),0);
                    }
                    if(of1.Cumulative_Revised_Forecast__c!=null){
                        mapPartnerWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Cumulative_Revised_Forecast__c));
                    }
                    if(of1.Cumulative_Revised_Forecast__c==null){
                        mapPartnerWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),0);
                    }  
                    if(of1.Cumulative_Variance__c!=null){
                        mapPartnerWeekToVariance.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Cumulative_Variance__c));
                    }
                    if(of1.Cumulative_Variance__c==null){
                        mapPartnerWeekToVariance.put(Integer.valueOf(of1.Week__c),0);
                    }
                }
            }

            Integer consolidatedActual=0;
            Integer consolidatedVariance=0;
            Integer consolidatedRevisedForecast = 0;
            dataList3=new List<Data>();
            Set<Integer> weeksList=new Set<Integer>();
            List<Onboard_Forecast__c>  ofList3 = [SELECT Cumulative_Actual__c,Week__c,Cumulative_Variance__c,Cumulative_Revised_Forecast__c FROM Onboard_Forecast__c where Id in :ids order by Week__c asc];
            for(Onboard_Forecast__c of1:ofList3){
                system.debug('oof1ids'+of1.id);
               
                weeksList.add(Integer.valueOf(of1.Week__c)); 
                system.debug('weeksList:'+weeksList);  
            }

            for(Integer week:weeksList){
                consolidatedActual=mapDirectWeekToActual.get(week)+mapPartnerWeekToActual.get(week);
                consolidatedVariance=mapDirectWeekToVariance.get(week)+mapPartnerWeekToVariance.get(week);
                consolidatedRevisedForecast=mapDirectWeekToRevisedForecast.get(week)+mapPartnerWeekToRevisedForecast.get(week);
                system.debug('consolidatedActual'+consolidatedActual);
                system.debug('consolidatedActual'+consolidatedVariance);
                system.debug('consolidatedRevisedForecast'+consolidatedRevisedForecast);
               // dataList3.add(new Data(week,consolidatedActual,consolidatedRevisedForecast,consolidatedVariance));
                dataList3.add(new Data(week,consolidatedActual !=null?consolidatedActual:0,consolidatedRevisedForecast!=null?consolidatedRevisedForecast:0,consolidatedVariance!=null?consolidatedVariance:0));

                
            }
    

    }
    
    public static  List<Data> getChartData() {
           return dataList;        
    
    }
    public static List<Data> getChartData2(){
        
       return dataList2;

    }
      public static List<Data> getChartData3(){
        
       return dataList3;

    }
    
  public static List<Data> getData() {
        return CumulativeLineChartController.getChartData();
    }
   


    // Wrapper class
    public class Data {
        public Integer name{ get; set; }
        public Integer actual { get; set; }
        public Integer revisedforecast{ get; set; }
        public Integer variance { get; set; }
        public Data(Integer name, Integer actual, Integer revisedforecast, Integer variance ) {
            this.name = name;
            this.actual= actual;
            this.revisedforecast= revisedforecast;
            this.variance = variance ;
            system.debug('week '+this.name);
            system.debug('actual '+this.actual);
        }
    }
}