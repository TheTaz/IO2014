ConnectionManager = require "../src/connection_manager"

describe "ConnectionManager", ->
    describe "is a wrapper for socket.io", ->
        beforeEach ->
            @sockets = jasmine.createSpyObj 'sockets', ['on', 'clients']
            @connectionManager = new ConnectionManager(@sockets)

        it "notify when a peer is connected", ->
            @connectionManager.onPeerConnected(@callback)
            expect(@sockets.on).toHaveBeenCalledWith("connection", jasmine.any(Function))

        it "notify when a peer is disconnected", ->
            @connectionManager.onPeerDisconnected(@callback)
            expect(@sockets.on).toHaveBeenCalledWith("disconnect", jasmine.any(Function))

        it "notify when code is loaded", ->
            @connectionManager.onCodeLoaded(@callback)
            expect(@sockets.on).toHaveBeenCalledWith("code_loaded", jasmine.any(Function))

        it "notify when partial result is ready", ->
            @connectionManager.onResultReady(@callback)
            expect(@sockets.on).toHaveBeenCalledWith("result_ready", jasmine.any(Function))

        it "fetches connected clients", ->
            @connectionManager.getActiveConnections()
            expect(@sockets.clients).toHaveBeenCalled()


