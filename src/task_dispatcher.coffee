events = require('events');

class Dispatcher extends events.EventEmitter
	constructor: ->
    	events.EventEmitter.call(this)

	dispatchTask: (func, left, right, clients) ->
	    self = this
	    tasks = this.generateTasks func, left, right, clients.length
	    result = []
	    arrived_results_count = 0

	    for i in [0..tasks.length-1]
	       	client = clients[i % clients.length]
	        client.emit 'task', {
	            code: tasks[i]
	        }

	        client.on 'task_result', (data) -> 
	            result.push data.result
	            console.log "Partial results arrived " + data.result
	            arrived_results_count++

	            if(arrived_results_count == tasks.length)
	            	self.emit('completed', result)

	generateTasks: (func, left, right, cnt) ->
	    result = []
	    k = Math.ceil((right - left + 1) / cnt)
	    for i in [left..right] by k
	        result.push this.generateFuncString(func, (i), Math.min(i + k - 1, right))

	    result

	generateFuncString: (func, a, b) ->
    	"func = " + String(func) + "; func(" + a + ", " + b + ")"

module.exports = Dispatcher