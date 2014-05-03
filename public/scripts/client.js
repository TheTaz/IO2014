console.log("Client script loaded, connecting to server...");

var socket = io.connect('http://localhost/client');
var lastServerMsgId = 0;
var lastClientMsgId = 0;
var tasks = {};
//tasks = { 1: { task: "{ ... }" , results: { 1: ..., 2: ... } }, 2: { ... } }
socket.on('operation', function (operation) {
	console.log("Received control message with operation code: " + operation.opcode);

	//TODO: Is this check needed?
	if (lastServerMsgId + 1 != operation.msgId) {
		console.log("Synchronization error, last message id was: " + lastServerMsgId +  " while current is: " + operation.msgId);
		for (var i = lastServerMsgId + 1; i < operation.msgId; i++) {
			socket.emit("error", { error: 4, msgId: i, details: { reason: "Did not receive operation" } });
		};
	}

	lastServerMsgId = operation.msgId;

	switch (operation.opcode) {
		case 1:
			//Add new task code,

			console.log(operation.data.runFun);
			console.log(typeof operation.data.runFun);

			if(operation.data.runFun instanceof String || typeof operation.data.runFun === "string"){
				taskId = operation.data.taskId;
				tasks[taskId] = {};
				tasks[taskId].task = operation.data.runFun;
				tasks[taskId].results = {};
				console.log("Added new task: " + tasks[taskId].task);
				socket.emit("ack", { ack: true, msgId: operation.msgId});
			} else {
				console.log("No task function provided");
				socket.emit("error", { error: 1, msgId: operation.msgId, details: { taskId: operation.data.taskId } });
			}

			break;
		case 2:
			//Delete task code

			taskId = operation.data.taskId;

			//TODO: Fire-and-forget call, or notify server that taskId was already removed?
			delete tasks[taskId]
			console.log("Deleted task: " + taskId);
			socket.emit("ack", { ack: true, msgId: operation.msgId});

			break;
		case 3:
			//Execute job (task fragment)

			taskId = operation.data.taskId;
			jobId = operation.data.jobId;
			jobArgs = operation.data.jobArgs;

			task = tasks[taskId];

			if(task === undefined){
				console.log("Cannot execute task, it doesn't exist")
				socket.emit("error", { error: 1, msgId: operation.msgId, details: { taskId: operation.data.taskId } });
				break;
			}

			console.log("Executing task: " + taskId);
			console.log("Task code: " + task.task);
			console.log("Job arguments: " + jobArgs);
			result = eval(task.task).taskProcess(jobArgs);
			task.results[jobId] = result;
			console.log("Result is: " + result);

			socket.emit("ack", { ack: true, msgId: operation.msgId});

			taskResult = { 
				opcode: 4, 
				msgId:  --lastClientMsgId, 
				data: { 
					taskId: taskId, 
					jobId: jobId, 
					jobResult: result
      	}
			};

			socket.emit("jobResult", taskResult);

			break;
		default:
			console.log("Unknown operation code: " + operation.opcode);
			socket.emit("error", { error: 4, msgId: i, details: { reason: "Unknown opcode" } });
	}
});
