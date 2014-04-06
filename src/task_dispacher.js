var events = require('events');

module.exports = Dispatcher;

function Dispatcher() {
    events.EventEmitter.call(this);
}

Dispatcher.prototype = Object.create(events.EventEmitter.prototype);

Dispatcher.prototype.dispatch_tasks = function(func, left, right, clients) {
    var self = this;
    var tasks = this.generate_tasks(func, left, right, clients.length);
    var result = [];
    console.log("generated " + tasks.length + " tasks, emiting...")
    // console.log(tasks);
    for (var i = 0; i < tasks.length; i++) {
        var client = clients[i % clients.length];
        client.emit('task', {
            code: tasks[i]
        });
        client.on('task_result', function(data) {
            result.push(data.result);
            console.log("Partial results arrived " + data.result)
        });
    }
    console.log("Now waiting for results...")

    // setInterval(function() {
    // 	if(result.length < tasks.length) {
    // 		console.log("Waiting 1 more second...");
    // 	} else {
    // 		console.log(this)
    // 		clearInterval(this);
    // 		self.emit('completed', result);
    // 	}
    // }, 1000);

    // how do we now all results arrived?
    setTimeout(function() {
        self.emit('completed', result);
    }, 5000);

    return this;
}

Dispatcher.prototype.generate_tasks = function(func, left, right, cnt) {
    var result = [];
    var k = Math.ceil((right - left + 1) / cnt); // 
    for (var i = left; i < right; i += k) {
        result.push(this.generate_func_string(func, (i), Math.min(i + k - 1, right)));
    }
    // console.log("Prepared tasks " + result)
    return result;
}

// add additional params there
Dispatcher.prototype.generate_func_string = function(func, a, b) {
    return "func = " + String(func) + "; func(" + a + ", " + b + ")"
}