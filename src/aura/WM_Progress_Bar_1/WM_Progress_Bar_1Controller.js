({
	doInit : function(component, event, helper) {
		var action = component.get("c.getProgressStages");
		var self = this;
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
        	var stringItems = response.getReturnValue();
        	component.set("v.RoadmapSteps", stringItems);
        }
        });
        $A.enqueueAction(action);
	}
})