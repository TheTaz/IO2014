###*
# @module server
###

###*
# Js code injector class.
# @class JsInjector
###

class JsInjector

  ###*
  # Initializes taskFunctionsList
  # @class JsInjector
  # @constructor
  ###

  constructor: (@connectionManager) ->
    @taskFunctionsList = {}
    @injectCallback = { 
      onAck: (socket, taskId) -> 
        @socketsState[socket].push taskId
      onError: (socket, taskId) ->
        console.log "Inject callback error::Socket: #{socket}::taskId: #{taskId} !"
    }
    @unloadCallback = {
      onAck: (socket, taskId) ->
        @socketsState[socket] = @socketsState[socket].filter (id) -> if id isnt taskId
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
      console.log "CodeInjector:Loading code for task: #{taskId}..."
      @taskFunctionsList[taskId] = runFun;
      for socket in @connectionManager.getActiveConnections()
        @socketsState[socket] ?= []
        if not taskId in @socketsState[socket]
          @connectionManager.sendNewTaskToPeer(socket, taskId, @taskFunctionsList[taskId], @injectCallback)
      console.log "CodeInjector::Code loaded for task: #{taskId} !"
    else 
      console.log "CodeInjector::Complementing sockets for task: #{taskId}..."
      for socket in @connectionManager.getActiveConnections()
        @socketsState[socket] ?= []
        if not taskId in @socketsState[socket]
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
    @taskFunctionsList[taskId] = null
    console.log "CodeInjector::Code unloaded for task: #{taskId} !"

module.exports = JsInjector
