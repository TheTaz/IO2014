webdriverjs = require("webdriverjs")

describe "Task ordering tests:", ->

  client = {}
  token = ""

  jasmine.DEFAULT_TIMEOUT_INTERVAL = 9999999

  checkTask=(task,expectedResult,done)->
    client
      .url('http://localhost:3000/admin')
      .setValue("#command",task, (err)->
        expect(err).toBeNull()
      )
      .buttonClick("#sendCommand",(err)->
        expect(err).toBeNull()
      )
      .getValue("#progressContainer textarea", (err, value)->
        expect(err).toBeNull()
        expect(value).toEqual(expectedResult)
      )
      .call(done)

  beforeEach ->
    client = webdriverjs.remote(
      desiredCapabilities:
        browserName: process.env.browser
    )
    client.init()

  it "admin panel is displayed with task input field.", (done) ->
    client
      .url('http://localhost:3000/admin')
      .getText('body', (err, result) ->
        expect(result.length).toBeGreaterThan(0)
      )
      .getTagName("#command", (err, result)->
        expect(result).toEqual("textarea")
      )
      .getTagName("#sendCommand", (err, result)->
        expect(result).toEqual("button")
      )
      .call(done)

  it "successfully orders a valid task", (done) ->
    fs = require("fs")
    task = fs.readFileSync("./example_task.js", "utf8")
    checkTask(task,"Converting circular structure to JSON",done)

  it "informs about invalid TaskParams object", (done) ->
    fs = require("fs")
    task = fs.readFileSync("./acceptance_test/invalidTaskParams.js", "utf8")
    checkTask(task,"Invalid taskParams object",done)

  it "informs about Invalid taskProcess function", (done) ->
    fs = require("fs")
    task = fs.readFileSync("./acceptance_test/invalidTaskProcess.js", "utf8")
    checkTask(task,"Invalid taskProcess function",done)

  it "informs about Invalid taskResultEquals function", (done) ->
    fs = require("fs")
    task = fs.readFileSync("./acceptance_test/invalidTaskResultEquals.js", "utf8")
    checkTask(task,"Invalid taskResultEquals function",done)

  it "informs about Invalid taskSplit function object", (done) ->
    fs = require("fs")
    task = fs.readFileSync("./acceptance_test/invalidTaskSplit.js", "utf8")
    checkTask(task,"Invalid taskSplit function",done)

  it "informs about Invalid taskMerge function", (done) ->
    fs = require("fs")
    task = fs.readFileSync("./acceptance_test/invalidTaskMerge.js", "utf8")
    checkTask(task,"Invalid taskMerge function",done)

  afterEach (done) ->
    client.end(done)
