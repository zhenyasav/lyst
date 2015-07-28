Session.setDefault 'stack', []

Router.route '/',
	name: 'home'
	data: -> Lists.find {}, 
		sort:
			created: -1

Template.home.helpers
	
	fromNow: -> moment(@created).fromNow()

Template.home.events
	'click .delete': -> Lists.remove @_id
	'click .list': -> Router.go '/' + @_id
	'click .add': -> Router.go '/' + Lists.insert
		created: new Date