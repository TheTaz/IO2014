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
		return @sockets.clients()

module.exports = ConnectionManager
