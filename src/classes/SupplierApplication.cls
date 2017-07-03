public class SupplierApplication{
    
    @AuraEnabled
    public static Lead getLeadDetails(string leadRecordId){
        system.debug('..leadRecord Id.. '+leadRecordId);
        Lead leadObj = [SELECT Id,Name,Country from Lead where Id=:leadRecordId];
        return leadObj;
    }
    
    @AuraEnabled
    public static List<String> getCountryList(){
    
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            System.debug(f.getLabel() +'::'+ f.getValue());
            options.add(f.getLabel());
        }
        system.debug('..Countriess..'+options);
        return options;  
    }
    
    @AuraEnabled
    public static List<String> getPartnerList(){
        List<String> options = new List<String>();
        List<Attachment> attchList = [SELECT Id,Name from Attachment where ParentId='00Q5B000002OC1g'];
        for(Attachment att : attchList){
            options.add(att.Id);
        }
        system.debug('..partners..'+options);
        return options;
    }
    
    /******* method for getting Parent and Child tabs from te custom setting *******/
    @AuraEnabled
    public static List<smartApp_Wrapper.progressBar> getProgressStages(){
        map<String,List<WM_Smart_App_ProgressBar__c>> primarychildtab = new map<String,List<WM_Smart_App_ProgressBar__c>>();
        for(WM_Smart_App_ProgressBar__c childtab : [Select name,Primarytab_Sequence__c,Parent_Tab__c,Sequence__c from WM_Smart_App_ProgressBar__c Order By Primarytab_Sequence__c,Sequence__c ASC])
        {
            System.debug('Primary Tab ' + childtab.Parent_Tab__c);
            List<WM_Smart_App_ProgressBar__c> templist = new List<WM_Smart_App_ProgressBar__c>();
            if(primarychildtab.containskey(childtab.Parent_Tab__c))
            {
                templist = primarychildtab.get(childtab.Parent_Tab__c);
            }
            templist.add(childtab);
            primarychildtab.put(childtab.Parent_Tab__c,templist);
        }
        system.debug('Final List ' + primarychildtab);
        //Arranging the child tabs
        List<smartApp_Wrapper.progressBar> progressbarstages = new List<smartApp_Wrapper.progressBar>();
        for(String prmytab : primarychildtab.keyset()){
            smartApp_Wrapper.progressBar temprec = new smartApp_Wrapper.progressBar(prmytab,primarychildtab.get(prmytab),false,false,true,Integer.ValueOf(primarychildtab.get(prmytab)[0].Primarytab_Sequence__c));
            progressbarstages.add(temprec);
        }
        progressbarstages.sort();
        system.debug('Final list ' + progressbarstages);
        return progressbarstages;
    }
    
    /********* method for getting the fields from the field set corresponding to the Active Parent ************/
    @AuraEnabled
    public static List<smartApp_Wrapper.fieldDisplay> getFieldMEmebers(String FieldsetAPIName){
        Map<String,Decimal> fieldwithindex = new Map<String,Decimal>{'et4ae5__Mobile_Country_Code__c'=>4.1,'Phone'=>4.2,'Extension__c'=>4.3,'MobilePhone' => 5.1};
        // Describe Calls to get the fieldset description
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Lead');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));
        Schema.FieldSet fs = DescribeSObjectResultObj.FieldSets.getMap().get(FieldsetAPIName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<smartApp_Wrapper.FieldSetMember> fset = new List<smartApp_Wrapper.FieldSetMember>();
        Decimal count = 1.0;
        List<smartApp_Wrapper.fieldDisplay> fetdetaillst = new List<smartApp_Wrapper.fieldDisplay>();
        List<Schema.FieldSetMember> fieldlstforsinglerow = new List<Schema.FieldSetMember>();
        Map<String,Schema.FieldSetMember> fieldAPI = new MAp<String,Schema.FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
            fieldAPI.put(f.fieldPath,f);
            fset.add(new smartApp_Wrapper.FieldSetMember(f));
            smartApp_Wrapper.fieldDisplay temprec = new smartApp_Wrapper.fieldDisplay();
            if( f.fieldPath != 'et4ae5__Mobile_Country_Code__c' && f.fieldPath != 'Phone' && f.fieldPath != 'Extension__c' && f.fieldPath != 'MobilePhone')
            {
                temprec.index = count;
                smartApp_Wrapper.FieldSetMember temrecfield = new smartApp_Wrapper.FieldSetMember(f);
                temrecfield.Classtype = '';
                if(f.fieldPath == 'Title')
                    temrecfield.Classtype = 'slds-size--6-of-12';
                temprec.fieldsdisplay.add(temrecfield);
                count ++;
                fetdetaillst.add(temprec);
            }else{
                fieldlstforsinglerow.add(f);
            }
        }
        // new logic 
        smartApp_Wrapper.fieldDisplay temprecinline = new smartApp_Wrapper.fieldDisplay();
        Integer Countnxt = 4;
        for(String str : fieldwithindex.keyset())
        {
            smartApp_Wrapper.FieldSetMember temrecfield = new smartApp_Wrapper.FieldSetMember(fieldAPI.get(str));
            if(fieldwithindex.get(str) < (Countnxt+1))
            {
                temprecinline.index = fieldwithindex.get(temrecfield.APIName);
                temrecfield.Classtype = 'slds-size--3-of-12';
                temprecinline.fieldsdisplay.add(temrecfield);
                //fetdetaillst.add(temprec);
            }else{
                fetdetaillst.add(temprecinline);
                temprecinline = new smartApp_Wrapper.fieldDisplay();
                Countnxt++;
            }
        }
        fetdetaillst.add(temprecinline);
        //return fset;
        return fetdetaillst;
    }
}