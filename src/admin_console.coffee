class AdminConsole
  constructor: (@sockets, @dispatcher, @connectionManager) ->
    JsInjector = require './js_injector'
    @jsInjector = new JsInjector(@connectionManager)
    TaskManager = require './task_manager'
    @taskManager = new TaskManager(@dispatcher, @jsInjector)

    @sockets.on 'connection', (socket) ->
      console.log 'admin connected'
      socket.on 'command', (data) ->
        task = eval data
        #@taskManager.manage task
        console.log 'command executed: ' + data
        socket.emit('result', 'Task completed! Result is: 3.14159265...')

module.exports = AdminConsole