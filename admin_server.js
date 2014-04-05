var initializeAdminServer = function(io, adminEndpoint) {
	var ConnectionManager = require("./connection_manager.js");
	var connectionManager = new ConnectionManager(io.of(adminEndpoint));

	connectionManager.on_connection(function (socket) {
		console.log("admin connected");
		socket.on('command', function (data) {
			console.log('command executed: ' + data);
		});
	});
}

module.exports = {
	"initialize" : initializeAdminServer
}