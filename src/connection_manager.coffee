class ConnectionManager
	constructor: (@sockets) ->

	onPeerConnected: (callback) ->
		@sockets.on 'connection', callback

	onPeerDisconnected: (callback) ->
		@sockets.on 'disconnect', callback

	onCodeLoaded: (callback) ->
		@sockets.on 'code_loaded', callback

	onResultReady: (callback) ->
		@sockets.on 'result_ready', callback

	getActiveConnections: ->
    	@sockets.clients()

	send: (client, data) ->
    	client.send(data)

module.exports = ConnectionManager
