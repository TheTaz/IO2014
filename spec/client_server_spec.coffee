describe "ClientServer", ->
	dispatcher = jasmine.createSpyObj 'dispatcher', ['on', 'dispatchTask']
	connectionManager = jasmine.createSpyObj 'connectionManager', ['onConnection', 'connectedClients']

	ClientServer = require "../src/client_server"
	clientServer = new ClientServer(dispatcher, connectionManager)
	
	
