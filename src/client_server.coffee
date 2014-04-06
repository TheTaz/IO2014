class ClientServer
	constructor: (@dispatcher, @connectionManager) ->
		@connectionManager.onConnection (socket) ->
			console.log("New user connected")


		@dispatcher.on 'completed', (result) ->
			console.log "Results arrived: " + JSON.stringify(result)

	dispatchTask: (func, left, right) ->
		@dispatcher.dispatchTask func, left, right, @connectionManager.connectedClients()

module.exports = ClientServer
