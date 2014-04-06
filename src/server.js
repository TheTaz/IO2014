var app = require('express')(),
    server = require('http').createServer(app),
    io = require('socket.io').listen(server);

var Dispatcher = require("./task_dispatcher");
var ConnectionManager = require("./connection_manager");

var tasks = require("./tasks")

var clientsEndpoint = "/clients";
var clientsIO = io.of(clientsEndpoint);

var adminEndpoint = "/admin";

var initializeServer = function() {
    server.listen(3000);
}

var initializeClientsServer = function() {
    app.get(clientsEndpoint, function(req, res) {
        res.sendfile(__dirname + '/index.html');
    });

    var ClientServer = require("./client_server.js");
    var dispatcher = new Dispatcher();
    var connectionManager = new ConnectionManager(clientsIO);

    return new ClientServer(dispatcher, connectionManager);
}

var initializeAdminServer = function() {
    //Nie mam pojecia jak to zrobic bez tych get'ow - gdzie nie umieszcze tych resource'ow, to zawsze 404
    app.get('/bootstrap/css/bootstrap.css', function(req, res) {
        res.sendfile(__dirname + '/bootstrap/css/bootstrap.css');
    });

    app.get('/bootstrap/css/bootstrap-theme.css', function(req, res) {
        res.sendfile(__dirname + '/bootstrap/css/bootstrap-theme.css');
    });

    app.get(adminEndpoint, function(req, res) {
        res.sendfile(__dirname + '/admin_panel.html');
    });

    var adminServer = require("./admin_server.js");
    adminServer.initialize(io, adminEndpoint);
}

var initialize = function() {
    initializeServer();
    initializeAdminServer();
    var clientServer = initializeClientsServer();

    clientsIO.on('connection', function(socket) {
        if (clientsIO.clients().length == 3) {
            clientServer.dispatchTask(tasks.findPrimesInRange, 1, 1000);
        }
    });
}

initialize();