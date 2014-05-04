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
  # @param {Function} taskProcessFun specified task processing function
  ###

  injectCode: (taskId, taskProcessFun) ->

    console.log "Loading code for task: ", taskId

    data =
      type: "task"
      taskId: taskId
      task: taskProcessFun

    for client in @connectionManager.getActiveConnections()
      @connectionManager.send(client, data)

  ###*
  # Inject code, takes as parameter task id only
  # @method injectCodeNoTPF
  # @param {Integer} taskId specified task identificator
  ###

  injectCodeNoTPF: (taskId) ->

    console.log "Loading code without task processing function for task: ", taskId

    data =
      type: "task"
      taskId: taskId

    for client in @connectionManager.getActiveConnections()
      @connectionManager.send(client, data)

  ###*
  # Unloads code from clients, code is recognized by task id.
  # @method unloadCode  
  # @param {Integer} taskId specified task identificator
  ###

  unloadCode: (taskId) ->

    data =
      type: "task"
      taskId: taskId

    for client in @connectionManager.getActiveConnections()
      @connectionManager.unload(client, taskId)

    console.log "Unloading code for task: ", taskId

  ###*
  # Callback run when code is injected to specified client
  # @method onCodeInjected
  # @param {Function} callback a callback can get client id as a param
  ###

  onCodeInjected: (callback) ->
    @sockets.on 'code-injected', callback

module.exports = JsInjector
