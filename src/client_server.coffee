class ClientServer
	constructor: (@connectionManager) ->
		@connectionManager.onPeerConnected (socket) ->
			console.log("New user connected")

module.exports = ClientServer
