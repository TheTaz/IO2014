###*
# ConnectionManager class.
# @class ConnectionManager
###
class ConnectionManager
	constructor: (@sockets) ->

	###*
	# Callback can take connected client as a parametr
	# @method onPeerConnected
	# @param {Function} callback a callback which will be executed when new clients is connected
	###
	onPeerConnected: (callback) ->
		@sockets.on 'connection', callback

	###*
	# @method onPeerDisconnected
	# @param {Function} callback a callback which will be executed when someone disconnects
	###
	onPeerDisconnected: (callback) ->
		@sockets.on 'disconnect', callback

	###*
	# @method onCodeLoaded
	# @param {Function} callback a callback which will be executed whenever a client emits code_loaded event
	###
	onCodeLoaded: (callback) ->
		@sockets.on 'code_loaded', callback

	###*
	# @method onResultReady
	# @param {Function} callback a callback which will be executed whenever a client emits result_ready event
	###
	onResultReady: (callback) ->
		@sockets.on 'result_ready', callback

	###*
	# @method getActiveConnections
	# @return a list of currently connected clients
	###
	getActiveConnections: ->
    	@sockets.clients()

	###*
	# Sends an event to specified client
	# @method send
	# @params {String} event_name event name 
	# @param {Object} params optional hash with params 
	###
	send: (client, event_name, params = {}) ->
    	client.send(event_name, params)

module.exports = ConnectionManager
