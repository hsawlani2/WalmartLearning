({
	/****** Event handler method that will display the tabs reated to the active parent step ****/
    BuildChildTabDetails : function(component, event,helper) {
		console.log('event handled');
        var context = event.getParam("ActiveParent");
		console.log('Parent details');
        console.log(context);
        console.log('Child tabs');
        console.log(context.ChildTabs);
        component.set("v.Childtabs",context.ChildTabs);
        component.set("v.ActiveChildTab",context.ChildTabs[0]);
        //helper.FetchTabDetails(component,event,helper);
	},

})