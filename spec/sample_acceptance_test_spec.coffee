webdriverjs = require("webdriverjs")

describe "my webdriverjs tests", ->

    client = {}
    token = ""

    jasmine.DEFAULT_TIMEOUT_INTERVAL = 9999999

    beforeEach ->
        client = webdriverjs.remote({
            desiredCapabilities: {
                browserName: 'phantomjs'
            }
        })
        client.init()

    it "receives token at registration", (done) ->
        client
            .url('http://localhost:8080/api/register')
            .getText('body', (err, result) ->
                token = result
                expect(token.length).toBeGreaterThan(0)
            )
            .call(done)
			
    afterEach (done) ->
        client.end(done)