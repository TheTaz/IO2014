###*
# Js code injector class.
# @class JsInjector
###

class JsInjector
  constructor: (@connectionManager) ->

  ###*
  # Inject code, takes as parameter task id and task processing function
  # @method injectCode
  # @param {Integer} taskId specified task identificator
  # @param {Function} runFun specified task processing function
  ###

  currentTaskFun = null;

  injectCode: (taskId, runFun) ->

    console.log "CodeInjector:Loading code for task: ", taskId

    currentTaskFun = runFun;
    
    for client in @connectionManager.getActiveConnections()
      @connectionManager.sendNewTaskToPeer(client, taskId, runFun)

    console.log "CodeInjector:Code loaded for task: ", taskId

  ###*
  # Handles new clients and gives them stored task proc fun taking as a param task id only
  # @method newClientHandler
  # @param {Integer} taskId specified task identificator
  ###

  newClientHandler: (taskId) ->

    console.log "CodeInjector:Handling new clients with task: ", taskId

    for client in @connectionManager.getActiveConnections()
      if @connectionManager.onCodeLoaded == 'code_loaded'
        @connectionManager.sendNewTaskToPeer(client, taskId, currentTaskFun)

  ###*
  # Unloads code from clients, code is recognized by task id.
  # @method unloadCode  
  # @param {Integer} taskId specified task identificator
  ###

  unloadCode: (taskId) ->

    console.log "CodeInjector:Unloading code for task: ", taskId

    for client in @connectionManager.getActiveConnections()
      @connectionManager.deleteTaskFromPeer(client, taskId)

    console.log "CodeInjector:Code unloaded for task: ", taskId

  ###*
  # Callback run when code is injected to specified client
  # @method onCodeInjected
  # @param {Function} callback a callback can get client id as a param
  ###

  onCodeInjected: (callback) -> 
    @connectionManager.onCodeLoaded callback

module.exports = JsInjector
