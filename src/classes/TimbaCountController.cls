public class TimbaCountController{

    public  Decimal count_All_Cases{get;set;}
    public  Decimal Count_unresponsive_Cases{get;set;}
    public  Decimal count_Deflected{get;set;}
    public  Decimal count_Non_Deflected{get;set;}
    
    public Decimal allCasesList {get;set;}
    public Decimal deflectedList {get;set;} 
    
  
    public Date sDate { get; set; }
    public Date eDate { get; set; }
    //public String sellerCommunityCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Case').getRecordTypeId();
    public String sellerCommunityClosedCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Closed Case').getRecordTypeId();
   // public String sellerCommunityResolvedCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Resolved Case').getRecordTypeId();
   // public List<Case> allCasesList=new List<Case>();
    //public List<TIMBASURVEYS__Survey_Summary__c > deflectedList = new List <TIMBASURVEYS__Survey_Summary__c >();
   // public List<Case_Initiation__c > deflectedList=new List<Case_Initiation__c >();
        
      DateTime expected = DateTime.newInstanceGMT(2016, 08, 15, 0, 0, 0);
    public boolean show{get;set;}
    
        
    public PageReference PopulateChartData(){
        
    system.debug('sDate ,eDate:'+sDate+','+eDate);
    //Decimal allCasesList;
    //Decimal deflectedList;
        if(sDate != null && eDate != null){
            allCasesList=  [
                SELECT count()
                FROM Case 
                WHERE ClosedDate >=: sDate 
                AND ClosedDate <=: eDate  
                AND RecordType.Name IN ('Seller Community Closed Case')];  

            deflectedList= [
                SELECT count()
                FROM   TIMBASURVEYS__Survey_Summary__c 
                WHERE CreatedDate >=: sDate 
                AND CreatedDate <=: eDate  
                AND TIMBASURVEYS__Complete_Survey_Name__c = 'Case Resolution Satisfaction Survey'];                         
    
        }
        else{
            allCasesList= [
                SELECT count()
                FROM Case 
                WHERE ClosedDate >=: expected
                AND RecordType.Name IN ('Seller Community Closed Case')]; 


            deflectedList= [
                SELECT count()
                FROM   TIMBASURVEYS__Survey_Summary__c 
                WHERE CreatedDate >=: expected
                AND TIMBASURVEYS__Complete_Survey_Name__c = 'Case Resolution Satisfaction Survey'];
        }

              count_Deflected = 0;
              count_All_Cases =0;
            
         if(allCasesList>0){
            count_All_Cases = allCasesList;                       
        }

         if (deflectedList >0){         
                    count_Deflected= deflectedList;
         }
         if(deflectedList >0 && allCasesList >0){
         Count_unresponsive_Cases = count_All_Cases -count_Deflected;
         }
         else{
         Count_unresponsive_Cases =0;
         }
        System.debug('count_All_Cases---'+count_All_Cases);
        System.debug('count_Deflected---'+count_Deflected);

        /*for (Case c :allCasesList ){
          count_All_Cases++;
          system.debug('@developer-->case:'+c.id);
          //system.debug('@developer-->case:'+c.);
        }
        for (TIMBASURVEYS__Survey_Summary__c t :deflectedList ){
          count_Deflected++;
          system.debug('@developer-->timba:'+t.id);
          system.debug('@developer-->timba:'+t.Name); 
          //system.debug('@developer-->case:'+c.);
        }*/
        return null;
    }

    public List<CutsomPieWidget> getPieData() {
       
         List<CutsomPieWidget> dataSet=new List<CutsomPieWidget>();
          Decimal count_nondeflected_percent;
          Decimal count_deflected_Percent;
         if(count_All_Cases!=null)
          count_nondeflected_percent=(Count_unresponsive_Cases /(count_All_Cases))*100.00;
          
         if(count_Deflected!=null)
         count_deflected_Percent=(count_Deflected/(count_All_Cases))*100.00;
         
         dataSet.add(new CutsomPieWidget('Unresponsive', Count_unresponsive_Cases !=null?Count_unresponsive_Cases :0 ,Count_unresponsive_Cases !=null?count_nondeflected_percent.setScale(2):0,'Unresponsive'+' '+String.valueof(Count_unresponsive_Cases !=null?Count_unresponsive_Cases :0 ) +':  '+String.valueof(Count_unresponsive_Cases !=null?count_nondeflected_percent.setScale(2):0)+'%'));
         dataSet.add(new CutsomPieWidget('Response Rate', count_Deflected!=null?count_Deflected:0,count_Deflected!=null?count_deflected_Percent.setScale(2):0,'Response Rate'+' '+String.valueof(count_Deflected!=null?count_Deflected:0 )+':  '+ String.valueof(count_Deflected!=null?count_deflected_Percent.setScale(2):0)+'%'));
         return dataSet;

    }
    
    public void dummyfunction(){
        show=true;
    }

  
    // Wrapper class
    
    public class CutsomPieWidget{
    
        public String name { get; set; }

        public Decimal data { get; set; }
        
        public Decimal data1{get;set;}

         public String name1 { get; set; }
     

        public CutsomPieWidget(String name, Decimal data,Decimal data1,String name1) {

            this.name = name;

            this.data = data;
            
            this.data1= data1;

            this.name1= name1;

        }

    }
    
    }