###*
# js_injector class.
# @class js_injector
###

class JsInjector
  constructor: (@connectionManager) ->

  inject: (id, task) ->
    data =
      type: "task"
      taskId: id
      task: task

    for client in @connectionManager.connectedClients()
      @connectionManager.send(client, data)

module.exports = JsInjector
