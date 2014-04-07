describe "JobDispatcher", ->
	JobDispatcher = require "../src/job_dispatcher"
	connectionManager = jasmine.createSpyObj 'connectionManager', ['connectedClients', 'assignTaskParamsToClient']
	jobDispatcher = new JobDispatcher connectionManager

	it "connects with connection manager to retrieve clients and assign task", ->
	
		jobDispatcher.dispatchTask [1, 2, 3], (params) -> [[1],[2,3]]
		expect(connectionManager.connectedClients).toHaveBeenCalled
		expect(connectionManager.assignTaskParamsToClient).toHaveBeenCalled
