class ClientServer
	constructor: (@dispatcher, @connectionManager) ->
		@connectionManager.onPeerConnected (socket) ->
			console.log("New user connected")


#		@dispatcher.on 'completed', (result) ->
#			console.log "Results arrived: " + JSON.stringify(result)

module.exports = ClientServer
