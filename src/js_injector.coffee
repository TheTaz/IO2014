events = require('events');

###*
# @module server
###

###*
# Js code injector class.
# @class JsInjector
###

class JsInjector extends events.EventEmitter

  ###*
  # Initializes taskFunctionsList
  # @class JsInjector
  # @constructor
  ###

  constructor: (@connectionManager) ->
    events.EventEmitter.call this

    @taskFunctionsList = {}
    @injectCallback = { 
      onAck: (socket, taskId) =>
        @socketsState[socket].push taskId
        @emit 'peer_capabilities_changed', socket
      onError: (socket, taskId) =>
        console.log "Inject callback error::Socket: #{socket}::taskId: #{taskId} !"
    }
    @unloadCallback = {
      onAck: (socket, taskId) ->
        @socketsState[socket] = @socketsState[socket].filter (id) -> id isnt taskId
      onError: (socket, taskId) ->
        console.log "Unload callback error::Socket: #{socket}::taskId: #{taskId} !"
    }

    @connectionManager.onPeerConnected @newPeerConnected

    @socketsState = {}

  ###*
  # Inject code, takes as parameter task id and task processing function
  # @method injectCode
  # @param {Integer} taskId specified task identificator
  # @param {Function} runFun specified task processing function
  # @default {null} runFun
  ###

  injectCode: (taskId, runFun = null) ->

    if runFun != null
      console.log "CodeInjector::Loading code for task: #{taskId}...", @connectionManager.getActiveConnections()
      @taskFunctionsList[taskId] = runFun;
      for socket in @connectionManager.getActiveConnections()

        @socketsState[socket] ?= []
        if taskId not in @socketsState[socket]
          @connectionManager.sendNewTaskToPeer(socket, taskId, @taskFunctionsList[taskId], @injectCallback)

      console.log "CodeInjector::Code loaded for task: #{taskId} !"
    else 
      console.log "CodeInjector::Complementing sockets for task: #{taskId}..."
      for socket in @connectionManager.getActiveConnections()
        @socketsState[socket] ?= []
        if taskId not in @socketsState[socket]
          @connectionManager.sendNewTaskToPeer(socket, taskId, @taskFunctionsList[taskId], @injectCallback)

      console.log "CodeInjector::Sockets have been complemented for task: #{taskId} !"

  ###*
  # Unloads code from sockets, code is recognized by task id.
  # @method unloadCode  
  # @param {Integer} taskId specified task identificator
  ###

  unloadCode: (taskId) ->

    console.log "CodeInjector::Unloading code for task: #{taskId}..."
    for socket in @connectionManager.getActiveConnections()
      @connectionManager.deleteTaskFromPeer(socket, taskId, @unloadCallback)
      @emit 'peer_capabilities_changed', socket
    @taskFunctionsList[taskId] = null
    console.log "CodeInjector::Code unloaded for task: #{taskId} !"

  ###*
  # Returns capabilities of given peer.
  # @method getPeerCapabilities
  ###
  getPeerCapabilities: (socket) ->
    return @socketsState[socket]


  ###*
  # Injects all currently available task runFun codes to given peer.
  # @method newPeerConnected
  ###
  newPeerConnected: (socket) =>
    for taskId of @taskFunctionsList
      @injectCode(taskId)

  ###*
  # Callback invocated when peer capabilities are changed.
  # @method onPeerCapabilitiesChanged
  ###
  onPeerCapabilitiesChanged: (callback) ->
    @on 'peer_capabilities_changed', callback

module.exports = JsInjector
