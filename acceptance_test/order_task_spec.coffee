webdriverjs = require("webdriverjs")

describe "Task ordering tests:", ->

  client = {}
  token = ""
    
  jasmine.DEFAULT_TIMEOUT_INTERVAL = 9999999

  beforeEach ->
    client = webdriverjs.remote(
      desiredCapabilities:
        browserName: process.env.browser
    )
    client.init()
  
  it "admin panel is displayed with task input field.", (done) ->
    client
      .url('http://localhost:3000/admin.html')
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
    client
      .url('http://localhost:3000/admin.html')
      .setValue("#command",task, (err)-> 
        expect(err).toBeNull()
      )
      .buttonClick("#sendCommand",(err)->
        expect(err).toBeNull()
      )
      .getValue("#progressContainer textarea", (err, value)->
        expect(err).toBeNull()
        expect(value).toEqual("Converting circular structure to JSON")
      )
      .call(done)

  afterEach (done) ->
    client.end(done)
