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

		# Meteor.setTimeout ->
		# 	$('.page>.list>.caption').focus()
		# , 200

caption = (id, el) ->
	Lists.update id, 
		$set: 
			caption: el?.value ? ''

decaption = _.debounce caption, 300

newItem = (id, element) ->
	ancestor = $(element).parents('.list')?[1]
	data = Blaze.getData ancestor
	Lists.update data._id,
		$push:
			items: Lists.insert
				created: new Date

removeItem = (id, element) ->
	ancestor = Blaze.getData ael = $(element).parents('.list')?[1]
	Lists.remove id
	Lists.update ancestor._id,
		$pull: 
			items: id

	Meteor.setTimeout ->
		$ ael
		.find '.caption'
		.last()
		.focus()
	, 10

indentItem = (id, element) ->
	ancestor = Blaze.getData ael = $(element).parents('.list')?[1]
	index = ancestor?.items?.indexOf? id
	prev = ancestor?.items?[index-1]
	if prev
		Lists.update ancestor._id,
			$pull:
				items: id
		Lists.update prev,
			$push:
				items: id

outdentItem = (id, element) ->
	ancestors = $ element
	.parents '.list'

	parent = Blaze.getData ael = ancestors?[1]
	grandparent = Blaze.getData gpel = ancestors?[2]

	index = grandparent?.items?.indexOf parent._id
	Lists.update grandparent._id,
		$push:
			items:
				$each: [id]
				$position: index+1
	Lists.update parent._id,
		$pull:
			items: id
	Meteor.setTimeout ->
		$('#' + id).find('.caption').first().focus()
	, 100

Template.list.onRendered ->
	$ @firstNode
	.find '.caption'
	.focus()

Template.list.helpers
	
	item: -> Lists.findOne String @

Template.list.events

	'click .bullet': (e) ->
		e.stopPropagation()

		parents = $(e.target).parents '.list'
		parents = _.map parents, (e) -> Blaze.getData e

		if parents.length
			parents = _.pluck parents.slice(1).reverse(), '_id'
			existing = Session.get 'stack'
			Session.set 'stack', (existing ? []).concat parents

		Router.go '/' + @_id

	'change input.caption': (e) ->
		e.stopPropagation()
		Meteor.setTimeout =>
			caption @_id, e.target
		,100

	'keydown input.caption': (e) ->
		e.stopPropagation()

		fn = switch e.keyCode
			when Utils.keys.tab
				e.preventDefault()
				if e.shiftKey
					outdentItem
				else
					indentItem

		fn? @_id, e.target

	'keyup input.caption': (e) ->
		e.stopPropagation()

		fn = switch e.keyCode
			when Utils.keys.enter then newItem
			when Utils.keys.backspace
				removeItem if e.target?.value is ''
			else 
				decaption

		fn? @_id, e.target