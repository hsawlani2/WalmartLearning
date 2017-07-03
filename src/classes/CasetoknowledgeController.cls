public class CasetoknowledgeController{

   public  Decimal count_All_Cases{get;set;}
    public  Decimal count_Deflected{get;set;}
    public  Decimal count_Non_Deflected{get;set;}
    
 
    public Date sDate { get; set; }
    public Date eDate { get; set; }
    public String sellerCommunityCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Case').getRecordTypeId();
    public String sellerCommunityClosedCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Closed Case').getRecordTypeId();
    public String sellerCommunityResolvedCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Resolved Case').getRecordTypeId();
   // public List<Case> allCasesList=new List<Case>();
   // public List<Case_Initiation__c > deflectedList=new List<Case_Initiation__c >();
    
    public boolean show{get;set;}
    
        
    public PageReference PopulateChartData(){
        
    system.debug('sDate ,eDate:'+sDate+','+eDate);
    Decimal allCasesList;
    Decimal deflectedList;
        if(sDate != null && eDate != null){
            allCasesList=  [
                SELECT count()
                FROM Case 
                WHERE CreatedDate >=: sDate 
                AND CreatedDate <=: eDate  
                AND RecordType.Name IN ('Seller Community Case','Seller Community Closed Case','Seller Community Resolved Case')];  

            deflectedList= [
                SELECT count()
                FROM   Case_Initiation__c 
                WHERE CreatedDate >=: sDate 
                AND CreatedDate <=: eDate  
                AND Case_Type__c = 'Operations Case' AND Deflected__c = True];                         
    
        }
        else{
            allCasesList= [
                SELECT count()
                FROM Case 
                WHERE RecordType.Name IN ('Seller Community Case','Seller Community Closed Case','Seller Community Resolved Case')]; 


            deflectedList= [
                SELECT count()
                FROM   Case_Initiation__c 
                WHERE Case_Type__c = 'Operations Case' AND Deflected__c = True]; 
        }

              count_Deflected = 0;
              count_All_Cases =0;
            
         if(allCasesList>0){
            count_All_Cases = allCasesList;                       
        }

         if (deflectedList >0){         
                    count_Deflected= deflectedList;
         }
        System.debug('count_All_Cases---'+count_All_Cases);
        System.debug('count_Deflected---'+count_Deflected);
        
        return null;
    }

    public List<CutsomPieWidget> getPieData() {
       
         List<CutsomPieWidget> dataSet=new List<CutsomPieWidget>();
          Decimal count_nondeflected_percent;
          Decimal count_deflected_Percent;
         if(count_All_Cases!=null)
          count_nondeflected_percent=(count_All_Cases/(count_All_Cases+count_Deflected))*100.00;
          
         if(count_Deflected!=null)
         count_deflected_Percent=(count_Deflected/(count_All_Cases+count_Deflected))*100.00;
         
         dataSet.add(new CutsomPieWidget('NonDeflected', count_All_Cases!=null?count_All_Cases:0 ,count_All_Cases!=null?count_nondeflected_percent.setScale(2):0,'NonDeflected'+' '+String.valueof(count_All_Cases!=null?count_All_Cases:0 ) +':  '+String.valueof(count_All_Cases!=null?count_nondeflected_percent.setScale(2):0)+'%'));
         dataSet.add(new CutsomPieWidget('Deflected', count_Deflected!=null?count_Deflected:0,count_Deflected!=null?count_deflected_Percent.setScale(2):0,'Deflected'+' '+String.valueof(count_Deflected!=null?count_Deflected:0 )+':  '+ String.valueof(count_Deflected!=null?count_deflected_Percent.setScale(2):0)+'%'));
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