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
    msgId = 7
    taskId = 1
    runFun = 6
    error = 1
    operation = { msgId: msgId, data: { taskId: taskId, runFun: runFun} }
    @client.onAddNewTask operation
    expect(@socket.emit).toHaveBeenCalledWith('error', { error: error, msgId: msgId, details: { taskId: taskId } })

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
    
    deleteOperation.msgId = 17
    @client.onDeleteTask deleteOperation
    expect(@client.tasks[taskId]).toBeUndefined()
    expect(@socket.emit).toHaveBeenCalledWith('ack', { msgId: deleteMsgId })  

  it "does not execute task if it does not exist", ->
    returnResult = jasmine.createSpy 'returnResult'
    @client.returnResult = returnResult

    taskId = 10
    msgId = 13
    error = 1
    operation = { msgId: msgId, data: { taskId: taskId } }
    @client.onExecuteJob operation
    expect(@socket.emit).toHaveBeenCalledWith('error', { error: error, msgId: msgId, details: { taskId: taskId } })
    expect(returnResult).not.toHaveBeenCalled()

  it "executes task if the task exists", ->
    returnResult = jasmine.createSpy 'returnResult'
    @client.returnResult = returnResult

    msgId = 7
    taskId = 1
    operation = { msgId: msgId, data: { taskId: taskId, runFun: "({ taskProcess: function(inputObj) {
        return [inputObj.number, inputObj.begin, inputObj.end];
    } })"} }
    @client.onAddNewTask operation

    msgId = 8
    jobId = 1
    number = 1
    begin = 2
    end = 3
    jobArgs = { number: number, begin: begin, end: end }
    operation = { msgId: msgId, data: { taskId: taskId, jobId: jobId, jobArgs: jobArgs }}
    @client.onExecuteJob operation
    expect(@socket.emit).toHaveBeenCalledWith('ack', { msgId: msgId })
    expect(@client.tasks[taskId].results[jobId]).toEqual([number, begin, end])
    expect(returnResult).toHaveBeenCalledWith operation, @client.tasks[taskId].results[jobId], true

  it "executes task and throws error if the task is malformed", ->
    returnResult = jasmine.createSpy 'returnResult'
    @client.returnResult = returnResult

    msgId = 7
    taskId = 1
    operation = { msgId: msgId, data: { taskId: taskId, runFun: "({ taskProcess: function(inputObj) {
        return [inputObj.number, inputObj.begin, inputObj.end];
    }; })"} }
    @client.onAddNewTask operation

    msgId = 8
    jobId = 1
    number = 1
    begin = 2
    end = 3
    jobArgs = { number: number, begin: begin, end: end }
    operation = { msgId: msgId, data: { taskId: taskId, jobId: jobId, jobArgs: jobArgs }}
    @client.onExecuteJob operation
    expect(@socket.emit).toHaveBeenCalledWith('ack', { msgId: msgId })
    expect(@client.tasks[taskId].results[jobId]).toBeUndefined()
    expect(returnResult).not.toHaveBeenCalled()
    expect(@client.onExecuteJob).toThrowError()

  it "returns result of a operation without retry", ->
    taskId = 1
    jobId = 1
    result = [1, 2, 3]
    @client.tasks[taskId] = {}
    @client.tasks[taskId].results = {}
    @client.tasks[taskId].results[jobId] = result

    operation = { data: { taskId: taskId, jobId: jobId } }
    msgId = @client.lastClientMsgId - 1
    taskResult = { 
      msgId: msgId, 
      data: { 
        taskId: taskId,
        jobId: jobId,
        jobResult: result
      }
    }

    @client.returnResult operation, result, false
    expect(@socket.emit).toHaveBeenCalledWith 'result', taskResult
