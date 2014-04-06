describe "ConnectionManager", ->
    sockets = jasmine.createSpyObj 'sockets', ['on', 'clients']
    ConnectionManager = require "../src/connection_manager"
    connectionManager = new ConnectionManager(sockets)

    it "returns list of connected clients", -> 
        connectionManager.connected_clients()
        expect(sockets.clients).toHaveBeenCalled()

    it "executes function on connection", ->
        callback = jasmine.createSpy 'callback'
        connectionManager.on_connection callback
        expect(sockets.on).toHaveBeenCalled()
