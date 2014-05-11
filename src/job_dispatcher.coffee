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
    @tasksJobsStatus={}
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

    @tasksJobsStatus[id]={}
    @tasksParamsWaiting[id]={}
    splitParams = taskSplitMethod(taskParams)
    data = (packageTaskParams(id, params) for params in splitParams)
    i = 1
    for d in data
      @tasksJobsStatus[id][i]=JobStatus.waiting
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
    delete @tasksJobsStatus[taskId]
    console.log "Stopping task: ", taskId
	

  ###*
  # Returns list of currently served jobs {job : jobStatus} for the specified task
  # @method getJobs
  # @param {Id} taskId unique id of the task that will be examined
  ###	
  getJobs: (taskId) ->
    return @tasksJobsStatus[taskId]
  
  ###*
  # Serves change in peer capabilities.
  # @method onPeerCapabilitiesChangeds
  # @param {Object} peerSocket peers socket
  # @param {Object} executingJobs info about jobs currently in execution
  # @param {Object} rejectedJobs info about jobs rejected by peer
  # @param {Integer} jobsPeerCanTake number of jobs peer can still take
  ###
  onPeerCapabilitiesChanged: (peerSocket, executingJobs, rejectedJobs, jobsPeerCanTake) ->
    if executingJobs
      for task in executingJobs
        for job in executingJobs[task]
          @tasksJobsStatus[task][job]=JobStatus.executing
    if rejectedJobs
      for task in rejectedJobs
        for job in rejectedJobs[task]
          @tasksParamsWaiting[task][job]=rejectedJobs[task][job]
          @tasksJobsStatus[task][job]=JobStatus.waiting
    if Object.getOwnPropertyNames(@tasksParamsWaiting).length != 0
      for task in @tasksParamsWaiting
        for job in @tasksParamsWaiting[task]
          sendParamsToPeer(peerSocket, task, @tasksParamsWaiting[task][job])		

  ###*
  # Dispatches waiting jobs to the peer.
  # @method onPeerConnected
  # @param {Object} peerSocket peers socket
  ###	
  onPeerConnected: (peerSocket) ->
    if Object.getOwnPropertyNames(@tasksParamsWaiting).length != 0
      for task in @tasksParamsWaiting
        for job in @tasksParamsWaiting[task]
          sendParamsToPeer(peerSocket, task, @tasksParamsWaiting[task][job])

  ###*
  # Dispatches waiting jobs to the peer.
  # @method onPeerDisconnected
  # @param {Object} jobsToReassign {taskId : {jobId : jobParams}}
  ###
  onPeerDisconnected: (jobsToReassign) ->
    for task in jobsToReassign
      for job in jobsToReassign[task]
        @tasksParamsWaiting[task][job]=jobsToReassign[task][job]
        @tasksJobsStatus[task][job]=JobStatus.waiting
	
  ###*
  # Sends parameters to the peer.
  # @method sendParamsToPeer
  # @param {Object} peers socket
  # @param {Id} taskId tasks unique id
  # @param {Id} jobId jobs unique id
  ###
  sendParamsToPeer: (peer, taskId, jobId) ->
    @connectionManager.executeJobOnPeer(peer, taskId, jobId, @tasksParamsWaiting[id][i])
    @tasksJobsStatus[taskId][jobId]=JobStatus.sent
    delete @tasksParamsWaiting[taskId][jobId]
    if Object.getOwnPropertyNames(@tasksParamsWaiting[taskId]).length == 0
      delete @tasksParamsWaiting[taskId]

module.exports = JobDispatcher
