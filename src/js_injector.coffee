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

  injectCode: (taskId, runFun) ->

    console.log "CodeInjector:Loading code for task: ", taskId
    
    for client in @connectionManager.getActiveConnections()
      @connectionManager.sendNewTaskToPeer(client, taskId, runFun)

    console.log "CodeInjector:Code loaded for task: ", taskId

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
