###*
# @module server
###

JsInjector = require './js_injector'
TaskManager = require './task_manager'
ResultAggregator = require "./result_aggregator"

class AdminConsole

  ###*
  # Initializes socket and html elements to inject in realtime.
  # Sets listener for 'send task' button click
  # @class AdminConsole
  # @constructor
  # @params {Object} sockets object maintaining websocket connections
  # @params {JobDispatcher} dispatcher object handling tasks dispatching
  # @params {ConnectionManager} connectionManager object maintaining connections with clients
  ###
  constructor: (@sockets, @dispatcher, @connectionManager) ->

    ###*
    # Object responsible for injecting task code to clients
    # @property jsInjector
    # @type {JsInjector}
    ###
    @jsInjector = new JsInjector(@connectionManager)

    ###*
    # Object responsible for aggregating results sent from clients
    # @property resultAgregator
    # @type {ResultAggregator}
    ###
    @resultAgregator = new ResultAggregator(@dispatcher)

    ###*
    # Object responsible for task management
    # @property taskManager
    # @type {TaskManager}
    ###
    @taskManager = new TaskManager(@dispatcher, @jsInjector, @resultAgregator)

    @sockets.on 'connection', (socket) =>
      console.log 'admin connected'
      socket.on 'command', (data) =>
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
  # @param {Integer} taskId id of added task
  ###
  notifyStarted: (taskId) ->
    @sockets.emit 'started', { taskId: taskId }

  ###*
  # Notifies admin console that scheduled a task, that error took place
  # @method notifyError
  # @param {Object} socket responsible for maintaining connection with admin console
  # @param {Integer} taskId id of added task
  # @param {String} details message explaining what caused error
  ###
  notifyError: (socket, taskId, details) ->
    socket.emit 'error', { taskId: taskId, details: details }

  ###*
  # Notifies admin console that scheduled a task, that task is invalid
  # @method notifyInvalid
  # @param {Object} socket responsible for maintaining connection with admin console
  ###
  notifyInvalid: (socket) ->
    socket.emit 'invalid'

  ###*
  # Notifies all admin consoles that result for a task is ready
  # @method notifyResult
  # @param {Integer} taskId id of added task
  # @param {Object} result computed result of a task
  ###
  notifyResult: (taskId, result) ->
    @sockets.emit 'result', { taskId: taskId, result: result }

  ###*
  # Notifies all admin consoles, that progress of a task needs to be updated
  # @method notifyProgress
  # @param {Integer} taskId id of added task
  # @param {Integer} progress percentage of a task done
  ###
  notifyProgress: (taskId, progress) ->
    @sockets.emit 'progress', { taskId: taskId, progress: progress }

module.exports = AdminConsole
