express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

ConnectionManager = require './connection_manager'

#tasks = require './tasks'

clientsEndpoint = '/client'
adminEndpoint = '/admin'

clientsIO = io.of clientsEndpoint
adminIO = io.of adminEndpoint

dispatcher = null
connectionManager = new ConnectionManager(clientsIO)

initializeServer = () ->
  app.use(express.static('./public'))
  server.listen 3000

initializeConnectionManager = () ->
  connectionManager.onPeerConnected (socket) ->
    console.log("New user connected")

    msgId = 0;

    socket.on 'ack', (payload) ->
      console.log('Got acknowledgment of msg ' + payload.msgId)
      if(payload.msgId is msgId)
        connectionManager.executeJobOnPeer(socket, 1, 1, { number: 999999, begin: 2, end: 999999 })
      
    socket.on 'result', (payload) ->
      console.log('Got result: ' + payload.data.jobResult)
      connectionManager.deleteTaskFromPeer(socket, 1)

    msgId = connectionManager.sendNewTaskToPeer(socket, 1, "({taskProcess: function(inputObj) { return [inputObj.number, inputObj.begin, inputObj.end]}})")   
    

initializeAdminConsole = () ->
  AdminConsole = require './admin_console'
  new AdminConsole(adminIO, dispatcher, connectionManager)

initialize = () ->
  initializeServer()
  initializeAdminConsole()
  initializeConnectionManager()

initialize()
