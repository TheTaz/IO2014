###*
# js_injector class.
# @class js_injector
###

class JsInjector
  constructor: (@connectionManager) ->

  injectCode: (taskId, taskProcessFun) ->
    # Stub method

    console.log "Loading code for task: ", taskId

    data =
      type: "task"
      taskId: taskId
      task: taskProcessFun

    for client in @connectionManager.getActiveConnections()
      @connectionManager.send(client, data)

  unloadCode: (taskId) ->
    # Stub method
    console.log "Unloading code for task: ", taskId

module.exports = JsInjector
