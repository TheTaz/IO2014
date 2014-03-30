var app = require('express')()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server);

server.listen(3000);

app.get('/', function (req, res) {
  res.sendfile(__dirname + '/index.html');
});

var tasks = require("./tasks.js");

var Dispatcher = require("./task_dispacher.js");
var dispatcher = new Dispatcher();

io.sockets.on('connection', function (socket) {
	console.log("new user connected")

	if(io.sockets.clients().length == 3) {
		console.log("starting task")
	 	dispatcher.dispatch_tasks(tasks.find_primes_in_range, 1, 100, io.sockets.clients());
	 	dispatcher.on('completed', function(results, a) {
	 		console.log("Results arrivers: " + JSON.stringify(results) +"!")
 		});
	 }
});



