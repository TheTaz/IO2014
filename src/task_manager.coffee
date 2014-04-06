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
    # will send appropriate parts of the task to dispatcher and injector

module.exports = TaskManager