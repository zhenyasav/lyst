Router.route '/:id',
	controller: DefaultController
	name: 'list'
	data: -> Lists.findOne @params.id
	onAfterAction: ->
		Tracker.nonreactive =>
			stack = Session.get 'stack'
			index = stack.indexOf @params.id
			if index >= 0
				if index <= stack.length - 1
					stack.splice index, stack.length - index
					Session.set 'stack', stack

		Meteor.setTimeout ->
			$('.page>.list>.caption').focus()
		, 200

caption = (id, el) ->
	Lists.update id, 
		$set: 
			caption: el?.value ? ''

decaption = _.debounce caption, 300

newItem = (id) ->
	Lists.update id,
		$push:
			items: Lists.insert
				created: new Date

Template.list.helpers
	
	item: -> Lists.findOne String @

Template.list.events

	'click .bullet': (e) ->
		e.stopPropagation()

		parents = $(e.target).parents '.list'
		parents = _.map parents, (e) -> Blaze.getData e

		if parents.length
			parents = _.pluck parents.slice(1).reverse(), '_id'
			Session.set 'stack', parents

		Router.go '/' + @_id

	'change input.caption': (e) ->
		e.stopPropagation()
		Meteor.setTimeout =>
			caption @_id, e.target
		,10

	'keyup input.caption': (e) ->
		e.stopPropagation()

		if e.keyCode is Utils.keys.enter
			newItem @_id
		else
			decaption @_id, e.target