describe("ConnectionManager", function() {
    var sockets = jasmine.createSpyObj('sockets', ['on', 'clients']);
    var ConnectionManager = require("../src/connection_manager.js");
    var connectionManager = new ConnectionManager(sockets);

    it("returns list of connected clients", function() {
        connectionManager.connected_clients();
        expect(sockets.clients).toHaveBeenCalled();
    });

    it("executes function on connection", function() {
        var callback = jasmine.createSpy('callback')
        connectionManager.on_connection(callback);

        expect(sockets.on).toHaveBeenCalled();
    });
});