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
