###*
# @module server
###

###*
# AdminConsole class
# @class AdminConsole
# @module server
###
class AdminConsole

  ###*
  # Initializes socket and html elements to inject in realtime.
  # Sets listener for 'send task' button click
  # @class AdminConsole
  # @constructor
  # @type {Object}
  # @params sockets object maintaining websocket connections
  # @type {Object}
  # @params dispatcher object handling tasks dispatching
  # @type {Object}
  # @params connectionManager object maintaining connections with clients
  ###
  constructor: (@sockets, @dispatcher, @connectionManager) ->
    JsInjector = require './js_injector'
    TaskManager = require './task_manager'
    ResultAggregator = require "./result_aggregator"

    ###*
    # Object responsible for injecting task code to clients
    # @property jsInjector
    # @type {Object}
    ###
    @jsInjector = new JsInjector(@connectionManager)

    ###*
    # Object responsible for aggregating results sent from clients
    # @property resultAgregator
    # @type {Object}
    ###
    @resultAgregator = new ResultAggregator(@dispatcher)

    ###*
    # Object responsible for task management
    # @property taskManager
    # @type {Object}
    ###
    @taskManager = new TaskManager(@dispatcher, @jsInjector, @resultAgregator)

    # #DEMO
    # @id = 0
    # #DEMO

    @sockets.on 'connection', (socket) =>
      console.log 'admin connected'
      socket.on 'command', (data) =>

        # #DEMO
        # localId = ++@id
        # socket.emit 'started', { taskId: localId }
        # setTimeout ->
        #  socket.emit 'progress', { taskId: localId, progress: 33 }
        #  setTimeout ->
        #    socket.emit 'progress', { taskId: localId, progress: 66 }
        #    setTimeout ->
        #      socket.emit 'progress', { taskId: localId, progress: 100 }
        #      setTimeout ->
        #        socket.emit 'result', { taskId: localId, result: [1, 2, 3] }
        #      , 3000
        #    , 3000
        #  , 3000
        # , 3000
        # #DEMO

        try
          task = eval '(' + data + ')'

        if not task?
          console.log "Invalid data: ", data
          @notifyInvalid socket
          return

        try
          task.owner = socket
          taskId = @taskManager.addTask task
          @taskManager.startTask taskId
          console.log 'command executed: ' + data
          @notifyStarted socket, taskId
        catch err
          console.log "Failed to add task: ", task
          console.log "Cannot add task due to: ", err.message
          @notifyError socket, taskId, err.message

  ###*
  # Notifies all admin consoles that the task has been added successfully
  # @method notifyStarted
  # @type {Integer}
  # @param taskId id of added task
  ###
  notifyStarted: (taskId) =>
    @sockets.emit 'started', { taskId: taskId }

  ###*
  # Notifies admin console that scheduled a task, that error took place
  # @method notifyError
  # @type {Object}
  # @param socket responsible for maintaining connection with admin console
  # @type {Integer}
  # @param taskId id of added task
  # @type {String}
  # @param details message explaining what caused error
  ###
  notifyError: (socket, taskId, details) =>
    socket.emit 'error', { taskId: taskId, details: details }

  ###*
  # Notifies admin console that scheduled a task, that task is invalid
  # @method notifyInvalid
  # @type {Object}
  # @param socket responsible for maintaining connection with admin console
  ###
  notifyInvalid: (socket) =>
    socket.emit 'invalid'

  ###*
  # Notifies all admin consoles that result for a task is ready
  # @method notifyResult
  # @type {Integer}
  # @param taskId id of added task
  # @type {Object}
  # @param result computed result of a task
  ###
  notifyResult: (taskId, result) =>
    @sockets.emit 'result', { taskId: taskId, result: result }

  ###*
  # Notifies all admin consoles, that progress of a task needs to be updated
  # @method notifyProgress
  # @type {Integer}
  # @param taskId id of added task
  # @type {Integer}
  # @param progress percentage of a task done
  ###
  notifyProgress: (taskId, progress) =>
    @sockets.emit 'progress', { taskId: taskId, progress: progress }

module.exports = AdminConsole
