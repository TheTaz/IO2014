describe "Client", ->
  Client = require "../src/public_scripts/client"

  beforeEach ->
    @socket = jasmine.createSpyObj "socket", ["on", "emit", "removeListener"]
    @client = new Client(@socket)

  it "adds event listener", ->
    event = "test_event"
    listener = jasmine.createSpy "listener"
    @client.addEventListener event, listener
    expect(@socket.on).toHaveBeenCalledWith(event, listener)

  it "removes event listener", ->
    event = "test_event"
    listener = jasmine.createSpy "listener"
    @client.removeEventListener event, listener
    expect(@socket.removeListener).toHaveBeenCalledWith(event, listener)

  it "adds new task", ->
    msgId = 7
    taskId = 1
    operation = { msgId: msgId, data: { taskId: taskId, runFun: "testFun"} }
    @client.onAddNewTask operation
    expect(@client.tasks[taskId].task).not.toBeUndefined()
    expect(@client.tasks[taskId].task).not.toBeNull()
    expect(@socket.emit).toHaveBeenCalledWith('ack', { msgId: msgId })

  it "does not add new task if type does not match", ->
    operation = { msgId: 7, data: { taskId: 1, runFun: 6} }
    @client.onAddNewTask operation
    expect(@socket.emit).toHaveBeenCalledWith('error', { error: 1, msgId: 7, details: { taskId: 1 } })

  it "deletes task", ->
    msgId = 7
    taskId = 1
    operation = { msgId: msgId, data: { taskId: taskId, runFun: "testFun"} }
    @client.onAddNewTask operation
    deleteMsgId = 6
    deleteOperation = { msgId: deleteMsgId, data: { taskId: taskId }}
    @client.onDeleteTask deleteOperation
    expect(@client.tasks[taskId]).toBeUndefined()
    expect(@socket.emit).toHaveBeenCalledWith('ack', { msgId: deleteMsgId })  
