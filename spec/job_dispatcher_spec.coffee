JobDispatcher = require "../src/job_dispatcher"

describe "JobDispatcher", ->
  sockets = null
  connManager = null
  injector = null
  jobDispatcher = null
  taskId=1

  beforeEach ->
    sockets = jasmine.createSpyObj "sockets", ["on", "clients"]
    connManager = jasmine.createSpyObj "connManager", ["getActiveConnections","deleteJobFromPeer","executeJobOnPeer","onPeerConnected","onPeerDisconnected","onJobDone"]
    getConn = () -> ["client1"]
    connManager.getActiveConnections.and.callFake(getConn)
    injector = jasmine.createSpyObj "injector", ["getPeerCapabilities","onPeerCapabilitiesChanged"]
    getCap = (socket, taskId, jobId) -> [1]
    injector.getPeerCapabilities.and.callFake(getCap)
    jobDispatcher = new JobDispatcher(connManager,injector)

  it "dispatches specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    expect(connManager.getActiveConnections).toHaveBeenCalled()
    expect(connManager.executeJobOnPeer).toHaveBeenCalled()
    expect(jobDispatcher.tasks.getTaskJobs(taskId).length).toEqual(2)

  it "stops specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.stopJob(taskId,2)
    expect(connManager.deleteJobFromPeer).toHaveBeenCalled()
  
  it "retrieves jobs for specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    result=jobDispatcher.getJobs(taskId)
    expect(jobDispatcher.tasks.getTaskJobs(taskId).length).toEqual(2)

  it "responds to changes in peers capabilities", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.onPeerCapabilitiesChanged("client1")
    #expect(jobDispatcher.tasks.getTaskIds()).toEqual("test")
    expect(injector.getPeerCapabilities).toHaveBeenCalled()
    expect(connManager.executeJobOnPeer).toHaveBeenCalled()

  it "responds to connection of a new peer", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.onPeerConnected("client1")
    expect(injector.getPeerCapabilities).toHaveBeenCalled()
    expect(connManager.executeJobOnPeer).toHaveBeenCalled()

  it "responds to disconnection of a peer", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.onPeerDisconnected("client1")
    jobs=jobDispatcher.tasks.getTaskJobs(taskId)
    for job in jobs
      expect(job.isWaiting()).toBe(true)

  it "responds to job finished by a peer", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.onJobDone("client1",taskId,1)
    expect(jobDispatcher.tasks.getJob(taskId,1).isExecuted()).toBe(true)
    expect(injector.getPeerCapabilities).toHaveBeenCalled()
    expect(connManager.executeJobOnPeer).toHaveBeenCalled()
