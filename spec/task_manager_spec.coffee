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
    @jsInjector = jasmine.createSpyObj("jsInjector", ["inject"])
    @jobDispatcher = jasmine.createSpyObj("jobDispatcher", ["dispatchTask"])
    @taskManager = new TaskManager(@jobDispatcher, @jsInjector)


  it "manages tasks", ->
    @taskManager.manage dummyTask

    expect(@taskManager.tasks).toContain
      id: @taskManager.lastTaskId
      task: dummyTask


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