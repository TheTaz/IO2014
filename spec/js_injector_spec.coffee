###
describe "JsInjector", ->
  JsInjector = require "../src/js_injector"

  dummyTask = null
  client = null
  jsInjector = null
  taskFunctionList = {}

  beforeEach ->
    dummyTask =
      taskId: 1;
      runFun: (inputObj) -> true
      taskFunctionList[taskId] = runFun
    @client = jasmine.createSpy "client"
    @connectionManager = jasmine.createSpyObj('connectionManager', ['getActiveConnections', 'sendNewTaskToPeer', 'deleteTaskFromPeer', 'onCodeLoaded'])
    jsInjector  = new JsInjector @connectionManager

  it "injects task processing function to clients", ->
    taskId = dummyTask.taskId
    runFun = dummyTask.runFun
    jsInjector.injectCode(taskId, runFun)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    expect(@connectionManager.sendNewTaskToPeer).toHaveBeenCalledWith(taskId, runFun)

  it "unloads tasks from clients", ->
    taskId = dummyTask.taskId
    jsInjector.unloadCode(taskId)
    expect(@connectionManager.getActiveConnections).toHaveBeenCalled
    expect(@connectionManager.deleteTaskFromPeer).toHaveBeenCalledWith(taskId)

  it "callback when code has been injected", ->
    callback = jasmine.createSpy "callback"
    jsInjector.onCodeInjected(callback)
    expect(@connectionManager.onCodeLoaded).toHaveBeenCalledWith(callback)
###