public class LineChartController {
   // Return a list of data points for a chart
    public static List<Data> dataList{get;set;} 
    public static List<Data> dataList2{get;set;}
    public static List<Data> dataList3{get;set;}
    public static List<Data> getData() {
        return LineChartController.getChartData();
    }
    public static Set<Id> ids=new Set<Id>();

    public static Map<Integer,Integer> mapDirectWeekToActual=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapDirectWeekToPlanned=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapPartnerWeekToActual=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapPartnerWeekToPlanned=new Map<Integer,Integer>();

    public static Map<Integer,Integer> mapDirectWeekToRevisedForecast=new Map<Integer,Integer>();
    public static Map<Integer,Integer> mapPartnerWeekToRevisedForecast=new Map<Integer,Integer>();

    // Make the chart data available via JavaScript remoting
   
    public LineChartController (){
        dataList = new List<Data>();
        dataList2 = new List<Data>();

            List<Onboard_Forecast__c>  ofList = [SELECT Actual__c,Week__c,Planned__c,Revised_Forecast__c,Integration_Channel__c FROM Onboard_Forecast__c Where Year__c = 2016   order by Week__c asc ];
            for(Onboard_Forecast__c of1:ofList){
                if(of1.Integration_Channel__c =='Direct'){

                    ids.add(of1.Id);
                    dataList.add(new Data(Integer.valueOf(of1.Week__c),of1.Actual__c!=null?Integer.valueOf(of1.Actual__c):0,of1.Revised_Forecast__c!=null?Integer.valueOf(of1.Revised_Forecast__c):0,of1.Planned__c!=null?Integer.valueOf(of1.Planned__c):0));
                    if(of1.Actual__c!=null ){
                        mapDirectWeekToActual.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Actual__c));
                    }
                    if(of1.Actual__c==null){
                        mapDirectWeekToActual.put(Integer.valueOf(of1.Week__c),0);
                    }
                    if(of1.Planned__c!=null){
                        mapDirectWeekToPlanned.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Planned__c));
                    }
                    if(of1.Planned__c==null){
                        mapDirectWeekToPlanned.put(Integer.valueOf(of1.Week__c),0);
                    }
                    if(of1.Revised_Forecast__c!=null){
                        mapDirectWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Revised_Forecast__c));
                    }
                    if(of1.Revised_Forecast__c==null){
                        mapDirectWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),0);
                    }
                }
                else if (of1.Integration_Channel__c =='Partner'){
            
                    ids.add(of1.Id);
                    dataList2.add(new Data(Integer.valueOf(of1.Week__c),of1.Actual__c!=null?Integer.valueOf(of1.Actual__c):0,of1.Revised_Forecast__c!=null?Integer.valueOf(of1.Revised_Forecast__c):0,of1.Planned__c!=null?Integer.valueOf(of1.Planned__c):0));
                    if(of1.Actual__c!=null ){
                        mapPartnerWeekToActual.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Actual__c));
                    }
                    if(of1.Actual__c==null){
                        mapPartnerWeekToActual.put(Integer.valueOf(of1.Week__c),0);
                    }
                    if(of1.Planned__c!=null){
                        mapPartnerWeekToPlanned.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Planned__c));
                    }
                    if(of1.Planned__c==null){
                        mapPartnerWeekToPlanned.put(Integer.valueOf(of1.Week__c),0);
                    }  
                    if(of1.Revised_Forecast__c!=null){
                        mapPartnerWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),Integer.valueOf(of1.Revised_Forecast__c));
                    }
                    if(of1.Revised_Forecast__c==null){
                        mapPartnerWeekToRevisedForecast.put(Integer.valueOf(of1.Week__c),0);
                    }
                }
            }

            Integer consolidatedActual=0;
            Integer consolidatedPlanned=0;
            Integer consolidatedRevisedForecast = 0;
            dataList3=new List<Data>();
            Set<Integer> weeksList=new Set<Integer>();
            List<Onboard_Forecast__c>  ofList3 = [SELECT Actual__c,Week__c,Planned__c,Revised_Forecast__c FROM Onboard_Forecast__c where Id in :ids order by Week__c asc];
            for(Onboard_Forecast__c of1:ofList3){
                system.debug('oof1ids'+of1.id);
                /*consolidatedActual=mapDirectWeekToActual.get(Integer.valueOf(of1.Week__c))+mapPartnerWeekToActual.get(Integer.valueOf(of1.Week__c));
                consolidatedPlanned=mapDirectWeekToPlanned.get(Integer.valueOf(of1.Week__c))+mapPartnerWeekToActual.get(Integer.valueOf(of1.Week__c));
                dataList3.add(new Data(Integer.valueOf(of1.Week__c),consolidatedActual,0,consolidatedPlanned));
                system.debug('consolidatedActual'+consolidatedActual);*/
                weeksList.add(Integer.valueOf(of1.Week__c));   
            }

            for(Integer week:weeksList){
                consolidatedActual=mapDirectWeekToActual.get(week)+mapPartnerWeekToActual.get(week);
                consolidatedPlanned=mapDirectWeekToPlanned.get(week)+mapPartnerWeekToPlanned.get(week);
                consolidatedRevisedForecast=mapDirectWeekToRevisedForecast.get(week)+mapPartnerWeekToRevisedForecast.get(week);
                system.debug('consolidatedActual'+consolidatedActual);
                system.debug('consolidatedActual'+consolidatedPlanned);
                system.debug('consolidatedRevisedForecast'+consolidatedRevisedForecast);
                dataList3.add(new Data(week,consolidatedActual,consolidatedRevisedForecast,consolidatedPlanned));
                
            }


    }

    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    public static  List<Data> getChartData() {
           return dataList;
        
    
    }
    public static List<Data> getChartData2(){
        
       return dataList2;



    }

    public static List<Data> getChartData3(){
        
        return dataList3;

    }
    
    public static List<Data> getData2() {
        return LineChartController.getChartData2();
    }
      public static List<Data> getData3() {
        return LineChartController.getChartData3();
    }

    // Wrapper class
    public class Data {
        public Integer name{ get; set; }
        public Integer actual { get; set; }
        public Integer revisedforecast{ get; set; }
        public Integer planned { get; set; }
        public Data(Integer name, Integer actual, Integer revisedforecast, Integer planned) {
            this.name = name;
            this.actual= actual;
            this.revisedforecast= revisedforecast;
            this.planned= planned;
            system.debug('week '+this.name);
            system.debug('actual '+this.actual);
        }
    }
}