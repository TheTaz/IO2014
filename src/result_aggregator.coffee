###*
# @class ResultAggregator
# @constructor  
###

class ResultAggregator

  constructor: (@jobDispatcher) ->
    @results = {}

  ###*
  # Forget specific task
  # @method forgetTask
  # @param {Integer} taskId identifier of the task to be forgotten
  ###
  forgetTask: (taskId) ->
    # Stub method
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
  # @return results for specified task
  ###
  getCurrentResult: (taskId) ->
    @results[taskId]

module.exports = ResultAggregator
