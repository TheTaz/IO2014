express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

JobDispatcher = require './job_dispatcher'
ConnectionManager = require './connection_manager'
JsInjector = require './js_injector'

#tasks = require './tasks'

clientsEndpoint = '/client'
adminEndpoint = '/admin'

clientsIO = io.of clientsEndpoint
adminIO = io.of adminEndpoint

connectionManager = new ConnectionManager(clientsIO, true)
jsInjector = new JsInjector(connectionManager)
dispatcher = new JobDispatcher(connectionManager, jsInjector)

initializeServer = () ->
  app.use(express.static('./public'))
  server.listen 3000

initializeConnectionManager = () ->
  connectionManager.onPeerConnected (socket) ->
    console.log("New user connected")

initializeAdminConsole = () ->
  AdminConsole = require './admin_console'
  new AdminConsole(adminIO, dispatcher, connectionManager, jsInjector)

initialize = () ->
  initializeServer()
  initializeAdminConsole()
  initializeConnectionManager()

initialize()
