({
	doInit : function(component, event, helper) {
		var action = component.get("c.getProgressStages");
		var self = this;
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
        	var stringItems = response.getReturnValue();
            console.log(stringItems[0].isActive = true);
            console.log(stringItems[0].isActive);
        	component.set("v.RoadmapSteps", stringItems);
            console.log(stringItems.length);
            for(var i= 0;i< stringItems.length;i++)
            {
                console.log(stringItems[0]);
                if(stringItems[i].isActive == true)
                {
                    //var compEvents = component.getEvent("Displaychildtabs");
                    var compEvents = $A.get("e.c:WM_ProgressBarToChildTab");
                    compEvents.setParams({ "ActiveParent" : stringItems[i] });
                    console.log('event yet to fire');
                    compEvents.fire();
                    console.log('event fired');
                    break;
                }
            }
        }
        });
        $A.enqueueAction(action);
	}
})