ConnectionManager = require "../src/connection_manager"

###*
# JobDispatcher class.
# @class JobDispatcher
###
class JobDispatcher
  JobStatus =
    sent : 1
    executing: 2	

  constructor: (@connectionManager)->
    @tasksJobs={}

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
    @tasksJobs[id]={}
    splitParams = taskSplitMethod(taskParams, clients.length)
    data = (packageTaskParams(id, params) for params in splitParams)
    i = 1
    for d in data
      @connectionManager.executeJobOnPeer(@getNextClient(), id, i, d)
      @tasksJobs[id][i]=JobStatus.sent

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
    delete @tasksJobs[taskId]
    console.log "Stopping task: ", taskId
	

  ###*
  # Returns list of currently serverd jobs {job : jobStatus} for the specified task
  # @method getJobs
  # @param {Id} id unique id of the task that will be examined
  ###	
  getJobs: (taskId) ->
    return @tasksJobs[taskId]
	
  
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
