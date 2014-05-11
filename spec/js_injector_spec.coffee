describe "JsInjector", ->
  JsInjector = require "../src/js_injector"

  taskFunctionList = {}
  socketsState = {}

  beforeEach ->
    @sockets = jasmine.createSpyObj "sockets", ["on", "clients"]
    @connectionManager = {
      getActiveConnections: jasmine.createSpy('getActiveConnections').and.returnValue([]),
      sendNewTaskToPeer: jasmine.createSpy('sendNewTaskToPeer'),
      deleteTaskFromPeer: jasmine.createSpy('deleteTaskFromPeer'),
      onCodeLoaded: jasmine.createSpy('onCodeLoaded')
    }
    @callback = jasmine.createSpy "callback"

    @jsInjector  = new JsInjector @connectionManager

  it "injects task processing function to clients with provided runFun", ->
    taskId = 1
    runFun = "(function(){ return 0; })"
    taskFunctionList[taskId] = runFun

    @jsInjector.injectCode(taskId, runFun)
    expect(taskFunctionList[taskId]).toContain(runFun)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    for socket in @connectionManager.getActiveConnections
      expect(@connectionManager.sendNewTaskToPeer).toHaveBeenCalledWith(socket, taskId, runFun, @callback)
      expect(socketsState[socket]).toContain(taskId)

 it "injects task processing function to clients without provided runFun", ->
    taskId = 1
    runFun = "(function(){ return 0; })"
    taskFunctionList[taskId] = runFun

    @jsInjector.injectCode(taskId)
    expect(taskFunctionList[taskId]).toContain(runFun)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    for socket in @connectionManager.getActiveConnections
      expect(@connectionManager.sendNewTaskToPeer).toHaveBeenCalledWith(socket, taskId, runFun, @callback)
      expect(socketsState[socket]).toContain(taskId)   

  it "unloads tasks from clients", ->
    taskId = 1

    @jsInjector.unloadCode(taskId)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    for socket in @connectionManager.getActiveConnections
      expect(@connectionManager.deleteTaskFromPeer).toHaveBeenCalledWith(socket, taskId, @callback)
      expect(socketsState[socket]).toContain(null)   
      