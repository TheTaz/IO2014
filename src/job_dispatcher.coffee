###*
# JobDispatcher class.
# @class JobDispatcher
###
class JobDispatcher
  class Job
    JobStatus =
      waiting : 1
      sent : 2
      executed: 3	
    
	constructor: (@id, @params) ->
      @status=JobStatus.waiting
      @peer=undefined
    
    setAsWaiting: ->
      @peer=undefined
      @status=JobStatus.waiting
	
    setAsSent: (peer) ->
      @peer=peer
      @status=JobStatus.sent
    
    setAsExecuted: ->
      @peer=undefined
      @status=JobStatus.executed
    
    isWaiting: ->
      return @status==JobStatus.waiting

    isSent: ->
      return @status==JobStatus.sent
    
    isExecuted: ->
      return @status==JobStatus.executed
  
  class TaskCollection
    constructor: ->
      @taskJobs={}
    
    addTask: (taskId) ->
      if(@taskJobs[taskId]==undefined)
        @taskJobs[taskId]=[]
    
    addJobToTask: (job, taskId) ->
      @taskJobs[taskId].push(job)
    
    removeTask: (taskId) ->
      delete @taskJobs[taskId]
    
    removeJobFromTask: (job, taskId) ->
      @taskJobs[taskId]=@taskJobs[taskId].filter (j) -> j isnt job
    
    getTaskIds: ->
      return Object.keys(@taskJobs)	
	
    getTaskJobs: (taskId) ->
      return @taskJobs[taskId]
    
    getTaskWaitingJobs: (taskId) ->
      jobs=[]
      for job in @taskJobs[taskId]
        if job.isWaiting
          jobs.push(job)
      return jobs
    
    getWaitingJobs: ->
      jobs={}
      for task in @getTaskIds()
        waiting=@getTaskWaitingJobs()
        if waiting!=[]
          jobs[task]=waiting
      return jobs

  ###*
  # Provides the mechanism for creating and managing jobs.
  # @class JobDispatcher
  # @constructor
  # @param {Object} reference to connection manager
  # @param {Object} reference to js injector
  ###
  constructor: (@connectionManager, @jsInjector)->
    @tasks=new TaskCollection()

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

    @tasks.addTask(id)
    clients = @connectionManager.getActiveConnections()
    splitInto=Math.min(taskParams.length,10)
    if clients
      splitInto=Math.min(taskParams.length,2*clients.length)
    splitParams = taskSplitMethod(taskParams, splitInto)
    data = (packageTaskParams(id, params) for params in splitParams)
    i = 1
    for d in data
      @tasks.addJobToTask((new Job(i,data)),id)
      i++
    if clients #todo clients len < params len
      i = 1
      for client in clients
        capabilities=@jsInjector.getPeerCapabilities(client)
        if id in capabilities
          @sendParamsToPeer(client, id, @tasks.getJobTasks(id)[i])
          i++

  ###*
  # Stops dispatching and executing job.
  # @method stopJob
  # @param {Id} taskId unique id of the task that job belongs to.
  # @param {Id} jobId id of the job to be stopped.
  ###
  stopJob: (taskId, jobId) ->
    for job in @tasks.getTaskJobs(taskId)
      if job.id==jobId and job.isSent()
        @connectionManager.deleteJobFromPeer(job.peer, taskId, job.id)
		@tasks.removeJobFromTask(job,taskId)
        console.log "Stopping task: ", taskId

  ###*
  # Returns list of currently served jobs {job : jobStatus} for the specified task
  # @method getJobs
  # @param {Id} taskId unique id of the task that will be examined
  ###	
  getJobs: (taskId) ->
    return @tasks.getTaskJobs(taskId)
  
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
    taskJobs=@tasks.getTaskJobs(taskId)
    for job in taskJobs
      if job.id==jobId
        job.setAsExecuted()
    @tryToAssignAvailableJobs(peerSocket)
	
  ###*
  # Dispatches waiting jobs to the newly connected peer.
  # @method onPeerConnected
  # @param {Object} peerSocket peers socket
  ###	
  onPeerConnected: (peerSocket) ->
    @tryToAssignAvailableJobs(peerSocket)

  ###*
  # Sets undone jobs as waiting after peer disconnection.
  # @method onPeerDisconnected
  # @param {Object} peers socket
  ###
  onPeerDisconnected: (peerSocket) ->
    for task in tasks.getTaskIds()
      for job in tasks.getTaskJobs(task)
        if job.peer == peerSocket
          job.setAsWaiting()
	
  ###*
  # Sends parameters to the peer.
  # @method sendParamsToPeer
  # @param {Object} peers socket
  # @param {Id} taskId tasks unique id
  # @param {Id} jobId jobs unique id
  ###
  sendParamsToPeer: (peer, taskId, job) ->
    @connectionManager.executeJobOnPeer(peer, taskId, job.id, job.params)
    job.setAsSent(peer)

  ###*
  # Returns the number of jobs that should be assigned to the peer.
  # @method getNumberOfJobsToAssign
  ###
  getNumberOfJobsToAssign: ->
    jobsNumber = 0
    waiting=@tasks.getWaitingJobs()
    for task in Object.keys(waiting)
        for job in waiting[task]
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
    capabilities = @jsInjector.getPeerCapabilities(peerSocket)
    howMany = @getNumberOfJobsToAssign()
	waiting=@tasks.getWaitingJobs()
    for task in Object.keys(waiting)
        if task in capabilities
          for job in @tasksParamsWaiting[task]
            @sendParamsToPeer(peerSocket, task, job.params)
            howMany--
            if howMany == 0
              break

module.exports = JobDispatcher
