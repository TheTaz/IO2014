describe "TaskDispatcher", ->
	TaskDispatcher = require "../src/task_dispatcher"
	taskDispatcher = new TaskDispatcher

	dumb_func = "function(a, b) { return a + b }"


	it "dispatches task", ->
		client = jasmine.createSpyObj 'client', ['on', 'emit']
		clients = [client]

		taskDispatcher.dispatchTask(dumb_func, 10, 20, clients)
		expect(client.on).toHaveBeenCalled();
		expect(client.emit).toHaveBeenCalled();


	it "generates function string", ->
		expect(taskDispatcher.generateFuncString(dumb_func, 10, 20)).toEqual "func = function(a, b) { return a + b }; func(10, 20)"

	it "generates tasks", ->
		tasks = taskDispatcher.generateTasks dumb_func, 10, 20, 3
		expect(tasks.length).toEqual 3
		expect(tasks[2]).toEqual "func = function(a, b) { return a + b }; func(18, 20)"
