app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

Dispatcher = require './task_dispatcher'
ConnectionManager = require './connection_manager'

tasks = require './tasks'

clientsEndpoint = '/clients'
adminEndpoint = '/admin'

clientsIO = io.of clientsEndpoint
adminIO = io.of adminEndpoint

dispatcher = new Dispatcher()
connectionManager = new ConnectionManager(clientsIO)

initializeServer = () ->
  server.listen 3000

initializeClientsServer = () ->
  app.get(clientsEndpoint, (req, res) ->
    res.sendfile(__dirname + '/index.html')
  )

  ClientServer = require './client_server'
  new ClientServer(dispatcher, connectionManager)

initializeAdminConsole = () ->
  app.get('/bootstrap/css/bootstrap.css', (req, res) ->
    res.sendfile('bootstrap/css/bootstrap.css');
  )

  app.get('/bootstrap/css/bootstrap-theme.css', (req, res) ->
    res.sendfile('bootstrap/css/bootstrap-theme.css');
  )

  app.get(adminEndpoint, (req, res) ->
    res.sendfile(__dirname + '/admin_panel.html');
  )

  AdminConsole = require './admin_console'
  new AdminConsole(adminIO, dispatcher, connectionManager)

initialize = () ->
  initializeServer()
  initializeAdminConsole()
  clientServer = initializeClientsServer()

  clientsIO.on 'connection', () ->
    if(clientsIO.clients().length is 3)
      clientServer.dispatchTask tasks.findPrimesInRange, 1, 1000

initialize()