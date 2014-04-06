class ConnectionManager
	constructor: (@sockets) ->

	on_connection: ->
		@sockets.on 'connection', (socket) ->
			callback(socket)

	connected_clients: ->
		@sockets.clients()

module.exports = ConnectionManager
