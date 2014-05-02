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
    @jobDispatcher = jasmine.createSpyObj("JobDispatcher", ["dispatchTask", "stopTask"])
    @resultAggregator = jasmine.createSpyObj("ResultAggregator", ["aggregateOne", "forgetTask"])
    @taskManager = new TaskManager(@jobDispatcher, @jsInjector, @resultAggregator)


  it "adds tasks", ->
    taskId = @taskManager.addTask dummyTask

    expect(@taskManager.tasks[taskId]).toContain
      taskId: @taskManager.lastTaskId
      taskProcess: dummyTask.taskProcess


  it "creates a new id for each task", ->
    @taskManager.manage dummyTask
    firstId = @taskManager.lastTaskId

    @taskManager.manage dummyTask
    secondId = @taskManager.lastTaskId

    expect(firstId).not.toBe(secondId)


  it "injects javascript code to client via JsInjector", ->
    @taskManager.manage dummyTask
    expect(@jsInjector.inject).toHaveBeenCalledWith(@taskManager.lastTaskId, dummyTask.taskProcess)


  it "dispatches jobs through JobDispatcher", ->
    @taskManager.manage dummyTask
    expect(@jobDispatcher.dispatchTask).toHaveBeenCalledWith(@taskManager.lastTaskId, dummyTask.taskParams, dummyTask.taskSplit)