var initializeClientServer = function(io) {
	var tasks = require("./tasks.js");

	var Dispatcher = require("./task_dispacher.js");
	var ConnectionManager = require("./connection_manager.js");

	var dispatcher = new Dispatcher();
	var connectionManager = new ConnectionManager(io.of("/clients"));

	connectionManager.on_connection(function() {
		console.log("new user connected")

		if(connectionManager.connected_clients().length == 3) {
			console.log("starting task")
		 	dispatcher.dispatch_tasks(tasks.findPrimesInRange, 1, 100, connectionManager.connected_clients());
		 	dispatcher.on('completed', function(results) {
		 		console.log("Results arrivers: " + JSON.stringify(results) +"!")
	 		});
		 } else {
		 	console.log("Number of connected clients " + connectionManager.connected_clients().length)
		 }
	});
}

module.exports = {
	"initialize" : initializeClientServer
}
