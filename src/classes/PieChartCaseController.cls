public class PieChartCaseController{

    public  Decimal count_All{get;set;}
    public  Decimal count_Zira{get;set;}
    public Decimal count_withoutjira{get;set;}
    public Decimal Percantage_withoutjira { get; set; }
    public Decimal Percantage_jira { get; set; }
    public Date sDate { get; set; }
    public Date eDate { get; set; }
    public String sellerCommunityCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Case').getRecordTypeId();
    public String sellerCommunityClosedCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Closed Case').getRecordTypeId();
    public String sellerCommunityResolvedCaseRTId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Seller Community Resolved Case').getRecordTypeId();
    Transient List<Case> allCasesList=new List<Case>();
    public boolean show{get;set;}
    
    public  Integer count_Non_Zira_Item{get;set;}
    public  Integer count_Non_Zira_Inventory{get;set;}
    public  Integer count_Non_Zira_Order{get;set;}
    public  Integer count_Non_Zira_Payment{get;set;}
    public  Integer count_Non_Zira_Reconciliation{get;set;}
    public  Integer count_Non_Zira_Other{get;set;}
    public  Integer count_Non_Zira_Portal{get;set;}
    public  Integer count_Zira_Item{get;set;}
    public  Integer count_Zira_Inventory{get;set;}
    public  Integer count_Zira_Order{get;set;}
    public  Integer count_Zira_Payment{get;set;}
    public  Integer count_Zira_Reconciliation{get;set;}
    public  Integer count_Zira_Other{get;set;}
    public  Integer count_Zira_Portal{get;set;}

    public  Integer count_All_Item{get;set;}
    public  Integer count_All_Inventory{get;set;}
    public  Integer count_All_Order{get;set;}
    public  Integer count_All_Payment{get;set;}
    public  Integer count_All_Reconciliation{get;set;}
    public  Integer count_All_Other{get;set;}
    public  Integer count_All_Portal{get;set;} 
    
    public PageReference PopulateChartData(){
        
    system.debug('sDate ,eDate:'+sDate+','+eDate);
        List<PieWedgeData> data = new List<PieWedgeData>();
        if(sDate != null && eDate != null){
            allCasesList=  [
                SELECT Id,Issue_Category__c,RecordType.Name,(SELECT  Id,zsfjira__CaseId__c,zsfjira__CaseId__r.Issue_Category__c 
                                                              FROM zsfjira__ZIssue_Case__r 
                                                              WHERE CreatedDate >=: sDate 
                                                              AND CreatedDate <=: eDate)
                FROM Case 
                WHERE CreatedDate >=: sDate 
                AND CreatedDate <=: eDate  
                AND RecordType.Name IN ('Seller Community Case','Seller Community Closed Case','Seller Community Resolved Case')
                AND Issue_Category__c IN ('Item','Inventory','Order','Payment','Reconciliation','Other','Portal')];  

        }
        else{
            allCasesList= [
                SELECT Id,Issue_Category__c,RecordType.Name,(SELECT  Id,zsfjira__CaseId__c,zsfjira__CaseId__r.Issue_Category__c 
                                                              FROM zsfjira__ZIssue_Case__r)
                FROM Case
                WHERE RecordType.Name IN ('Seller Community Case','Seller Community Closed Case','Seller Community Resolved Case')
                AND Issue_Category__c IN ('Item','Inventory','Order','Payment','Reconciliation','Other','Portal')];
        }

       /* if(allCasesList.size()>0){
            count_All =0;
            count_Zira=0;
            count_withoutjira =0;
            for(Case c:allCasesList){
                    count_All++;
                   system.debug('count_All :'+count_All );
                   system.debug('CASEID :'+c.id );

                   if(c.zsfjira__ZIssue_Case__r.size()!=0){
                      for(zsfjira__ZIssue_Case__c zIssue:c.zsfjira__ZIssue_Case__r){
                            count_Zira++;  
                        }
                    }
            }
           
            count_withoutjira = count_All -count_Zira ;
           
            Percantage_withoutjira = (count_withoutjira/count_All)*100.00;
            Percantage_jira = (count_Zira/count_All)*100.00;
           
            Percantage_jira = math.round(Percantage_jira);
            Percantage_withoutjira = math.round(Percantage_withoutjira );
            system.debug('count_withoutjira:'+count_withoutjira);
            system.debug('count_Zira  :'+count_Zira );
            system.debug('Percantage_jira  :'+Percantage_jira );
            system.debug('Percantage_withoutjira  :'+Percantage_withoutjira );
        }*/



         if(allCasesList.size()>0){
            count_All =0;
            count_Zira=0;
            count_withoutjira =0;
             count_Non_Zira_Item=0;
             count_Non_Zira_Inventory=0;
             count_Non_Zira_Order=0;
             count_Non_Zira_Payment=0;
             count_Non_Zira_Reconciliation=0;
             count_Non_Zira_Other=0;
             count_Non_Zira_Portal=0;
            
             count_Zira_Item=0;
             count_Zira_Inventory=0;
             count_Zira_Order=0;
             count_Zira_Payment=0;
             count_Zira_Reconciliation=0;
             count_Zira_Other=0;
             count_Zira_Portal=0;
            
             count_All_Item=0;
             count_All_Inventory=0;
             count_All_Order=0;
             count_All_Payment=0;
             count_All_Reconciliation=0;
             count_All_Other=0;
             count_All_Portal=0; 
                
        
           for(Case c:allCasesList){
            count_All ++;
               if(!c.zsfjira__ZIssue_Case__r.isEmpty()){
                 count_Zira++;
                  for(zsfjira__ZIssue_Case__c zIssue:c.zsfjira__ZIssue_Case__r){
                    System.debug('Category is ---'+zIssue.zsfjira__CaseId__r.Issue_Category__c);
                      if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Item')){
                               count_Zira_Item++;
                      }
                           
                     if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Inventory')){
                         count_Zira_Inventory++;
                     }
                     
                     if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Order')){
                         count_Zira_Order++;
                     }
                     
                     if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Payment')){
                         count_Zira_Payment++;
                     }
                     
                     if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Reconciliation')){
                         count_Zira_Reconciliation++;
                     }
                     
                     if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Other')){
                         count_Zira_Other++;
                     }
                     
                     if(zIssue.zsfjira__CaseId__r.Issue_Category__c!=null && zIssue.zsfjira__CaseId__r.Issue_Category__c.equals('Portal')){
                         count_Zira_Portal++;
                     }
                  }
              }

              else{  
                      
                      if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Item')){
                               count_Non_Zira_Item++;
                      }
                           
                     else if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Inventory')){
                         count_Non_Zira_Inventory++;
                     }
                     
                     else if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Order')){
                         count_Non_Zira_Order++;
                     }
                     
                     else if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Payment')){
                         count_Non_Zira_Payment++;
                     }
                     
                     else if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Reconciliation')){
                         count_Non_Zira_Reconciliation++;
                     }
                     
                     else if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Other')){
                         count_Non_Zira_Other++;
                     }
                     
                     else if(c.Issue_Category__c!=null && c.Issue_Category__c.equals('Portal')){
                         count_Non_Zira_Portal++;
                     }                      
              }
            }
               
        }
        count_withoutjira = count_All -count_Zira ;
        count_All_Item=count_Zira_Item+count_Non_Zira_Item;
        count_All_Inventory=count_Zira_Inventory+count_Non_Zira_Inventory;
        count_All_Order=count_Zira_Order+count_Non_Zira_Order;
        count_All_Payment=count_Zira_Payment+count_Non_Zira_Payment;
        count_All_Reconciliation=count_Zira_Reconciliation+count_Non_Zira_Reconciliation;
        count_All_Other=count_Zira_Other+count_Non_Zira_Other;
        count_All_Portal=count_Zira_Portal+count_Non_Zira_Portal;

        System.debug('count_All_Item---'+count_All_Item);
        System.debug('count_All_Inventory---'+count_All_Inventory);
        System.debug('count_All_Order---'+count_All_Order);
        System.debug('count_All_Payment---'+count_All_Payment);
        System.debug('count_All_Reconciliation---'+count_All_Reconciliation);
        System.debug('count_All_Other---'+count_All_Other);
        System.debug('count_All_Portal---'+count_All_Portal);
        System.debug('count_Non_Zira_Item---'+count_Non_Zira_Item);
        System.debug('count_Non_Zira_Inventory---'+count_Non_Zira_Inventory);
        System.debug('count_Non_Zira_Order---'+count_Non_Zira_Order);
        System.debug('count_Non_Zira_Payment---'+count_Non_Zira_Payment);
        System.debug('count_Non_Zira_Reconciliation---'+count_Non_Zira_Reconciliation);
        System.debug('count_Non_Zira_Other---'+count_Non_Zira_Other);
        System.debug('count_Non_Zira_Portal---'+count_Non_Zira_Portal);
        System.debug('count_Zira_Item---'+count_Zira_Item);
        System.debug('count_Zira_Inventory---'+count_Zira_Inventory);
        System.debug('count_Zira_Payment---'+count_Zira_Item);
        System.debug('count_Zira_Reconciliation---'+count_Zira_Reconciliation);
        System.debug('count_Zira_Other---'+count_Zira_Other);
        System.debug('count_Zira_Portal---'+count_Zira_Portal);          
        System.debug('Data Size:'+data.size());
        
        return null;
    }

    public List<CutsomPieWidget> getPieData() {
         //List<PieWedgeData> data = new List<PieWedgeData>();
         List<CutsomPieWidget> dataSet=new List<CutsomPieWidget>();
          Decimal count_withoutjira_percent;
          Decimal count_Zira_Percent;
         if(count_withoutjira!=null)
          count_withoutjira_percent=(count_withoutjira/count_All)*100.00;
         if(count_Zira!=null)
         count_Zira_Percent=(count_Zira/count_All)*100.00;
         dataSet.add(new CutsomPieWidget('RRT Cases', count_withoutjira!=null?count_withoutjira:0 ,count_withoutjira!=null?count_withoutjira_percent.setScale(2):0,'RRT Cases'+'  '+String.valueof(count_withoutjira!=null?count_withoutjira:0)+':  ' + String.valueof(count_withoutjira!=null?count_withoutjira_percent.setScale(2):0)+'%'));
         dataSet.add(new CutsomPieWidget('Deflected to Jira', count_Zira!=null?count_Zira:0,count_Zira!=null?count_Zira_Percent.setScale(2):0,'Deflected to Jira'+'  '+ String.valueof(count_Zira!=null?count_Zira:0)+':  ' + String.valueof(count_Zira!=null?count_Zira_Percent.setScale(2):0)+'%'));
         return dataSet;

    }
    
    public void dummyfunction(){
        show=true;
    }

 public List<CutsomPieWidget> getPieData1() {
     List<PieWedgeData> data = new List<PieWedgeData>();
     Decimal count_Zira_Item_percent=0;
     Decimal count_Zira_Inventory_percent=0;
     Decimal count_Zira_Order_percent=0;
     Decimal count_Zira_Payment_percent=0;
     Decimal count_Zira_Reconciliation_percent=0;
     Decimal count_Zira_Other_percent=0;
     Decimal count_Zira_Portal_percent=0;
     if(count_Zira_Item!=null && (count_Zira!=null && count_Zira!=0)){
         count_Zira_Item_percent=(count_Zira_Item/count_Zira)*100.00;
     }
    if(count_Zira_Inventory!=null && (count_Zira!=null && count_Zira!=0) ){
         count_Zira_Inventory_percent=(count_Zira_Inventory/count_Zira)*100.00;
     }
          if(count_Zira_Order!=null && (count_Zira!=null && count_Zira!=0)){
         count_Zira_Order_percent=(count_Zira_Order/count_Zira)*100.00;
     }
          if(count_Zira_Payment!=null && (count_Zira!=null && count_Zira!=0)){
         count_Zira_Payment_percent=(count_Zira_Payment/count_Zira)*100.00;
     }
          if(count_Zira_Reconciliation!=null && (count_Zira!=null && count_Zira!=0)){
         count_Zira_Reconciliation_percent=(count_Zira_Reconciliation/count_Zira)*100.00;
     }
          if(count_Zira_Other!=null && (count_Zira!=null && count_Zira!=0)){
         count_Zira_Other_percent=(count_Zira_Other/count_Zira)*100.00;
     }
         if(count_Zira_Portal!=null && (count_Zira!=null && count_Zira!=0)){
         count_Zira_Portal_percent=(count_Zira_Portal/count_Zira)*100.00;
     }
      
     List<CutsomPieWidget> dataSet=new List<CutsomPieWidget>();
     dataSet.add(new CutsomPieWidget('Item', count_Zira_Item!=null?count_Zira_Item:0 , count_Zira_Item!=null? count_Zira_Item_percent.setScale(2):0,'Item'+'  '+ String.valueof(count_Zira_Item!=null?count_Zira_Item:0)+':  ' + String.valueof(count_Zira_Item!=null? count_Zira_Item_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Inventory ', count_Zira_Inventory!=null?count_Zira_Inventory:0,count_Zira_Inventory!=null?count_Zira_Inventory_percent.setScale(2):0,'Inventory'+'  '+String.valueof(count_Zira_Inventory!=null?count_Zira_Inventory:0)+':  ' + String.valueof(count_Zira_Inventory!=null?count_Zira_Inventory_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Order', count_Zira_Order!=null?count_Zira_Order:0, count_Zira_Order!=null?count_Zira_Order_percent.setScale(2):0,'Order'+'  '+String.valueof(count_Zira_Order!=null?count_Zira_Order:0)+':  ' + String.valueof(count_Zira_Order!=null?count_Zira_Order_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Payment', count_Zira_Payment!=null?count_Zira_Payment:0, count_Zira_Payment!=null?count_Zira_Payment_percent.setScale(2):0,'Payment'+'  '+ String.valueof(count_Zira_Payment!=null?count_Zira_Payment:0)+':  ' + String.valueof(count_Zira_Payment!=null?count_Zira_Payment_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Reconciliation', count_Zira_Reconciliation!=null?count_Zira_Reconciliation:0, count_Zira_Reconciliation!=null?count_Zira_Reconciliation_percent.setScale(2):0,'Reconciliation'+'  '+ String.valueof(count_Zira_Reconciliation!=null?count_Zira_Reconciliation:0)+':  ' + String.valueof(count_Zira_Reconciliation!=null?count_Zira_Reconciliation_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Other', count_Zira_Other!=null?count_Zira_Other:0 ,count_Zira_Other!=null?count_Zira_Other_percent.setScale(2):0,'Other'+'  '+String.valueof(count_Zira_Other!=null?count_Zira_Other:0)+':  ' + String.valueof(count_Zira_Other!=null?count_Zira_Other_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Portal', count_Zira_Portal!=null?count_Zira_Portal:0, count_Zira_Portal !=null?count_Zira_Portal_percent.setScale(2):0,'Portal'+'  '+String.valueof(count_Zira_Portal!=null?count_Zira_Portal:0)+':  ' + String.valueof(count_Zira_Portal !=null?count_Zira_Portal_percent.setScale(2):0)+'%' ));
     return dataSet;
 }
 
  public List<CutsomPieWidget> getPieData2() {
    List<CutsomPieWidget> data = new List<CutsomPieWidget>();
     Decimal count_Non_Zira_Item_percent=0;
     Decimal count_Non_Zira_Inventory_percent=0;
     Decimal count_Non_Zira_Order_percent=0;
     Decimal count_Non_Zira_Payment_percent=0;
     Decimal count_Non_Zira_Reconciliation_percent=0;
     Decimal count_Non_Zira_Other_percent=0;
     Decimal count_Non_Zira_Portal_percent=0;
     if(count_Non_Zira_Item!=null && (count_withoutjira!=null && count_withoutjira!=0)){
         count_Non_Zira_Item_percent=(count_Non_Zira_Item/count_withoutjira)*100.00;
     }
    if(count_Non_Zira_Inventory!=null && (count_withoutjira!=null && count_withoutjira!=0) ){
         count_Non_Zira_Inventory_percent=(count_Non_Zira_Inventory/count_withoutjira)*100.00;
     }
          if(count_Non_Zira_Order!=null && (count_withoutjira!=null && count_withoutjira!=0)){
         count_Non_Zira_Order_percent=(count_Non_Zira_Order/count_withoutjira)*100.00;
     }
          if(count_Non_Zira_Payment!=null && (count_withoutjira!=null && count_withoutjira!=0)){
         count_Non_Zira_Payment_percent=(count_Non_Zira_Payment/count_withoutjira)*100.00;
     }
          if(count_Non_Zira_Reconciliation!=null && (count_withoutjira!=null && count_withoutjira!=0)){
         count_Non_Zira_Reconciliation_percent=(count_Non_Zira_Reconciliation/count_withoutjira)*100.00;
     }
          if(count_Non_Zira_Other!=null && (count_withoutjira!=null && count_withoutjira!=0)){
         count_Non_Zira_Other_percent=(count_Non_Zira_Other/count_withoutjira)*100.00;
     }
         if(count_Non_Zira_Portal!=null && (count_withoutjira!=null && count_withoutjira!=0)){
         count_Non_Zira_Portal_percent=(count_Non_Zira_Portal/count_withoutjira)*100.00;
     }
      
     List<CutsomPieWidget> dataSet=new List<CutsomPieWidget>();
     dataSet.add(new CutsomPieWidget('Item', count_Non_Zira_Item!=null?count_Non_Zira_Item:0 , count_Non_Zira_Item!=null? count_Non_Zira_Item_percent.setScale(2):0,'Item'+'  '+  String.valueof(count_Non_Zira_Item!=null?count_Non_Zira_Item:0)+':  ' + String.valueof(count_Non_Zira_Item!=null? count_Non_Zira_Item_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Inventory', count_Non_Zira_Inventory!=null?count_Non_Zira_Inventory:0,count_Non_Zira_Inventory!=null?count_Non_Zira_Inventory_percent.setScale(2):0,'Inventory'+'  '+ String.valueof( count_Non_Zira_Inventory!=null?count_Non_Zira_Inventory:0)+':  ' + String.valueof(count_Non_Zira_Inventory!=null?count_Non_Zira_Inventory_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Order', count_Non_Zira_Order!=null?count_Non_Zira_Order:0, count_Non_Zira_Order!=null?count_Non_Zira_Order_percent.setScale(2):0,'Order'+'  '+ String.valueof(count_Non_Zira_Order!=null?count_Non_Zira_Order:0)+':  ' + String.valueof(count_Non_Zira_Order!=null?count_Non_Zira_Order_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Payment', count_Non_Zira_Payment!=null?count_Non_Zira_Payment:0, count_Non_Zira_Payment!=null?count_Non_Zira_Payment_percent.setScale(2):0,'Payment'+'  '+ String.valueof(count_Non_Zira_Payment!=null?count_Non_Zira_Payment:0)+':  ' + String.valueof(count_Non_Zira_Payment!=null?count_Non_Zira_Payment_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Reconciliation', count_Non_Zira_Reconciliation!=null?count_Non_Zira_Reconciliation:0, count_Non_Zira_Reconciliation!=null?count_Non_Zira_Reconciliation_percent.setScale(2):0,'Reconciliation'+'  '+ String.valueof(count_Non_Zira_Reconciliation!=null?count_Non_Zira_Reconciliation:0)+':  ' + String.valueof(count_Non_Zira_Reconciliation!=null?count_Non_Zira_Reconciliation_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Other', count_Non_Zira_Other!=null?count_Non_Zira_Other:0 ,count_Non_Zira_Other!=null?count_Non_Zira_Other_percent.setScale(2):0,'Other'+'  '+ String.valueof(count_Non_Zira_Other!=null?count_Non_Zira_Other:0 )+':  ' + String.valueof(count_Non_Zira_Other!=null?count_Non_Zira_Other_percent.setScale(2):0)+'%'));
     dataSet.add(new CutsomPieWidget('Portal', count_Non_Zira_Portal!=null?count_Non_Zira_Portal:0, count_Non_Zira_Portal !=null?count_Non_Zira_Portal_percent.setScale(2):0,'Portal'+'  '+ String.valueof( count_Non_Zira_Portal!=null?count_Non_Zira_Portal:0)+':  ' + String.valueof(count_Non_Zira_Portal !=null?count_Non_Zira_Portal_percent.setScale(2):0)+'%' ));
     return dataSet;
 }

    // Wrapper class
    public class PieWedgeData {

 

        public String name { get; set; }

        public Decimal data { get; set; }

 

        public PieWedgeData(String name, Decimal data) {

            this.name = name;

            this.data = data;

        }

    }
    
    public class CutsomPieWidget{
    
        public String name { get; set; }

        public Decimal data { get; set; }
        
        public Decimal data1{get;set;}

        public String name1 { get; set; }

        public CutsomPieWidget(String name, Decimal data,Decimal data1 , String name1 ) {

            this.name = name;

            this.data = data;
            
            this.data1=data1;

            this.name1 = name1;

        }

    }
    
    }