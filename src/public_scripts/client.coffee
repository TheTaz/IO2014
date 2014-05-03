###*
# This script runs in web browser, when client opens client.html
# @module client
###

console.log 'Client script loaded, connecting to server...'

###*
# Client class
# @class Client
# @module client
###
class Client
	constructor: () ->

		###*
		#	Address for client to connect to server websocket
		# @property clientEndpoint
		# @type String
		###
		@clientEndpoint = 'http://localhost/client'

		###*
		# Socket handling the connection to the server
		# @property socket
		# @type Object
		###
		@socket = io.connect @clientEndpoint

		###*
		# Value defining id of the last operation sent by the server
		# @property lastServerMsgId
		# @type Integer
		###
		@lastServerMsgId = 0

		###*
		# Value defining id of the last operation sent by the client
		# @property lastClientMsgId
		# @type Integer
		###
		@lastClientMsgId = 0

		###*
		#	Local object containing saved tasks and their results (if any exist)
		# Object has the following format:
		# {
		#		1: { 
		#			task: '({ ... })', 
		#			results: { 
		#				1: [ ... ], 
		#				2: [ ... ] 
		#			} 
		#		}, 
		#		2: { 
		#			... 
		#		} 
		#	}
		# @property tasks
		# @type Object
		###
		@tasks = {}

		###*
		#	Event listener that listenes for a new operation from the server
		# @event operation
		# @param operation details of the operation sent from the server
		###
		@socket.on 'operation', (operation) =>
			console.log 'Received control message with operation code: ' + operation.opcode

			#TODO: Is this check needed?
			if @lastServerMsgId + 1 isnt operation.msgId
				console.log 'Synchronization error, last message id was: ' + @lastServerMsgId +  ' while current is: ' + operation.msgId
				@socket.emit('error', { error: 4, msgId: i, details: { reason: 'Did not receive operation' } }) for i in [(@lastServerMsgId + 1)..(operation.msgId)]

			@lastServerMsgId = operation.msgId

			switch operation.opcode
				when 1
					#Add new task code,

					console.log operation.data.runFun
					console.log typeof operation.data.runFun

					if operation.data.runFun instanceof String or typeof operation.data.runFun is 'string'
						taskId = operation.data.taskId
						@tasks[taskId] = {}
						@tasks[taskId].task = operation.data.runFun
						@tasks[taskId].results = {}
						console.log 'Added new task: ' + @tasks[taskId].task
						@socket.emit('ack', { ack: true, msgId: operation.msgId})
					else 
						console.log 'No task function provided'
						@socket.emit('error', { error: 1, msgId: operation.msgId, details: { taskId: operation.data.taskId } });

				when 2
					#Delete task code

					taskId = operation.data.taskId

					#TODO: Fire-and-forget call, or notify server that taskId was already removed?
					delete @tasks[taskId]
					console.log 'Deleted task: ' + taskId
					@socket.emit('ack', { ack: true, msgId: operation.msgId})

				when 3
					#Execute job (task fragment)

					taskId = operation.data.taskId
					jobId = operation.data.jobId
					jobArgs = operation.data.jobArgs

					task = @tasks[taskId]

					if not task?
						console.log 'Cannot execute task, it doesn\'t exist'
						@socket.emit('error', { error: 1, msgId: operation.msgId, details: { taskId: operation.data.taskId } })
						break

					console.log 'Executing task: ' + taskId
					console.log 'Task code: ' + task.task
					console.log 'Job arguments: ' + jobArgs
					result = eval(task.task).taskProcess jobArgs
					task.results[jobId] = result
					console.log 'Result is: ' + result

					@socket.emit('ack', { ack: true, msgId: operation.msgId})

					taskResult = { 
						opcode: 4, 
						msgId:  --@lastClientMsgId, 
						data: { 
							taskId: taskId, 
							jobId: jobId, 
							jobResult: result
		      	}
					}

					@socket.emit('jobResult', taskResult)

				else
					console.log 'Unknown operation code: ' + operation.opcode
					@socket.emit('error', { error: 4, msgId: i, details: { reason: 'Unknown opcode' } })

new Client()