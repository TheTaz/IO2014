class AdminConsole
  constructor: (@sockets, @dispatcher, @connectionManager) ->
    JsInjector = require './js_injector'
    TaskManager = require './task_manager'
    ResultAggregator = require "./result_aggregator"

    @jsInjector = new JsInjector(@connectionManager)
    @resultAgregator = new ResultAggregator(@dispatcher)
    @taskManager = new TaskManager(@dispatcher, @jsInjector, @resultAgregator)

    @sockets.on 'connection', (socket) =>
      console.log 'admin connected'
      socket.on 'command', (data) =>

        try
          task = eval '(' + data + ')'

        if not task?
          socket.emit('result', 'Invalid data!')
          console.log "Invalid data: ", data
          return

        try
          taskId = @taskManager.addTask task
          @taskManager.startTask taskId
          console.log 'command executed: ' + data
          socket.emit('result', 'Task started!')
        catch err
          console.log "Failed to add task:", task
          console.log "Cannot add task due to:", err
          socket.emit('result', 'Invalid task!')


module.exports = AdminConsole
