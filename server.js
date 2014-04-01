var app = require('express')()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server);

server.listen(3000);

app.get('/clients', function (req, res) {
  res.sendfile(__dirname + '/index.html');
});

var clientServer = require("./client_server.js");
clientServer.initialize(io);