events = require('events');


###*
# @class ResultAggregator
# @constructor  
###

class ResultAggregator

  constructor: (@connectionManager) ->
    events.EventEmitter.call this
    @results = {}

    @connectionManager.onResultReady (taskId, jobId, result) =>
      @addResultFor(taskId, jobId, result)

  ###*
  # Forget specific task
  # @method forgetTask
  # @param {Integer} taskId identifier of the task to be forgotten
  ###
  forgetTask: (taskId) ->
    @results[taskId] = null

  ###*
  # Initialize task with function to merge partial results
  # @method aggregateOn
  # @param {Integer} taskId identifier of the new task
  # @param {Function} mergeFun function aimed to merge partial results
  ###
  aggregateOn: (taskId, mergeFun) ->
    # Stub methods
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

  addResultFor: (taskId, jobId, result) ->
    if @results[taskId]
      @results[taskId].partialResults[jobId] = result

module.exports = ResultAggregator

