
describe "JsInjector", ->
  JsInjector = require "../src/js_injector"

  taskFunctionList = {}
  socketsState = {}

  beforeEach ->
    @sockets = jasmine.createSpyObj "sockets", ["on", "clients"]
    @connectionManager = jasmine.createSpyObj('connectionManager', ['getActiveConnections', 'sendNewTaskToPeer', 'deleteTaskFromPeer', 'onCodeLoaded'])
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

 it "injects task processing function to clients without provided runFun", ->
    taskId = 1
    runFun = "(function(){ return 0; })"
    taskFunctionList[taskId] = runFun

    @jsInjector.injectCode(taskId)
    expect(taskFunctionList[taskId]).toContain(runFun)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    expect(@connectionManager.sendNewTaskToPeer).toHaveBeenCalledWith(socket, taskId, runFun, @callback)   

  it "unloads tasks from clients", ->
    taskId = 1

    @jsInjector.unloadCode(taskId)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    expect(@connectionManager.deleteTaskFromPeer).toHaveBeenCalledWith(socket, taskId, @callback)
