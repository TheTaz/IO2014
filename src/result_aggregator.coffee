###*
# @class ResultAggregator
# @constructor  
###

class ResultAggregator

  constructor: (@connectionManager) ->
    events.EventEmitter.call this
    @results = {}

    @connectionManager.onResultReady (taskId, result) ->
      @results[taskId].partialResults << result

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
      partialResults: []

  ###*
  # @method getCurrentResult
  # @param {Integer} taskId identifier of the task
  # @return partial results and merged result for specified task
  ###
  getCurrentResult: (taskId) ->
    partialResults: @results[taskId].partialResults,
    mergedResult: @results[taskId].taskMergeFun(@results[taskId].partialResults)


module.exports = ResultAggregator
