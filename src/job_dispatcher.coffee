
class JobDispatcher
	constructor: (@connectionManager)->

	#on: (action, resultParser) ->
		
		
	dispatchTask: (taskParams, taskSplitMethod) ->
		splittedParams = taskSplitMethod taskParams
		(@connectionManager.assignTaskParamsToClient i, this.clientChoiceRuleExample i) for i in splittedParams
	    
	clientChoiceRuleExample: (data) ->
		clients = @connectionManager.connectedClients
		return null
		
module.exports = JobDispatcher