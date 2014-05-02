class ConnectionManager
	constructor: (@sockets) ->

	onPeerConnected: (callback) ->
		@sockets.on 'connection', callback

	onPeerDisconnected: (callback) ->
		@sockets.on 'disconnect', callback

	# TODO : document callback and test it somehow
	onCodeLoaded: (callback) ->
		@sockets.on 'code_loaded', callback

	onResultReady: (callback) ->
		@sockets.on 'result_ready', callback

	# TODO : wrap up clients in a class allowing for custom events
	getActiveConnections: ->
    @sockets.clients()

  send: (client, data) ->
    # Stub method
    console.log "ConnectionManager:send(", client, ",", data , ")"

module.exports = ConnectionManager