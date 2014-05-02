events = require('events');

class TaskManager extends events.EventEmitter

  TaskStatus:
    new: 0
    running: 1
    done: 2
    removed: 3

  constructor: (@dispatcher, @injector, @resultAggregator) ->
    events.EventEmitter.call this
    @on 'task_state_change', @taskStateChangeCallback
    @tasks = {}


  ## API methods

  addTask: (taskObj) ->
    taskId = @newTaskId()

    console.log "TaskParams: ", taskObj.taskParams

    return false if not taskObj.taskParams?

    return false if not typeof taskObj.taskProcess       == 'function'
    return false if not typeof taskObj.taskSplit         == 'function'
    return false if not typeof taskObj.taskMerge         == 'function'
    return false if not typeof taskObj.taskResultEquals  == 'function'

    @tasks[taskId] = taskObj
    @tasks[taskId]['taskId'] = taskId
    @setTaskStatus taskId, @TaskStatus.new

    console.log "New task ID: ", taskId

    return taskId


  startTask: (taskId) ->
    task = @tasks[taskId]
    return false if not task?

    @resultAggregator.aggregateOn taskId, task.taskMerge
    @injector.injectCode taskId, task.taskProcess
    @dispatcher.dispatchTask taskId, task.taskParams, task.taskSplit

    @setTaskStatus taskId, @TaskStatus.running
    console.log task

    return true


  removeTask: (taskId) ->
    @tasks[taskId] = null

    @injector.unloadCode taskId
    @resultAggregator.forgetTask taskId
    @dispatcher.stopTask taskId

    @setTaskStatus taskId, @TaskStatus.removed


  getTaskState: (taskId) ->
    return null if not @tasks[taskId]?

    {
      status: @tasks[taskId]['status'],
      currentResult: @resultAggregator.getCurrentResult(taskId)
    }



  ## Internal methods

  newTaskId: ->
    @lastTaskId = @lastTaskId ? 0
    ++@lastTaskId

  setTaskStatus: (taskId, newState) ->
    task = @tasks[taskId]
    return false if not task?

    oldState = task["status"]
    task["status"] = newState

    @emit 'task_state_change', taskId, oldState, newState

    return true


  taskStateChangeCallback: (taskId, oldState, newState) ->
    console.log "onTaskStateChange(", taskId, ", ", oldState, ", ", newState, ")"
    return true

module.exports = TaskManager