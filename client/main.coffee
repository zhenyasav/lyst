Session.setDefault 'stack', []

Router.route '/', ->
	Session.set 'stack', []
	this.redirect '/' + Lists.insert
		created: new Date

Template.body.helpers
	
	item: -> Lists.findOne String @