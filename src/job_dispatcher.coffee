###*
# JobDispatcher class.
# @class JobDispatcher
###
class JobDispatcher
  JobStatus =
    waiting : 1
    sent : 2
    executed: 3	

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
    clients = @connectionManager.getActiveConnections()
    splitInto=Math.min(taskParams.length,10)
    if clients
      splitInto=Math.min(taskParams.length,2*clients.length)
    splitParams = taskSplitMethod(taskParams, splitInto)
    data = (packageTaskParams(id, params) for params in splitParams)
    i = 1
    for d in data
      @tasksJobsStatus[id][i]=JobStatus.waiting
      @tasksParamsWaiting[id][i]=data
      i++
    if clients
      i = 1
      for client in clients
        capabilities=@connectionManager.getPeerCapabilities(client)
        if id in capabilities
          sendParamsToPeer(client, id, i)
          i++
	  
  ###*
  # Stops dispatching and executing jobs for the specified task
  # @method stopTask
  # @param {Id} taskId unique id of the task that will be stopped
  ###
  stopTask: (taskId) ->
    delete @tasksParamsWaiting[taskId]
    clients = @connectionManager.getActiveConnections()
    if clients
      for job in @tasksJobsStatus[taskId]
        if @tasksJobsStatus[taskId][job] == JobStatus.sent
          deleteJobFromPeer(client, taskId, job) for client in clients
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
  # Serves change in peer capabilities, tries to dispatch capable tasks.
  # @method onPeerCapabilitiesChanged
  # @param {Object} peerSocket peers socket
  ###
  onPeerCapabilitiesChanged: (peerSocket) ->
    @tryToAssignAvailableJobs(peerSocket)

  ###*
  # Serves finished job, tries to dispatch capable tasks to the peer that finished the job.
  # @method onJobDone
  # @param {Object} peerSocket peers socket
  # @param {Id} taskId unique id of the task that job belongs to
  # @param {Id} jobId unique id of the job that was finished
  ###
  onJobDone: (peerSocket, taskId, jobId) ->
    @tasksJobsStatus[taskId][jobId]=JobStatus.executed
    @tryToAssignAvailableJobs(peerSocket)
	
  ###*
  # Dispatches waiting jobs to the newly connected peer.
  # @method onPeerConnected
  # @param {Object} peerSocket peers socket
  ###	
  onPeerConnected: (peerSocket) ->
    @tryToAssignAvailableJobs(peerSocket)

  ###*
  # Enqueues undone jobs after peer disconnection.
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

  ###*
  # Returns the number of jobs that should be assigned to the peer.
  # @method getNumberOfJobsToAssign
  ###
  getNumberOfJobsToAssign: ->
    jobsNumber = 0
    for task in @tasksParamsWaiting
        for job in @tasksParamsWaiting[task]
          jobsNumber++
    if jobsNumber == 0
      return 0
    peers = @connectionManager.getActiveConnections()
    if peers
      if peers.length >= jobsNumber or peers.length==0
        return jobsNumber
      else 
        return Math.max(jobsNumber/(peers.length),1)
    return Math.min(jobsNumber,4)

  ###*
  # Tries to assign to peer as many available tasks as peers capabilities and getNumberOfJobsToAssign() allows it.
  # @method tryToAssignAvailableJobs
  ###
  tryToAssignAvailableJobs: (peerSocket) ->
    capabilities = @connectionManager.getPeerCapabilities(peerSocket)
    howMany = getNumberOfJobsToAssign()
    if Object.getOwnPropertyNames(@tasksParamsWaiting).length != 0
      for task in @tasksParamsWaiting
        if task in capabilities
          for job in @tasksParamsWaiting[task]
            sendParamsToPeer(peerSocket, task, @tasksParamsWaiting[task][job])
            howMany--
            if howMany == 0
              break

module.exports = JobDispatcher
