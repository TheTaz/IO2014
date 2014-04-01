module.exports = ConnectionManager;

function ConnectionManager(sockets) {
	this.sockets = sockets;
}

ConnectionManager.prototype.on_connection = function(callback) {
	this.sockets.on('connection', function() {
		callback();
	});
}

ConnectionManager.prototype.connected_clients = function() {
	return this.sockets.clients();
}