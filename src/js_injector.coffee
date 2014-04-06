class JsInjector
  constructor: (@connection_manager) ->

  inject = (data, clients) ->
    for client in clients
      @connectionManager.send(client, data)

module.exports = Injector