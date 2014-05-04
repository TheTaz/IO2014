###*
# This script runs in web browser, when client opens client.html
# @module client
###

###*
# Client class
# @class Client
###
class Client
  ###*
  # Initializes message counters and socket
  # @class Client
  # @constructor
  ###
  constructor: () ->

    ###*
    # Address for client to connect to server websocket
    # @property clientEndpoint
    # @type {String}
    ###
    @clientEndpoint = 'http://localhost/client'

    ###*
    # Socket handling the connection to the server
    # @property socket
    # @type Object
    ###
    @socket = io.connect @clientEndpoint

    ###*
    # Value defining id of the last operation sent by the server
    # @property lastServerMsgId
    # @type Integer
    ###
    @lastServerMsgId = 0

    ###*
    # Value defining id of the last operation sent by the client
    # @property lastClientMsgId
    # @type Integer
    ###
    @lastClientMsgId = 0

    ###*
    # Local object containing saved tasks and their results (if any exist)
    # Object has the following format:
    # {
    #   1: { 
    #     task: '({ ... })', 
    #     results: { 
    #       1: [ ... ], 
    #       2: [ ... ] 
    #     } 
    #   }, 
    #   2: { 
    #     ... 
    #   } 
    # }
    # @property tasks
    # @type Object
    ###
    @tasks = {}

  ###*
  # Sets event listener for a given websocket event
  # @method addEventListener
  # @param {String} event event name
  # @param {Object} listener callback for an event, can take message payload as an argument
  ###
  addEventListener: (event, listener) =>
    @socket.on event, listener

  ###*
  # Removes event listener for a given websocket event
  # @method removeEventListener
  # @param {String} event event name
  # @param {Object} listener callback for an event to remove
  ###
  removeEventListener: (event, listener) =>
    @socket.removeListener event, listener 
  
  ###*
  # Handler for adding new task operation. Saves given task if it exists.
  # @method onAddNewTask
  # @param {Object} operation message payload
  ###
  onAddNewTask: (operation) =>
    console.log operation.data.runFun
    console.log typeof operation.data.runFun

    if operation.data.runFun instanceof String or typeof operation.data.runFun is 'string'
      taskId = operation.data.taskId
      @tasks[taskId] = {}
      @tasks[taskId].task = operation.data.runFun
      @tasks[taskId].results = {}
      console.log 'Added new task: ' + @tasks[taskId].task
      @socket.emit('ack', { msgId: operation.msgId})
    else 
      console.log 'No task function provided'
      @socket.emit('error', { error: 1, msgId: operation.msgId, details: { taskId: operation.data.taskId } });

  ###*
  # Handler for deleting a task operation.
  # @method onDeleteTask
  # @param {Object} operation message payload
  ###
  onDeleteTask: (operation) =>
    taskId = operation.data.taskId

    #TODO: Fire-and-forget call, or notify server that taskId was already removed?
    delete @tasks[taskId]
    console.log 'Deleted task: ' + taskId
    @socket.emit('ack', { msgId: operation.msgId})

  ###*
  # Handler for executing a job operation. 
  # Loads a saved task, and executes it with given parameters.
  # After successful execution returnResult function is called.
  # @method onExecuteJob
  # @param {Object} operation message payload
  ###
  onExecuteJob: (operation) =>
    taskId = operation.data.taskId
    jobId = operation.data.jobId
    jobArgs = operation.data.jobArgs

    task = @tasks[taskId]

    if not task?
      console.log 'Cannot execute task, it doesn\'t exist'
      @socket.emit('error', { error: 1, msgId: operation.msgId, details: { taskId: taskId } })
      return

    @socket.emit('ack', { msgId: operation.msgId})

    console.log 'Executing task: ' + taskId
    console.log 'Task code: ' + task.task
    console.log 'Job arguments: ' + jobArgs
    try
      result = eval(task.task).taskProcess jobArgs
      task.results[jobId] = result
      console.log 'Result is: ' + result
      @returnResult(operation, result)
    catch error
      @socket.emit('error', { error: 2, msgId: operation.msgId, details: { taskId: taskId, jobId: jobId, reason: error } })
    
  ###*
  # Handles job result sending.
  # Schedules a check for acknowledgement.
  # If there is no acknowledgement, the operation is restarted.
  # @method returnResult
  # @param {Object} operation message payload
  # @param {Object} result job result
  ###
  returnResult: (operation, result) =>
    taskResult = { 
      msgId:  --@lastClientMsgId, 
      data: { 
        taskId: operation.data.taskId,
        jobId: operation.data.jobId,
        jobResult: result
      }
    }

    @socket.emit('result', taskResult)

    resultAcknowledged = false

    ackEventListener = (message) ->
      console.log('Got acknowledgement for result with msgId ' + taskResult.msgId)
      resultAcknowledged = true

    @addEventListener 'ack', ackEventListener

    setTimeout =>
      if not resultAcknowledged
        console.log('Did not get acknowledgement, trying one more time')
        @removeEventListener 'ack', ackEventListener
        @returnResult operation, result
      else
        @removeEventListener 'ack', ackEventListener
    , 5000

  ###*
  # Should be called if operation structure is malformed and cannot be processed by the client.
  # @method onMalformedOperation
  # @param {Object} operation message payload
  ###
  onMalformedOperation: (operation) =>
    console.log 'Cannot handle operation' + operation.msgId
    @socket.emit('error', { error: 4, msgId: i, details: { reason: 'Cannot handle operation' } })

console.log 'Client script loaded, connecting to server...'

client = new Client()

client.addEventListener 'addTask', (operation) =>
  console.log('Event: new task')
  @lastServerMsgId = operation.msgId
  client.onAddNewTask(operation)

client.addEventListener 'deleteTask', (operation) =>
  console.log('Event: delete task')
  @lastServerMsgId = operation.msgId
  client.onDeleteTask(operation)

client.addEventListener 'executeJob', (operation) =>
  console.log('Event: run job')
  @lastServerMsgId = operation.msgId
  client.onExecuteJob(operation)
