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

initializeAdminConsole = () ->
  AdminConsole = require './admin_console'
  new AdminConsole(adminIO, dispatcher, connectionManager)

initialize = () ->
  initializeServer()
  initializeAdminConsole()
  initializeConnectionManager()

initialize()
