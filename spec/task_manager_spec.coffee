describe "TaskManager", ->
  TaskManager = require "../src/task_manager"

  dummyTask =
    taskParams: true
    taskProcess: (inputObj) -> true
    taskResultEquals: (a, b) -> true
    taskSplit: (inputObj, n) -> [inputObj]
    taskMerge: (chunkData) ->
      input: null
      output: true


  beforeEach ->
    @jsInjector = jasmine.createSpyObj("jsInjector", ["injectCode", "unloadCode"])
    @jobDispatcher = jasmine.createSpyObj("jobDispatcher", ["dispatchTask", "stopTask"])
    @resultAggregator = jasmine.createSpyObj("ResultAggregator", ["aggregateOn", "forgetTask", "getCurrentResult"])
    @taskManager = new TaskManager(@jobDispatcher, @jsInjector, @resultAggregator)


  it "add tasks", ->
    taskId = @taskManager.addTask dummyTask

    expect(taskId).toBe @taskManager.lastTaskId

    addedTask = @taskManager.tasks[taskId]

    dummyTask.taskId = @taskManager.lastTaskId
    dummyTask.status = TaskManager::TaskStatus.new
    expect(addedTask).toEqual dummyTask


  it "creates a new id for each task", ->
    @taskManager.addTask dummyTask
    firstId = @taskManager.lastTaskId

    @taskManager.addTask dummyTask
    secondId = @taskManager.lastTaskId

    expect(firstId).not.toBe(secondId)


  it "gets current state for the started task", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.startTask taskId

    obj = new Object()
    @resultAggregator.getCurrentResult.and.returnValue(obj)

    state = @taskManager.getTaskState taskId

    expect(state.status).toBe(TaskManager::TaskStatus.running)
    expect(state.currentResult).toBe(obj)


  it "gets current state for the not started task", ->
    taskId = @taskManager.addTask dummyTask
    state = @taskManager.getTaskState taskId

    expect(state.status).toBe(TaskManager::TaskStatus.new)


  it "changes status on start", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.startTask taskId

    expect(@taskManager.getTaskState(taskId).status).toBe TaskManager::TaskStatus.running


  it "injects javascript code to client via JsInjector", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.startTask taskId
    expect(@jsInjector.injectCode).toHaveBeenCalledWith(taskId, dummyTask.taskProcess)


  it "dispatches jobs through JobDispatcher", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.startTask taskId
    expect(@jobDispatcher.dispatchTask).toHaveBeenCalledWith(taskId, dummyTask.taskParams, dummyTask.taskSplit)


  it "initializes result aggregator for the task", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.startTask taskId
    expect(@resultAggregator.aggregateOn).toHaveBeenCalledWith(taskId, dummyTask.taskMerge)


  it "unloads javascript code from client via JsInjector", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.removeTask taskId
    expect(@jsInjector.unloadCode).toHaveBeenCalledWith(taskId)


  it "removes jobs through JobDispatcher", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.removeTask taskId
    expect(@jobDispatcher.stopTask).toHaveBeenCalledWith(taskId)


  it "disables the task in result aggregator", ->
    taskId = @taskManager.addTask dummyTask
    @taskManager.removeTask taskId
    expect(@resultAggregator.forgetTask).toHaveBeenCalledWith(taskId)


  it "fails to get state for non-existing task", ->
    expect(@taskManager.getTaskState(@taskManager.lastTaskId + 1)).toBeNull()


  it "fails to start non-existing task", ->
    expect(@taskManager.startTask(@taskManager.lastTaskId + 1)).toBeFalsy()


  it "fails to remove for non-existing task", ->
    expect(@taskManager.removeTask(@taskManager.lastTaskId + 1)).toBeFalsy()
