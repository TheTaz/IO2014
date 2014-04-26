express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

Dispatcher = require './task_dispatcher'
ConnectionManager = require './connection_manager'

#tasks = require './tasks'

clientsEndpoint = '/client'
adminEndpoint = '/admin'

clientsIO = io.of clientsEndpoint
adminIO = io.of adminEndpoint

dispatcher = new Dispatcher()
connectionManager = new ConnectionManager(clientsIO)

initializeServer = () ->
  app.use(express.static('./public'))
  server.listen 3000

initializeClientsServer = () ->
  ClientServer = require './client_server'
  new ClientServer(dispatcher, connectionManager)

initializeAdminConsole = () ->
  AdminConsole = require './admin_console'
  new AdminConsole(adminIO, dispatcher, connectionManager)

initialize = () ->
  initializeServer()
  initializeAdminConsole()
  clientServer = initializeClientsServer()

#  clientsIO.on 'connection', () ->
#    if(clientsIO.clients().length is 3)
#      clientServer.dispatchTask tasks.findPrimesInRange, 1, 1000

initialize()