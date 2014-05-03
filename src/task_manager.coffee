events = require('events');

###*
# TaskManager class.
# @class TaskManager
###
class TaskManager extends events.EventEmitter

  TaskStatus:
    ###*
    # Status for newly added tasks
    # @attribute TaskStatus.new
    ###
    new: 0

    ###*
    # Status for started tasks
    # @attribute TaskStatus.running
    ###
    running: 1

    ###*
    # Status for completed tasks
    # @attribute TaskStatus.done
    ###
    done: 2

    ###*
    # Status for removed tasks
    # @attribute TaskStatus.removed
    ###
    removed: 3

    ###*
    # Status for failed tasks
    # @attribute TaskStatus.failed
    ###
    failed: 4

  constructor: (@dispatcher, @injector, @resultAggregator) ->
    events.EventEmitter.call this
    @on 'task_state_change', @taskStateChangeCallback
    @tasks = {}


  ## API methods

  ###*
  # Registers given task. Note that this method does NOT start the task
  # nor initializes it.
  # @method addTask
  # @param {Object} taskObj Structure of the task's object shall be same as in example_task.js
  # @return {Integer} new task ID. throws {Error} when task object is invalid
  ###
  addTask: (taskObj) ->
    taskId = @newTaskId()

    if not taskObj.taskParams?
      throw new Error("Invalid taskParams object")

    if typeof taskObj.taskProcess != 'function'
      throw new Error("Invalid taskProcess function")

    if typeof taskObj.taskSplit != 'function'
      throw new Error("Invalid taskSplit function")

    if typeof taskObj.taskMerge != 'function'
      throw new Error("Invalid taskMerge function")

    if typeof taskObj.taskResultEquals != 'function'
      throw new Error("Invalid taskResultEquals function")

    @tasks[taskId] = taskObj
    @tasks[taskId].taskId = taskId
    @setTaskStatus taskId, @TaskStatus.new

    return taskId

  ###*
  # Starts (runs) task with given ID. This initializes task in ResultAggregator and JsInjector
  # and dispatches jobs though JobDispatcher
  # @method startTask
  # @param {Integer} taskId ID of the task that was returned by @addTask method
  # @return {Boolean} True if everything is like it should be. False on error.
  ###
  startTask: (taskId) ->
    task = @tasks[taskId]
    return false if not task?

    @resultAggregator.aggregateOn taskId, task.taskMerge
    @injector.injectCode taskId, task.taskProcess
    @dispatcher.dispatchTask taskId, task.taskParams, task.taskSplit

    @setTaskStatus taskId, @TaskStatus.running

    return true


  ###*
  # Removes and stops task with given ID. Task is interrupted and its results are deleted.
  # @method removeTask
  # @param {Integer} taskId ID of the task that was returned by @addTask method
  ###
  removeTask: (taskId) ->
    delete @tasks[taskId]

    @injector.unloadCode taskId
    @resultAggregator.forgetTask taskId
    @dispatcher.stopTask taskId

    @setTaskStatus taskId, @TaskStatus.removed

  ###*
  # Gets current state of task with given ID.
  # @method getTaskState
  # @param {Integer} taskId ID of the task that was returned by @addTask method
  # @return {Object} Returned object contains @TaskStatus in 'status' field and
  # current result in 'currentResult'. 'currentResult' object is the same as one returned
  # by ResultAggregator.getCurrentResult.
  ###
  getTaskState: (taskId) ->
    return null if not @tasks[taskId]?

    {
      status: @tasks[taskId].status,
      currentResult: @resultAggregator.getCurrentResult(taskId)
    }

  ###*
  # Sets new status for task with given ID. Designed for use with ResultAggregator
  # for changing task status to TaskStatus.done or TaskStatus.failed
  # @method setTaskStatus
  # @param {Integer} taskId ID of the task that was returned by @addTask method
  # @param {TaskStatus} newState new status for the task
  # @return {Boolean} False if given task does not exist, True otherwise.
  ###
  setTaskStatus: (taskId, newStatus) ->
    task = @tasks[taskId]
    return false if not task?

    oldStatus = task.status
    task.status = newStatus

    @emit 'task_state_change', taskId, oldStatus, newStatus

    return true


  ## Internal methods

  newTaskId: ->
    @lastTaskId = @lastTaskId ? 0
    ++@lastTaskId

  ###*
  # Callback function. This function is called every time task's status has changed.
  # @method taskStateChangeCallback
  # @param {Integer} taskId ID of the task that was returned by @addTask method
  # @param {TaskStatus} oldStatus old status for the task
  # @param {TaskStatus} newStatus new status for the task
  ###
  taskStateChangeCallback: (taskId, oldStatus, newStatus) ->
    task = @tasks[taskId]
    return if not task? || not task.owner?

    try
      switch newStatus
        when @TaskStatus.done
          task.owner.emit('result', @getTaskState(taskId).currentResult)
        when @TaskStatus.failed
          task.owner.emit('result', "Task failed!")
        when @TaskStatus.removed
          task.owner.emit('result', "Task removed!")
    catch err
      console.log "Notification failed for: new task status: ", newStatus, ", task: ", taskId, " due to: ", err

module.exports = TaskManager
