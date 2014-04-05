describe("Dispacher", function() {
	var dispatcher;
	beforeEach(function() {
		dispatcher = require("../src/task_dispacher");
	});

	it("should be able to create code to run given function", function() {
		expect(dispatcher.prototype.generate_func_string("log","1","2")).toEqual("func = log; func(1, 2)");
	});
});
