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
          socket.emit('invalid')
          console.log "Invalid data: ", data
          return

        try
          # task.owner = socket
          taskId = @taskManager.addTask task
          @taskManager.startTask taskId
          console.log 'command executed: ' + data
          socket.emit('started', { taskId: taskId })
        catch err
          console.log "Failed to add task: ", task
          console.log "Cannot add task due to: ", err.message
          socket.emit('error', { taskId: taskId, details: err.message })

      # valid events:
      # invalid
      # started { taskId: 1 }
      # error { taskId: 1, details: "details" }
      # result { taskId: 1, result: [ ... ] }
      # progress { taskId: 1, progress: 50 }


module.exports = AdminConsole
