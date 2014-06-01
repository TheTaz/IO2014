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
        console.log "Client 1", taskId, taskId not in @socketsState[socket]
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
  # Returns socketsState map.
  # @method getPeerCapabilities
  ###

  getPeerCapabilities: () ->
    return @socketsState

  getPeerCapabilities: (socket) ->
    return @socketsState[socket]

  ###*
  # Callback invocated when peer capabilities are changed.
  # @method onPeerCapabilitiesChanged
  ###

  onPeerCapabilitiesChanged: (callback) ->
    @on 'peer_capabilities_changed', callback

module.exports = JsInjector
