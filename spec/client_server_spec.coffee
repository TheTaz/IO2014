describe "ClientServer", ->
	dispatcher = jasmine.createSpyObj 'dispatcher', ['on', 'dispatchTask']
	connectionManager = jasmine.createSpyObj 'connectionManager', ['onConnection', 'connectedClients']

	ClientServer = require "../src/client_server"
	clientServer = new ClientServer(dispatcher, connectionManager)
	
	it "add listeners to dispatcher and connectionManager", ->
		expect(dispatcher.on).toHaveBeenCalled()
		expect(connectionManager.onConnection).toHaveBeenCalled()

	it "dispatches task", ->
		func = createSpy('func')
		left = 3
		right = 33

		clientServer.dispatchTask func, left, right
		expect(dispatcher.dispatchTask).toHaveBeenCalledWith func, left, right, undefined
		
