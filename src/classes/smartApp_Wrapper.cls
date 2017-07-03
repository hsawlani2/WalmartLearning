/**** This class has all the wrapper class structure that is being used in the lightning app ****/
public class smartApp_Wrapper{

    /****** wrapper class for building the Parent Child Relationship of the tabs *****/
    public class progressBar implements Comparable{
        @AuraEnabled
        public String PrimaryTab{get;set;}
        
        @AuraEnabled
        public List<String> ChildTabs{get;set;}
        
        @AuraEnabled
        public Boolean isCompleted{get;set;}
        
        @AuraEnabled
        public Boolean isActive{get;set;}
        
        @AuraEnabled
        public Boolean notstarted{get;set;} 
        
        @AuraEnabled 
        public Integer Tabsequence{get;set;}
        
        public progressBar(String Prmytab, List<WM_Smart_App_ProgressBar__c> chldtab, Boolean isComp, Boolean isAct, Boolean notstrt,Integer sequence){
            ChildTabs= new List<String>();
            for(WM_Smart_App_ProgressBar__c temprec :chldtab)
            {
                ChildTabs.add(temprec.Name);
            }
            this.PrimaryTab = Prmytab;
            this.isCompleted = isComp;
            this.isActive = isAct;
            this.notstarted = notstrt;
            this.Tabsequence = sequence;
            
        } 
        
        public Integer compareTo(Object compareTo) 
        {
            progressBar jobsWrapper = (progressBar) compareTo;
            if (Tabsequence == jobsWrapper.Tabsequence) return 0;
            if (Tabsequence > jobsWrapper.Tabsequence) return 1;
            return -1;        
        }
    }
    
    /********* Wrapper class for the fields set from backend *****/
    public class FieldSetMember{
        @AuraEnabled
        public String APIName{get;set;}
        @AuraEnabled
        public String FieldLabel{get;set;}
        @AuraEnabled
        public Boolean FieldRequired{get;set;}
        @AuraEnabled
        public Boolean FieldDBRequired{get;set;}
        @AuraEnabled
        public String FieldType{get;set;}
        @AuraEnabled
        public String HTMLchar{get;set;}
        @AuraEnabled
        public String Classtype{get;set;}
        
        
        public FieldSetMember(Schema.FieldSetMember fb){
            this.APIName = fb.fieldPath;
            this.FieldLabel = fb.label;
            this.FieldRequired = fb.required;
            this.FieldDBRequired = fb.DBRequired;
            this.FieldType = '' + fb.getType();
        }
        
        public FieldSetMember(){
            this.APIName = '';
            this.FieldLabel = '';
            this.FieldRequired = false;
            this.FieldDBRequired = false;
            this.FieldType = '';
        }
    }
    
    /*************** Wrapper class for the form to display all the fields ********/
    public class fieldDisplay{
        @AuraEnabled
        public List<smartApp_Wrapper.FieldSetMember> fieldsdisplay{get;set;}
        @AuraEnabled
        public Decimal index{get;set;}

        public fieldDisplay(){
            fieldsdisplay = new List<smartApp_Wrapper.FieldSetMember>();
        }
    }
}