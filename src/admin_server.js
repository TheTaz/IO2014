var initializeAdminServer = function(io, adminEndpoint) {
    var ConnectionManager = require("./connection_manager.js");
    var connectionManager = new ConnectionManager(io.of(adminEndpoint));
    var TaskManager = require("./task_manager.js");
    var taskManager = new TaskManager();

    connectionManager.onConnection(function(socket) {
        console.log("admin connected");
        socket.on('command', function(data) {
            var task = eval(data); // todo: error handling
            taskManager.manage(task);
            console.log('command executed: ' + data);
            socket.emit('result', 'Task completed! Result is: 3.14159265...');
        });
    });
}

module.exports = {
    "initialize": initializeAdminServer
}