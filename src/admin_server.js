var initializeAdminServer = function(io, adminEndpoint) {
  var ConnectionManager = require('./connection_manager');
  var connectionManager = new ConnectionManager(io.of(adminEndpoint));
  var JobDispatcher = require('./job_dispatcher');
  var JsInjector = require('./js_injector');
  var TaskManager = require('./task_manager');

  var taskManager = new TaskManager(new JobDispatcher(connectionManager), new JsInjector(connectionManager));

  connectionManager.onConnection(function(socket) {
    console.log('admin connected');
    socket.on('command', function(data) {
      var task = eval(data); // todo: error handling
      taskManager.manage(task);
      console.log('command executed: ' + data);
      socket.emit('result', 'Task completed! Result is: 3.14159265...');
    });
  });
};

module.exports = {
  'initialize': initializeAdminServer
};
