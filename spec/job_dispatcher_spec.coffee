describe "JobDispatcher", ->
  beforeEach ->
    JobDispatcher = require "../src/job_dispatcher"
    ConnectionManager = require "../src/connection_manager"
    sockets = jasmine.createSpyObj "sockets", ["on", "clients"]
    connManager = new ConnectionManager(sockets)
    jobDispatcher = new JobDispatcher(connManager)
    taskId=1
  
  it "dispatches specified task", ->
    jobDispatcher.dispatchTask taskId, [1, 2, 3], (params, n) -> [[1],[2,3]]
    expect(connManager.getActiveConnections).toHaveBeenCalled
	
  it "stops specified task", ->
    jobDispatcher.stopTask(taskId)
    expect(connManager.deleteTaskFromPeer).toHaveBeenCalled
  
  it "retrieves jobs for specified task", ->
    jobDispatcher.getJobs(taskId)
    expect(connManager.getActiveConnections).toHaveBeenCalled

  it "responds to changes in peers capabilities", ->
    jobDispatcher.onPeerCapabilitiesChanged()

  it "responds to connection of a new peer", ->
    jobDispatcher.onPeerConnected()

  it "responds to disconnection of a peer", ->
    jobDispatcher.onPeerDisconnected({})
