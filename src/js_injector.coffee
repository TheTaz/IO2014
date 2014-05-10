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
    @callback = { 
      onAck: (socket, taskId) -> 
        @socketsState[socket].push taskId
      onError: (socket, taskId) ->
        console.log "Callback error::Socket: #{socket}::taskId: #{taskId} !"
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
      console.log "CodeInjector:Loading code for task #{taskId}..."
      @taskFunctionsList[taskId] = runFun;
      for socket in @connectionManager.getActiveConnections()
        @socketsState[socket]? = []
        @connectionManager.sendNewTaskToPeer(socket, taskId, @taskFunctionsList[taskId], @callback)
      console.log "CodeInjector::Code loaded for task #{taskId} !"
    else 
      console.log "CodeInjector::Complementing sockets for task #{taskId}..."
      for socket in @connectionManager.getActiveConnections()
        if not @socketsState[socket]? then
          @socketsState[socket] = []
        if not taskId in @socketsState[socket] then
          @connectionManager.sendNewTaskToPeer(socket, taskId, @taskFunctionsList[taskId], @callback)

  ###*
  # Unloads code from sockets, code is recognized by task id.
  # @method unloadCode  
  # @param {Integer} taskId specified task identificator
  ###

  unloadCode: (taskId) ->

    console.log "CodeInjector:Unloading code for task: ", taskId
    for socket in @connectionManager.getActiveConnections()
      @connectionManager.deleteTaskFromPeer(socket, taskId, @callback)
    @taskFunctionsList[taskId].delete
    console.log "CodeInjector:Code unloaded for task: ", taskId

  ###*
  # Callback run when code is injected to specified socket
  # @method onCodeInjected
  # @param {Function} callback a callback can get socket id as a param
  ###

  onCodeInjected: (callback) -> 
    @connectionManager.onCodeLoaded callback

module.exports = JsInjector
