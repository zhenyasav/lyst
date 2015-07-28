

Template.body.helpers
	
	item: -> Lists.findOne String @

	pageName: -> Router.current()?.route?.options?.name ? ''