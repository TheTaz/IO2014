events = require('events');


###*
# @class ResultAggregator
# @constructor  
###
class ResultAggregator

  constructor: (@connectionManager) ->
    events.EventEmitter.call this
    @results = {}

    @connectionManager.onResult (socket, payload) =>
      @addResultFor(payload.taskId, payload.jobId, payload.jobResult)

  ###*
  # Forget specific task
  # @method forgetTask
  # @param {Integer} taskId identifier of the task to be forgotten
  ###
  forgetTask: (taskId) ->
    delete @results[taskId]

  ###*
  # Initialize task with function to merge partial results
  # @method aggregateOn
  # @param {Integer} taskId identifier of the new task
  # @param {Function} mergeFun function aimed to merge partial results
  ###
  aggregateOn: (taskId, mergeFun) ->
    @results[taskId] =
      taskMergeFun: mergeFun,
      partialResults: {}

  ###*
  # @method getCurrentResult
  # @param {Integer} taskId identifier of the task
  # @return partial results and merged result for specified task
  ###
  getCurrentResult: (taskId) ->
    if @results[taskId]
      partialResults: @results[taskId].partialResults,
      mergedResult: @results[taskId].taskMergeFun(result for jobId, result of @results[taskId].partialResults)

  ###*
  # Aggregates result for given job in given task
  # @method addResultFor
  # @param {Integer} taskId identifier of the task
  # @param {Integer} jobId identifier of the job
  # @param {Object} result task result
  ###
  addResultFor: (taskId, jobId, result) ->
    if @results[taskId]
      @results[taskId].partialResults[jobId] = result

module.exports = ResultAggregator

