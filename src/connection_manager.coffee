class ConnectionManager
	constructor: (@sockets) ->

	onConnection: (callback) ->
		@sockets.on 'connection', (socket) ->
			callback(socket)

	connectedClients: ->
		@sockets.clients()

	send: (client, data) ->

module.exports = ConnectionManager
