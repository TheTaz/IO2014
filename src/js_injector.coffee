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
    taskFunctionsList = []

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
      taskFunctionsList[taskId] = runFun;
      for client in @connectionManager.getActiveConnections()
        @connectionManager.sendNewTaskToPeer(client, taskId, taskFunctionsList[taskId])
      console.log "CodeInjector::Code loaded for task #{taskId} !"
    else 
      console.log "CodeInjectror::Complementing clients for task #{taskId}..."
      if @connectionManager.onCodeLoaded != 'code_loaded'
        @connectionManager.sendNewTaskToPeer(client, taskId, taskFunctionsList[taskId])

  ###*
  # Unloads code from clients, code is recognized by task id.
  # @method unloadCode  
  # @param {Integer} taskId specified task identificator
  ###

  unloadCode: (taskId) ->

    console.log "CodeInjector:Unloading code for task: ", taskId
    for client in @connectionManager.getActiveConnections()
      @connectionManager.deleteTaskFromPeer(client, taskId)
    taskFunctionsList[taskId].delete
    console.log "CodeInjector:Code unloaded for task: ", taskId

  ###*
  # Callback run when code is injected to specified client
  # @method onCodeInjected
  # @param {Function} callback a callback can get client id as a param
  ###

  onCodeInjected: (callback) -> 
    @connectionManager.onCodeLoaded callback

module.exports = JsInjector
