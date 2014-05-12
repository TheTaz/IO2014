JobDispatcher = require "../src/job_dispatcher"
ConnectionManager = require "../src/connection_manager"

describe "JobDispatcher", ->
  sockets = null
  connManager = null
  jobDispatcher = null
  taskId=1

  beforeEach ->
    sockets = jasmine.createSpyObj "sockets", ["on", "clients"]
    connManager = jasmine.createSpyObj "connManager", ["getActiveConnections","deleteJobFromPeer","getPeerCapabilities","executeJobOnPeer"]
    getConn = () -> ["client1","client2"]
    connManager.getActiveConnections.andCallFake(getConn)
    getCap = (socket, taskId, jobId) -> [1]
    connManager.getPeerCapabilities.andCallFake(getCap)
    jobDispatcher = new JobDispatcher(connManager)

  it "dispatches specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    expect(jobDispatcher.tasksJobsStatus[taskId]).toEqual({1 : 2, 2 : 2})
    expect(connManager.getActiveConnections).toHaveBeenCalled()
    expect(connManager.executeJobOnPeer).toHaveBeenCalled()
	
  it "stops specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.stopTask(taskId)
    expect(connManager.deleteJobFromPeer).toHaveBeenCalledWith("client1",1,'1')
    expect(connManager.deleteJobFromPeer).toHaveBeenCalledWith("client1",1,'2')
    expect(connManager.deleteJobFromPeer).toHaveBeenCalledWith("client2",1,'1')
    expect(connManager.deleteJobFromPeer).toHaveBeenCalledWith("client2",1,'2')
  
  it "retrieves jobs for specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    result=jobDispatcher.getJobs(taskId)
    expect(result).toEqual({1 : 2, 2 : 2})

  it "responds to changes in peers capabilities", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    jobDispatcher.onPeerCapabilitiesChanged()
    expect(connManager.getPeerCapabilities).toHaveBeenCalled()
    expect(connManager.executeJobOnPeer).toHaveBeenCalled()

  it "responds to connection of a new peer", ->
    #jobDispatcher.onPeerConnected()

  it "responds to disconnection of a peer", ->
    #jobDispatcher.onPeerDisconnected({})
