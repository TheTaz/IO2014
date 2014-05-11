ConnectionManager = require "../src/connection_manager"

###*
# JobDispatcher class.
# @class JobDispatcher
###
class JobDispatcher
  constructor: (@connectionManager)->

  ###*
  # @method dipatchTask
  # @param {Id} id task unique id
  # @param {Collection} taskParams parameters for a task
  # @param {Function} taskSplitMethod a function taking as parameters: task parameters and number of available clients 
  ###
  dispatchTask: (id, taskParams, taskSplitMethod) ->
    packageTaskParams = (id, params) ->
      type: "params"
      taskId: id
      params: params

    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo
    splitParams = taskSplitMethod(taskParams, clients.length)
    data = (packageTaskParams(id, params) for params in splitParams)
    @connectionManager.executeJobOnPeer(@getNextClient(), id, d) for d in data

  ###*
  # Stops the specified task
  # @method stopTask
  # @param {Id} id unique id of the task that will be stopped
  ###
  stopTask: (taskId) ->
    # Stub method
    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo
    deleteTaskFromPeer(client, taskId) for client in clients
    console.log "Stopping task: ", taskId
	

  ###*
  # Returns list of currently running jobs for the specified task
  # @method getJobs
  # @param {Id} id unique id of the task that will be examined
  ###	
  getJobs: (taskId) ->
    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo
    return clients #todo
	
  
  getNextClient: ->
    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo

    @clientNum = @clientNum ? 0
    @clientNum = 0 if @clientNum >= clients.length
    clients[@clientNum++]

  clientChoiceRuleExample: (data) ->
    clients = @connectionManager.getActiveConnections()
    return null

module.exports = JobDispatcher
