({
	doInit : function(component, event, helper) {
		console.log("..leadIdss.123456. "+component.get("v.leadId"));
        var action = component.get("c.getLeadDetails");
        action.setParams({ leadRecordId : component.get("v.leadId") });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log("..state. "+state);
            if (state === "SUCCESS") {
            	console.log("success.. "+JSON.stringify(response.getReturnValue()));
                component.set("v.leadRecord",response.getReturnValue());
                console.log("..leadRecord. "+component.get("v.leadRecord"));
            }else{
            	var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
	}
})