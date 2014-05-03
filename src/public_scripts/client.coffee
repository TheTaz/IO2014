###*
# This script runs in web browser, when client opens client.html
# @module client
###

###*
# Client class
# @class Client
# @module client
###
class Client
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

  setEventListener: (event, listener) =>
    @socket.on event, listener

  checkIfMissedAnyMessages: (operation) =>
    #TODO: Is this check needed?
    if @lastServerMsgId + 1 isnt operation.msgId
      console.log 'Synchronization error, last message id was: ' + @lastServerMsgId +  ' while current is: ' + operation.msgId
      @socket.emit('error', { error: 4, msgId: i, details: { reason: 'Did not receive operation' } }) for i in [(@lastServerMsgId + 1)..(operation.msgId)]

    @lastServerMsgId = operation.msgId
  
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

  onDeleteTask: (operation) =>
    taskId = operation.data.taskId

    #TODO: Fire-and-forget call, or notify server that taskId was already removed?
    delete @tasks[taskId]
    console.log 'Deleted task: ' + taskId
    @socket.emit('ack', { msgId: operation.msgId})

  onExecuteJob: (operation) =>
    taskId = operation.data.taskId
    jobId = operation.data.jobId
    jobArgs = operation.data.jobArgs

    task = @tasks[taskId]

    if not task?
      console.log 'Cannot execute task, it doesn\'t exist'
      @socket.emit('error', { error: 1, msgId: operation.msgId, details: { taskId: operation.data.taskId } })
      return

    console.log 'Executing task: ' + taskId
    console.log 'Task code: ' + task.task
    console.log 'Job arguments: ' + jobArgs
    result = eval(task.task).taskProcess jobArgs
    task.results[jobId] = result
    console.log 'Result is: ' + result

    @socket.emit('ack', { msgId: operation.msgId})

    @returnResult(operation, result)

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

  onMalformedOperation: (operation) =>
    console.log 'Cannot handle operation' + operation.msgId
    @socket.emit('error', { error: 4, msgId: i, details: { reason: 'Cannot handle operation' } })

console.log 'Client script loaded, connecting to server...'

client = new Client()

client.setEventListener 'addTask', (operation) =>
  console.log('Event: new task')
  client.checkIfMissedAnyMessages(operation)
  client.onAddNewTask(operation)

client.setEventListener 'deleteTask', (operation) =>
  console.log('Event: delete task')
  client.checkIfMissedAnyMessages(operation)
  client.onDeleteTask(operation)

client.setEventListener 'executeJob', (operation) =>
  console.log('Event: run job')
  client.checkIfMissedAnyMessages(operation)
  client.onExecuteJob(operation)

client.setEventListener 'ack', (message) =>
  console.log('Ack for message ' + message.msgId)
