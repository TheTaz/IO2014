describe "ConnectionManager", ->
  ConnectionManager = require "../src/connection_manager"

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

    it "generates new message object", ->
      msgId =  0
      @connectionManager.lastServerMsgId = msgId
      message = @connectionManager.generateNewMessage()
      expect(message).toEqual({msgId: msgId + 1, data: null})
      expect(@connectionManager.lastServerMsgId).toEqual(msgId + 1)

    it "generates new message object for every client operation", ->
      generateNewMessage = jasmine.createSpy "generateNewMessage"
      @connectionManager.generateNewMessage = generateNewMessage

      @connectionManager.sendNewTaskToPeer()
      expect(generateNewMessage).toHaveBeenCalled

      @connectionManager.deleteTaskFromPeer()
      expect(generateNewMessage).toHaveBeenCalled

      @connectionManager.executeJobOnPeer()
      expect(generateNewMessage).toHaveBeenCalled

    it "sends new task to a client", ->
      socket = jasmine.createSpyObj "socket", ["emit"]
      taskId = 1
      runFun = "(function(){ return 0; })"
      callback = jasmine.createSpy "callback"

      msgId = @connectionManager.sendNewTaskToPeer socket, taskId, runFun, callback
      expect(msgId).toBeDefined()
      expect(@connectionManager.responseCallbacks[msgId]).toEqual({ taskId: taskId, callback: callback })
      expect(socket.emit).toHaveBeenCalledWith 'addTask', { msgId: msgId, data: { taskId: taskId, runFun: runFun } }

    it "deletes a task from a client", ->
      socket = jasmine.createSpyObj "socket", ["emit"]
      taskId = 1
      callback = jasmine.createSpy "callback"

      msgId = @connectionManager.deleteTaskFromPeer socket, taskId, callback
      expect(msgId).toBeDefined()
      expect(@connectionManager.responseCallbacks[msgId]).toEqual({ taskId: taskId, callback: callback })
      expect(socket.emit).toHaveBeenCalledWith 'deleteTask', { msgId: msgId, data: { taskId: taskId } }

    it "executes job on a peer", ->
      socket = jasmine.createSpyObj "socket", ["emit"]
      taskId = 1
      jobId = 1
      jobArgs = { test: "test" }
      callback = jasmine.createSpy "callback"

      msgId = @connectionManager.executeJobOnPeer socket, taskId, jobId, jobArgs, callback
      expect(msgId).toBeDefined()
      expect(@connectionManager.responseCallbacks[msgId]).toEqual({ taskId: taskId, callback: callback })
      expect(socket.emit).toHaveBeenCalledWith 'executeJob', { msgId: msgId, data: { taskId: taskId, jobId: jobId, jobArgs: jobArgs } }

    it "sends acknowledgement to a client", ->
      socket = jasmine.createSpyObj "socket", ["emit"]
      msgId = 1

      @connectionManager.sendAckToPeer socket, msgId
      expect(socket.emit).toHaveBeenCalledWith "ack", { msgId: msgId }

    describe "when callback exists", ->
      it "executes onAck callback when acknowledgement comes from client", ->
        msgId = 1
        taskId = 1
        callback = jasmine.createSpyObj "callback", ["onAck", "onError"]
        responseCallback = {
          taskId: taskId
          callback: callback
        }
        socket = jasmine.createSpy "socket"
        @connectionManager.responseCallbacks[msgId] = responseCallback

        @connectionManager.onAck socket, { msgId: msgId }
        expect(callback.onAck).toHaveBeenCalledWith socket, taskId
        expect(callback.onError).not.toHaveBeenCalled()
        expect(@connectionManager.responseCallbacks[msgId]).toBeUndefined()

      it "executes onError callback when error comes from client", ->
        msgId = 1
        taskId = 1
        callback = jasmine.createSpyObj "callback", ["onAck", "onError"]
        responseCallback = {
          taskId: taskId
          callback: callback
        }
        socket = jasmine.createSpy "socket"
        @connectionManager.responseCallbacks[msgId] = responseCallback

        @connectionManager.onError socket, { msgId: msgId }
        expect(callback.onError).toHaveBeenCalledWith socket, taskId
        expect(callback.onAck).not.toHaveBeenCalled()
        expect(@connectionManager.responseCallbacks[msgId]).toBeUndefined()

    describe "when result comes from a client", ->
      it "sends acknowledgement to the client", ->
        sendAckToPeer = jasmine.createSpy "sendAckToPeer"
        @connectionManager.sendAckToPeer = sendAckToPeer
        msgId = 1
        data = "data"
        payload = {
          msgId: msgId
          data: data
        }
        socket = jasmine.createSpy "socket"

        @connectionManager.onResult socket, payload
        expect(@connectionManager.sendAckToPeer).toHaveBeenCalledWith socket, msgId

      it "emits 'resultReady' event with result data", ->
        sendAckToPeer = jasmine.createSpy "sendAckToPeer"
        @connectionManager.sendAckToPeer = sendAckToPeer
        emit = jasmine.createSpy "emit"
        @connectionManager.emit = emit
        msgId = 1
        data = "data"
        payload = {
          msgId: msgId
          data: data
        }
        socket = jasmine.createSpy "socket"

        @connectionManager.onResult socket, payload
        expect(@connectionManager.emit).toHaveBeenCalledWith "resultReady", socket, payload.data
        