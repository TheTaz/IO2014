describe("ConnectionManager", function() {
	var sockets = jasmine.createSpyObj('sockets', ['on', 'clients']);

  
  it("returns list of connected clients", function() {
		var ConnectionManager = require("../src/connection_manager.js");
		var connectionManager = new ConnectionManager(sockets);

		connectionManager.connected_clients();
		expect(sockets.clients).toHaveBeenCalled();
  });

	it("executes function on connection", function() {
		var ConnectionManager = require("../src/connection_manager.js");
		var connectionManager = new ConnectionManager(sockets);

		var callback = jasmine.createSpy('callback')
		connectionManager.on_connection(callback);

		expect(sockets.on).toHaveBeenCalled();
	});
});
