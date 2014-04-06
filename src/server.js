var app = require('express')(),
    server = require('http').createServer(app),
    io = require('socket.io').listen(server);

var clientsEndpoint = "/clients";
var adminEndpoint = "/admin";

var initializeServer = function() {
	server.listen(3000);
}

var initializeClientsServer = function(){
	app.get(clientsEndpoint, function (req, res) {
        res.sendfile(__dirname + '/index.html');
    });

	var clientServer = require("./client_server.js");
	clientServer.initialize(io, clientsEndpoint);
}

var initializeAdminServer = function(){
    //Nie mam pojecia jak to zrobic bez tych get'ow - gdzie nie umieszcze tych resource'ow, to zawsze 404
    app.get('/bootstrap/css/bootstrap.css', function(req, res) {
       res.sendfile(__dirname + '/bootstrap/css/bootstrap.css');
    });

    app.get('/bootstrap/css/bootstrap-theme.css', function(req, res) {
        res.sendfile(__dirname + '/bootstrap/css/bootstrap-theme.css');
    });

	app.get(adminEndpoint, function (req, res) {
		res.sendfile(__dirname + '/admin_panel.html');
	});

	var adminServer = require("./admin_server.js");
	adminServer.initialize(io, adminEndpoint);
}

var initialize = function(){
	initializeServer();
	initializeAdminServer();
	initializeClientsServer();
}

initialize();