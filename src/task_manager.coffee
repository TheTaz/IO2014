events = require('events');

class TaskManager
  constructor: (@dispatcher, @injector) ->
    events.EventEmitter.call this
    @tasks = []

  newTaskId: ->
    @lastTaskId = @lastTaskId ? 0
    ++@lastTaskId

  manage: (taskObj) ->
    @tasks.push
      id: @newTaskId()
      task: taskObj

    @injector.inject(@lastTaskId, taskObj.taskProcess)
    @dispatcher.dispatchTask(@lastTaskId, taskObj.taskParams, taskObj.taskSplit)
    # should create a result aggregator that will wait for tasks to finish

module.exports = TaskManager