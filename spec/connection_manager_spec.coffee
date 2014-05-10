ConnectionManager = require "../src/connection_manager"

describe "ConnectionManager", ->
  describe "as a wrapper for socket.io", ->
    beforeEach ->
      @sockets = jasmine.createSpyObj "sockets", ["on", "clients"]
      @connectionManager = new ConnectionManager(@sockets)
      @callback = jasmine.createSpy "callback"

    it "notifies when a peer is connected", ->
      @connectionManager.onPeerConnected(@callback)
      expect(@sockets.on).toHaveBeenCalledWith("connection", @callback)

    it "notifies when a peer is disconnected", ->
      @connectionManager.onPeerDisconnected(@callback)
      expect(@sockets.on).toHaveBeenCalledWith("disconnect", @callback)

    it "fetches connected clients", ->
      @connectionManager.getActiveConnections()
      expect(@sockets.clients).toHaveBeenCalled()
