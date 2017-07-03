({
	/*
     *  Map to store the components details which needs to be created in every screen of PreQualification step.
     */
    leadData:[],
	
	 
    configMap: {
        "step 1": [{configdef : "ui:outputText", attributes : {"value" : "In which Country is your Company registered?"}}, {configdef : "ui:inputSelect",attributes :{"aura:id":"InputSelectDynamic","change":"component.getReference(onChangeCountry(component,event))"}},{configdef : "ui:outputText", attributes:{"value" : "You will need a Bank Account and a Warehouse presence in the US to be registered as a Supplier.","aura:id":"notUnitedStates","class":"slds-hidden"}}],
		"step 2": [{configdef : "ui:outputText", attributes : {"value" : "Do you have an existing relationship with us? (Select all that applies)"}},{configdef : "c:WM_WalmartPartner",attributes :{}}],
		"step 3": [{configdef : "ui:outputText", attributes : {"value" : "Are you able to ship directly to the customers?"}},{configdef : "ui:inputRadio", attributes :{"name":"shipDirectlyToCustomer","label":"Yes","checked":"true"}},{configdef : "ui:inputRadio", attributes :{"name":"shipDirectlyToCustomer","label":"No"}}],
        "step 4": [{configdef : "ui:outputText", attributes : {"value" : "Do you conduct business with other online retail companies?"}},{configdef : "ui:inputRadio", attributes :{"name":"onlineRetail","label":"Yes","checked":"true"}},{configdef : "ui:inputRadio", attributes :{"name":"onlineRetail","label":"No"}},{configdef : "ui:inputSelect", attributes :{"aura:id":"onlineRetailCompany"}}],
		"step 5": [{configdef : "ui:outputText", attributes : {"value" : "Do you conduct business with other physical retail companies?"}},{configdef : "ui:inputRadio", attributes :{"name":"physicalRetail","label":"Yes","checked":"true"}},{configdef : "ui:inputRadio", attributes :{"name":"physicalRetail","label":"No"}},{configdef : "ui:inputText", attributes :{}}]
	
	},
	
	navigationMap: {
		"home"	:{"next":"step 1","back":"home"},
		"step 1":{"next":"step 2","back":"home"},
		"step 2":{"next":"step 3","back":"step 1"},
		"step 3":{"next":"step 4","back":"step 2"},
		"step 4":{"next":"step 5","back":"step 3"},
	},
    
    fetchvalues:function(component,event,helper){
        console.log("..Map... ");
        console.log(this.configMap["step 1"]);
		console.log("..navigationMap... "+JSON.stringify(this.navigationMap["home"].next));
		console.log("..back step... "+JSON.stringify(this.navigationMap["home"].back));
		console.log("..component.get(v.currentScreen)... "+component.get("v.currentScreen"));
		leadData = component.get("v.PreQualificationleadRecord");
        console.log(leadData.Name);
		var currentScreen = component.get("v.currentScreen");
		
		if(currentScreen == "step 1"){
			//this.configMap[component.get("v.currentScreen")][0].attributes.value = leadData.Name
			this.configMap["step 1"][0].attributes.value = leadData.Name
		}else if(currentScreen == "step 2"){
		
		}else if(currentScreen == "step 3"){
		
		}else if(currentScreen == "step 4"){
		
		}else if(currentScreen == "step 5"){
		
		}else{
			
		}
		
		console.log("home screen.. "+component.find("HomeScreen"));
		var toggleText = component.find("HomeScreen");
		$A.util.toggleClass(toggleText, "toggle")
		
        //console.log(this.configMap["step 1"][0].attributes.value = leadData.Name);
	    var finallistofcomp = [];
        for(var i = 0 ; i< this.configMap["step 1"].length;i++)
        {
            finallistofcomp.push([
                this.configMap["step 1"][i].configdef,
                this.configMap["step 1"][i].attributes
            ]);
        }
		$A.createComponents(
            finallistofcomp,
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
					console.log('inside success');
                    console.log(newButton);
                    component.set("v.tbody", newButton);
                    console.log('end of the function');
				}
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + JSON.stringify(errorMessage));
                    // Show error message
                }
            }
			
        );
		
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
	}
})