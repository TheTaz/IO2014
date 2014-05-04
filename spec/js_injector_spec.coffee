
describe "JsInjector", ->
  JsInjector = require "../src/js_injector"

  @connectionManager = jasmine.createSpyObj('connectionManager', ['getActiveConnections', 'sendNewTaskToPeer', 'deleteTaskFromPeer', 'onCodeLoaded'])
  @jsInjector  = new JsInjector(@connectionManager)

  before each ->
    @dummytask =
      taskId = 0;
      runFun = (inputObj) -> true

  it "injects task processing function to clients", ->
    @jsInjector.injectCode @dummytask.taskId @dummytask.runFun
    expect(connectionManager.getActiveConnections).toHaveBeenCalled
    expect(connectionManager.sendNewTaskToPeer).toHaveBeenCalled

  it "unloads tasks from clients", ->
    @jsInjector.unloadCode @dummytask.taskId
    expect(connectionManager.getActiveConnections).toHaveBeenCalled
    expect(connectionManager.deleteTaskFromPeer).toHaveBeenCalled

  it "callback when code has been injected", ->
    @jsInjector.onCodeInjected
    expect(connectionManager.onCodeLoaded).toHaveBeenCalled