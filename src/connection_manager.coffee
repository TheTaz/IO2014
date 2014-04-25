class ConnectionManager
	constructor: (@sockets) ->

	onPeerConnected: (callback) ->
		@sockets.on 'connection', (socket) ->
			callback(socket)

	onPeerDisconnected: (callback) ->
		@sockets.on 'disconnect', (socket) ->
			callback(socket)

	onCodeLoaded: (callback) ->
		@sockets.on 'code_loaded', (socket, message) ->
			callback(socket, message)

	onResultReady: (callback) ->
		@sockets.on 'result_ready', (socket, message) ->
			callback(socket, message)

	getActiveConnections: ->
		return @sockets.clients()

module.exports = ConnectionManager
