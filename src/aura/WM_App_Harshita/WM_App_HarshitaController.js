({
	BuildChildTabDetails : function(component, event) {
		console.log('event handled');
        var context = event.getParam("ActiveParent");
		console.log('Parent details');
        console.log(context);
        console.log('Child tabs');
        console.log(context.ChildTabs);
        component.set("v.Childtabs",context.ChildTabs);
	}
})