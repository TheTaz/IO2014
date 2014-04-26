class JobDispatcher
  constructor: (@connectionManager)->

  dispatchTask: (id, taskParams, taskSplitMethod) ->
    packageTaskParams = (id, params) ->
      type: "params"
      taskId: id
      params: params

    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo

    splitParams = taskSplitMethod(taskParams, clients.length)
    data = (packageTaskParams(id, params) for params in splitParams)
    @connectionManager.send(@getNextClient(), d) for d in data

  getNextClient: ->
    clients = @connectionManager.getActiveConnections()
    if (not clients?) then return undefined #todo

    @clientNum = @clientNum ? 0
    @clientNum = 0 if @clientNum >= clients.length
    clients[@clientNum++]

  clientChoiceRuleExample: (data) ->
    clients = @connectionManager.getActiveConnections()
    return null

module.exports = JobDispatcher
