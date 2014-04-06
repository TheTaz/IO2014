describe "TaskManager", ->
  TaskManager = require "../src/task_manager"

  dummyTask =
    taskProcess: (inputObj) -> true
    taskResultEquals: (a, b) -> true
    taskSplit: (inputObj, n) -> [inputObj]
    taskMerge: (chunkData) ->
      input: null
      output: true


  beforeEach ->
    @taskManager = new TaskManager(undefined, undefined)


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
