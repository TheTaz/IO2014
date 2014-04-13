var app = require('express')(),
    server = require('http').createServer(app),
    io = require('socket.io').listen(server);

var Dispatcher = require('./task_dispatcher');
var ConnectionManager = require('./connection_manager');

var tasks = require('./tasks');

var clientsEndpoint = '/clients';
var clientsIO = io.of(clientsEndpoint);

var adminEndpoint = '/admin';

var dispatcher = new Dispatcher();
var connectionManager = new ConnectionManager(clientsIO);

var initializeServer = function() {
  server.listen(3000);
};

var initializeClientsServer = function() {
  app.get(clientsEndpoint, function(req, res) {
    res.sendfile(__dirname + '/index.html');
  });

  var ClientServer = require('./client_server');
  return new ClientServer(dispatcher, connectionManager);
};

var initializeAdminConsole = function() {
  app.get('/bootstrap/css/bootstrap.css', function(req, res) {
    res.sendfile('bootstrap/css/bootstrap.css');
  });

  app.get('/bootstrap/css/bootstrap-theme.css', function(req, res) {
    res.sendfile('bootstrap/css/bootstrap-theme.css');
  });

  app.get(adminEndpoint, function(req, res) {
    res.sendfile(__dirname + '/admin_panel.html');
  });

  var AdminConsole = require('./admin_console');
  return new AdminConsole(io.of(adminEndpoint), dispatcher, connectionManager);
};

var initialize = function() {
  initializeServer();
  initializeAdminConsole();
  var clientServer = initializeClientsServer();

  clientsIO.on('connection', function() {
    if (clientsIO.clients().length === 3) {
      clientServer.dispatchTask(tasks.findPrimesInRange, 1, 1000);
    }
  });
};

initialize();