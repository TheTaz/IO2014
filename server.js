var app = require('express')()
  , server = require('http').createServer(app)
  , io = require('socket.io').listen(server);

server.listen(3000);

app.get('/client', function (req, res) {
  	res.sendfile(__dirname + '/index.html');
});

app.get('/admin', function (req, res) {
	res.sendfile(__dirname + '/admin_panel.html');
});

var tasks = require("./tasks.js");

var Dispatcher = require("./task_dispacher.js");
var dispatcher = new Dispatcher();

io.of('/client').on('connection', function (socket) {
	console.log("client connected");
	if(io.of('/client').clients().length == 3) {
		console.log("starting task")
	 	dispatcher.dispatch_tasks(tasks.find_primes_in_range, 1, 100, io.of('/client').clients());
	 	dispatcher.on('completed', function(results, a) {
 			console.log("Results arrivers: " + JSON.stringify(results) +"!")
		});
 	}
});

io.of('/admin').on('connection', function (socket) {
	console.log("admin connected");
	io.of('/admin').clients()[io.of('/admin').clients().length - 1].on('command', function (data) {
		console.log('command executed: ' + data);
	});
});