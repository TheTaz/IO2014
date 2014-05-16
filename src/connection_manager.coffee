events = require('events');


###*
# @module server
###

events = require 'events'

###*
# ConnectionManager class
# @class ConnectionManager
###
class ConnectionManager extends events.EventEmitter
  ###*
  # Initializes message counters
  # @class ConnectionManager
  # @constructor
  # @param {Object} sockets socket.io socket used by clients to connect to the server
  # @param {Boolean} debug enables debug outputs
  ###
  constructor: (@sockets, @debug) ->
    events.EventEmitter.call this

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
    # Object containing callbacks to execute when ack or error event is received.
    # It has the following format:
    # {
    #   1: { 
    #     taskId: taskId1, 
    #     callback: callback1 
    #   },
    #   2: { 
    #     taskId: taskId2, 
    #     callback: callback2 
    #   }
    # }
    # Where 1, 2 are msgIds and callback1, callback2 are callbacks to run,
    # when ack or error event for msgId 1 and 2 comes.
    # @property responseCallbacks
    # @type {Object}
    ###
    @responseCallbacks = {}

    @onPeerConnected (socket) =>
      socket.on 'ack', (payload) =>
        @onAck socket, payload

      socket.on 'error', (payload) =>
        @onError socket, payload

      socket.on 'result', (payload) =>
        @onResult socket, payload

  ###*
  # Creates new message object and initializes it's msgId
  # @method generateNewMessage
  # @return {Object} message stub with initialized msgId
  ###
  generateNewMessage: () ->
    message = {
      msgId: ++@lastServerMsgId,
      data: null
    }

  ###*
  # Sends message to given client to add provided task
  # @method sendNewTaskToPeer
  # @param {Object} socket client connection handling socket 
  # @param {Integer} taskId id of a new task
  # @param {String} runFun code of the function to run
  # @param {Object} callback receives acknowledgement or error for generated msgId, should have onAck and onError functions defined
  # @return Integer msgId of sent message
  ###
  sendNewTaskToPeer: (socket, taskId, runFun, callback) ->
    message = @generateNewMessage()
    if message?
      @responseCallbacks[message.msgId] = { taskId: taskId, callback: callback }
      if not runFun instanceof String and not typeof runFun is 'string'
        runFun = '(' + runFun + ')'
      message.data = {
        taskId: taskId,
        runFun: runFun
      }
      socket.emit 'addTask', message
      return message.msgId
  
  ###*
  # Sends message to given client to delete task
  # @method deleteTaskFromPeer
  # @param {Object} socket client connection handling socket 
  # @param {Integer} taskId id of a task
  # @param {Object} callback receives acknowledgement or error for generated msgId, should have onAck and onError functions defined
  # @return Integer msgId of sent message
  ###
  deleteTaskFromPeer: (socket, taskId, callback) ->
    message = @generateNewMessage()
    if message?
      @responseCallbacks[message.msgId] = { taskId: taskId, callback: callback }
      message.data = {
        taskId: taskId
      }
      socket.emit 'deleteTask', message
      return message.msgId

  ###*
  # Sends message to given client to execute job
  # @method executeJobOnPeer
  # @param {Object} socket client connection handling socket 
  # @param {Integer} taskId id of a task
  # @param {Integer} jobId id of a job
  # @param {Object} jobArgs arguments for a job to execute
  # @param {Object} callback receives acknowledgement or error for generated msgId, should have onAck and onError functions defined
  # @return Integer msgId of sent message
  ###
  executeJobOnPeer: (socket, taskId, jobId, jobArgs, callback) ->
    message = @generateNewMessage()
    if message?
      @responseCallbacks[message.msgId] = { taskId: taskId, callback: callback }
      message.data = {
        taskId: taskId,
        jobId: jobId,
        jobArgs: jobArgs
      }
      socket.emit 'executeJob', message
      return message.msgId

  deleteJobFromPeer: (socket, taskId, jobId) ->
    #stub method

  ###*
  # Sends acknowledgment message to given client
  # @method sendAckToPeer
  # @param {Object} socket client connection handling socket 
  # @param {Integer} msgId id of a message to accept
  ###
  sendAckToPeer: (socket, msgId) ->
    message = {
      msgId: msgId
    }
    socket.emit 'ack', message

  ###*
  # Default handler for acknowledgements from clients
  # @method onAck
  # @param {Object} socket object used to communicate with connected client
  # @param {Object} payload data sent along with the event
  ###
  onAck: (socket, payload) ->
    if @debug then console.log('Got message ' + payload.msgId + " acknowledgment")
    taskId = @responseCallbacks[payload.msgId]?.taskId
    callback = @responseCallbacks[payload.msgId]?.callback
    if taskId? then callback?.onAck?(socket, taskId)
    delete @responseCallbacks[payload.msgId]

  ###*
  # Default handler for errors from clients
  # @method onError
  # @param {Object} socket object used to communicate with connected client
  # @param {Object} payload data sent along with the event
  ###
  onError: (socket, payload) ->
    taskId = @responseCallbacks[payload.msgId]?.taskId
    callback = @responseCallbacks[payload.msgId]?.callback
    if taskId? then callback?.onError?(socket, taskId)
    delete @responseCallbacks[payload.msgId]

    if @debug
      console.log('Message ' + payload.msgId + " generated error code " + payload.error)
      console.log('Details:')
      switch payload.error
        when 1
          console.log('No code for task ' + payload.details.taskId)
        when 2
          console.log('Job execution error for task: ' + payload.details.taskId + " job: " + payload.details.jobId)
          console.log('Reason: ' + payload.details.reason)
        when 3
          console.log('Job execution denied for task: ' + payload.details.taskId + " job: " + payload.details.jobId)
          console.log('Reason: ' + payload.details.reason)
        when 4
          console.log('Malformed operation, reason: ' + payload.details.reason)
        else
          console.log('Unknown error code')

  ###*
  # Default handler for result events from clients
  # Emits 'resultReady' event passing two objects as payload:
  # socket - client which returned the result
  # data - object containing the result, it has the following structure:
  # { 
  #   taskId: taskId
  #   jobId: jobId
  #   jobResult: jobResult
  # }
  # @method onResult
  # @param {Object} socket object used to communicate with connected client
  # @param {Object} payload data sent along with the event
  ###
  onResult: (socket, payload) ->
    @lastClientMsgId = payload.msgId
    @sendAckToPeer(socket, payload.msgId)
    @emit 'resultReady', socket, payload.data

    if @debug
      console.log('Received partial task result:')
      console.log('Message: ' + payload.msgId)  #Note that this message id is generated by client
      console.log('Task: ' + payload.data.taskId)
      console.log('Job: ' + payload.data.jobId)
      console.log('Result: ' + payload.data.jobResult)
      console.log('Sending acknowledgment to client')

  ###*
  # Callback can take a connected client as a parametr
  # @method onPeerConnected
  # @param {Function} callback a callback which will be executed when new clients is connected
  ###
  onPeerConnected: (callback) ->
    @sockets.on 'connection', callback 

  ###*
  # @method onPeerDisconnected
  # @param {Function} callback a callback which will be executed when someone disconnects
  ###
  onPeerDisconnected: (callback) ->
    @sockets.on 'disconnect', callback

  onJobDone: (callback) ->
    #method stub
    @onJobDoneCallback=callback

  ###*
  # @method getActiveConnections
  # @return a list of currently connected clients
  ###
  getActiveConnections: ->
    @sockets.clients()

module.exports = ConnectionManager
