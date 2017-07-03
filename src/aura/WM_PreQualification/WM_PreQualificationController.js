({
	doneRendering : function(component, event, helper) {
		console.log("..PreQualificationleadRecord.. "+component.get("v.PreQualificationleadRecord"));
        
	},
    
	doInit : function(component, event, helper) {
        var inputsel = component.find("InputSelectDynamic");
    	var opts=[];
    	var action = component.get("c.getCountryList");
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            	console.log("countries in controller.. "+JSON.stringify(response.getReturnValue()));
            	opts.push({"class": "optionClass", label: '--Select--', value: '',selected: "true"});
                for(var i=0;i< response.getReturnValue().length;i++){
            		opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
        		}
                component.set("v.countryList", opts);
            }
        });
        $A.enqueueAction(action);
    },
	    
    onChangeCountry : function(component,event) {
    	console.log("..selected country.. "+event.getSource().get('v.value')); 
        var toggleText = component.find("notUnitedStates");
        if(event.getSource().get('v.value') == 'United States'){
            console.log("United states");
			$A.util.removeClass(toggleText, 'slds-visible');
        }else{
            $A.util.addClass(toggleText, 'slds-visible');

        }
	},
    
    startPreSellerSetup : function(component,event,helper){
        console.log('startPreSellerSetup');
		console.log('startPreSellerSetup'+JSON.stringify(component.get("v.tbody")));
		component.set("v.body","");
		console.log('..after null value.. '+JSON.stringify(component.get("v.tbody")));
        var compEvent = $A.get("e.c:WM_NavigationEvent");
        compEvent.setParams({"currentScreen" : component.get("v.currentScreen")});
        compEvent.fire();

		
    },
	
	handleComponentEvent : function(component,event,helper){
		var message = event.getParam("currentScreen");
		console.log("Event Parameter.. "+event.getParam("currentScreen"));
        helper.fetchvalues(component,event,helper);
    
    }
	
})