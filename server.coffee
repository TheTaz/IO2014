# Library imports
connectAssets       = require 'connect-assets'
express             = require 'express'
http                = require 'http'
path                = require 'path'
socketIo            = require 'socket.io'

# Application imports
AdminConsole        = require path.join(__dirname, 'src', 'admin_console')
ConnectionManager   = require path.join(__dirname, 'src', 'connection_manager')
JobDispatcher       = require path.join(__dirname, 'src', 'job_dispatcher')
JsInjector          = require path.join(__dirname, 'src', 'js_injector')

# Set up an application
app = express()
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'ejs'
app.use express.favicon()
app.use express.logger 'dev'
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static path.join(__dirname, 'assets')
app.use connectAssets()

# Prepare routing
clientsEndpoint = '/client'
adminEndpoint = '/admin'
app.get clientsEndpoint, (res, req) -> req.render 'client'
app.get adminEndpoint, (res, req) -> req.render 'admin'

# Start the server
server = http.createServer app
io = socketIo.listen server
server.listen app.get 'port'

# Other initializations
clientsIO = io.of clientsEndpoint
adminIO = io.of adminEndpoint
connectionManager = new ConnectionManager clientsIO, true
jsInjector = new JsInjector connectionManager
dispatcher = new JobDispatcher connectionManager, jsInjector
adminConsole = new AdminConsole adminIO, dispatcher, connectionManager, jsInjector

connectionManager.onPeerConnected (socket) ->
  console.log 'New user connected'
