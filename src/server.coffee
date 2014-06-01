# Library imports
express = require 'express'
http = require 'http'
path = require 'path'
socketIo = require 'socket.io'

# Application imports
AdminConsole = require './admin_console'
adminRoute = require './routes/admin'
clientRoute = require './routes/client'
ConnectionManager = require './connection_manager'
JobDispatcher = require './job_dispatcher'

clientsEndpoint = '/client'
adminEndpoint = '/admin'

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'ejs'
app.use express.favicon()
app.use express.logger('dev')
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static('./public')

app.get clientsEndpoint, clientRoute
app.get adminEndpoint, adminRoute

server = http.createServer app
io = socketIo.listen server
server.listen app.get 'port'

clientsIO = io.of clientsEndpoint
adminIO = io.of adminEndpoint
connectionManager = new ConnectionManager clientsIO, true
dispatcher = new JobDispatcher connectionManager
adminConsole = new AdminConsole adminIO, dispatcher, connectionManager

connectionManager.onPeerConnected (socket) ->
  console.log("New user connected")
