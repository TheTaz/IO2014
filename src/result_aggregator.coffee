class ResultAggregator

  constructor: (@jobDispatcher) ->
    @results = {}


  ## API methods

  forgetTask: (taskId) ->
    # Stub method
    @results[taskId] = null

  aggregateOn: (taskId, mergeFun) ->
    # Stub methods
    @results[taskId] =
      taskMergeFun: mergeFun,
      partialResults: {}

  getCurrentResult: (taskId) ->
    # Stub method
    null

module.exports = ResultAggregator
