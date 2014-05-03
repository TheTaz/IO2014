var socket = io.connect('http://localhost/client');
var lastServerMsgId = 0;
var lastClientMsgId = 0;
var tasks = {};
//tasks = { 1: { task: ... , results: ... }, 2: { task: ... , results: ... }}
socket.on('task', function (controlMsg) {
	console.log("Received control message: " + controlMsg);
	if (lastServerMsgId + 1 != controlMsg.msgId) {
		console.log("Synchronization error, last message id was: " + lastServerMsgId +  " while current is: " + controlMsg.msgId);
	}
	lastServerMsgId = controlMsg.msgId;
	switch (controlMsg.opcode) {
		case 1:
			//Add new task code

			taskId = controlMsg.data.taskId;

			tasks[taskId] = {};
			tasks[taskId].task = controlMsg.data.runFun;

			socket.emit("response", { ack: true, msgId: controlMsg.msgId});

			break;
		case 2:
			//Delete task code

			taskId = controlMsg.data.taskId;

			delete tasks[taskId]

			socket.emit("response", { ack: true, msgId: controlMsg.msgId});

			break;
		case 3:
			//Execute job (task fragment)

			taskId = controlMsg.data.taskId;
			jobId = controlMsg.data.jobId;
			jobArgs = controlMsg.data.jobArgs;

			task = tasks[taskId];
			result = eval(task.task).taskProcess(jobArgs);
			task.results[jobId] = result;

			socket.emit("response", { ack: true, msgId: controlMsg.msgId});

			taskResult = { 
				"opcode": 4, 
				"msgId":  --lastClientMsgId, 
				"data": { 
					"taskId": taskId, 
					"jobId": jobId, 
					"jobResult": result
      	}
			};

			socket.emit("task_result", taskResult);

			break;
		default:
			console.log("Operation code: " + controlMsg.opcode + " is not handled");
	}
});