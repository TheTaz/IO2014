###*
# JobDispatcher class.
# @class JobDispatcher
###
class JobDispatcher
  JobStatus =
    waiting : 1
    sent : 2
    executing: 3	

  constructor: (@connectionManager)->
    @tasksJobs={}
    @tasksParamsWaiting={}

  ###*
  # @method dispatchTask
  # @param {Id} id task unique id
  # @param {Collection} taskParams parameters for a task
  # @param {Function} taskSplitMethod a function taking as parameters: task parameters and number of available clients 
  ###
  dispatchTask: (id, taskParams, taskSplitMethod) ->
    packageTaskParams = (id, params) ->
      type: "params"
      taskId: id
      params: params

    @tasksJobs[id]={}
    @tasksParamsWaiting[id]={}
    splitParams = taskSplitMethod(taskParams)
    data = (packageTaskParams(id, params) for params in splitParams)
    i = 1
    for d in data
      @tasksJobs[id][i]=JobStatus.waiting
      @tasksParamsWaiting[id][i]=data
      i++
    clients = @connectionManager.getActiveConnections()
    if clients
      i = 1
      for client in clients
        sendParamsToPeer(client, id, i)
        i++
	  
  ###*
  # Stops the specified task
  # @method stopTask
  # @param {Id} taskId unique id of the task that will be stopped
  ###
  stopTask: (taskId) ->
    # Stub method
    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo
    deleteTaskFromPeer(client, taskId) for client in clients
    delete @tasksJobs[taskId]
    console.log "Stopping task: ", taskId
	

  ###*
  # Returns list of currently served jobs {job : jobStatus} for the specified task
  # @method getJobs
  # @param {Id} taskId unique id of the task that will be examined
  ###	
  getJobs: (taskId) ->
    return @tasksJobs[taskId]

  peerCapabilitiesChanged: () ->

  ###*
  # Dispatches waiting jobs to the peer.
  # @method onPeerConnected
  # @param {Object} peerSocket peers socket
  ###	
  onPeerConnected: (peerSocket) ->
    if Object.getOwnPropertyNames(@tasksParamsWaiting).length != 0
      for task in @tasksParamsWaiting
        sendParamsToPeer(peerSocket, task, Object.keys(@tasksParamsWaiting[task])[0])

  onPeerDisconnected: () ->

  ###*
  # Sends parameters to the peer.
  # @method sendParamsToPeer
  # @param {Object} peers socket
  # @param {Id} taskId tasks unique id
  # @param {Id} jobId jobs unique id
  ###
  sendParamsToPeer: (peer, taskId, jobId) ->
    @connectionManager.executeJobOnPeer(peer, taskId, jobId, @tasksParamsWaiting[id][i])
    @tasksJobs[taskId][jobId]=JobStatus.sent
    delete @tasksParamsWaiting[taskId][jobId]
    if Object.getOwnPropertyNames(@tasksParamsWaiting[taskId]).length == 0
      delete @tasksParamsWaiting[taskId]

module.exports = JobDispatcher
