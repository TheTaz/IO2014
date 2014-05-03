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

  	socket.on "ack", (data) ->
  		console.log("Client accepted msgId: " + data.msgId)

  	socket.on "jobResult", (data) ->
  		console.log("Received response: " + data.data.jobResult)
  	
  	socket.emit("operation", {opcode: 1, msgId: 1, data: { taskId: 1, runFun: "({taskProcess: function(inputObj) { return [inputObj.number, inputObj.begin, inputObj.end]}})" } })
  	#socket.emit("operation", {opcode: 2, msgId: 2, data: { taskId: 1 } })
  	socket.emit("operation", {opcode: 3, msgId: 2, data: { taskId: 1, jobId: 1, jobArgs: { number: 999999, begin: 2, end: 999999 } } })


initializeAdminConsole = () ->
  AdminConsole = require './admin_console'
  new AdminConsole(adminIO, dispatcher, connectionManager)

initialize = () ->
  initializeServer()
  initializeAdminConsole()
  initializeConnectionManager()

initialize()
