class ConnectionManager
	constructor: (@sockets) ->

	onConnection: (callback) ->
		@sockets.on 'connection', (socket) ->
			callback(socket)

	connectedClients: ->
		@sockets.clients()

module.exports = ConnectionManager
