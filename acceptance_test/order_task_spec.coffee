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

    
  afterEach (done) ->
    client.end(done)
