###*
# This script runs in web browser, when client opens client.html
# @module admin
###

###*
# Admin class
# @class Admin
# @module admin
###
class Admin

  ###*
  # Initializes socket and html elements to inject in realtime.
  # Sets listener for 'send task' button click
  # @class Admin
  # @constructor
  ###
  constructor: () ->

    ###*
    # Socket handling the connection to the server
    # @property socket
    # @type Object
    ###
    @socket = io.connect('http://localhost/admin')

    ###*
    # First part of the outer div of progress bar
    # @property clientEndpoint
    # @type {String}
    ###
    @progressBarPrefix = '<div class="progress progress-striped active">'

    ###*
    # First part of the inner div of progress bar
    # @property clientEndpoint
    # @type {String}
    ###
    @progressBarInnerPrefix = '<div id="progressBar_'

    ###*
    # Second part of the inner div of progress bar
    # @property clientEndpoint
    # @type {String}
    ###
    @progressBarInnerPostfix = '" class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">0%</div>'
    
    ###*
    # Second part of the outer div of progress bar
    # @property clientEndpoint
    # @type {String}
    ###
    @progressBarPostfix = '</div>'

    ###*
    # First part of the result textarea
    # @property clientEndpoint
    # @type {String}
    ###
    @taskResultPrefix = '<textarea readonly style="width: 100%" id="result_'
    
    ###*
    # Second part of the result textarea
    # @property clientEndpoint
    # @type {String}
    ###
    @taskResultInfix = '">'
    
    ###*
    # Third part of the result textarea
    # @property clientEndpoint
    # @type {String}
    ###
    @taskResultPostfix = '</textarea>'

    $(document).ready(() =>
      $('#sendCommand').click(() =>
        console.log('sending command...')
        command = document.getElementById('command').value
        @socket.emit 'command', command
      )
    )

  ###*
  # Sets event listener for a given websocket event
  # @method addEventListener
  # @type {String}
  # @param event event name
  # @type {Object}
  # @param listener callback for an event, can take message payload as an argument
  ###
  addEventListener: (event, listener) =>
    @socket.on event, listener

  ###*
  # Removes event listener for a given websocket event
  # @method removeEventListener
  # @type {String}
  # @param event event name
  # @type {Object}
  # @param listener callback for an event to remove
  ###
  removeEventListener: (event, listener) =>
    @socket.removeListener event, listener 

  ###*
  # Increses given progress bar element to given value
  # @method increaseProgress
  # @type {Object}
  # @param element progress bar DOM element to modify
  # @type Integer
  # @param value defines percentage that progress bar should indicate
  ###
  increaseProgress: (element, value) =>
    element.style.width = value + '%'
    element['aria-valuenow'] = value
    element.innerHTML = value + '%'

  ###*
  # Handler called after the task has been started by the server.
  # Adds new progress bar to indicate task progress
  # @method onStarted
  # @type {Object}
  # @param payload message payload
  ###
  onStarted: (payload) =>
    taskId = payload.taskId
    progressBar = @progressBarPrefix + @progressBarInnerPrefix + taskId + @progressBarInnerPostfix + @progressBarPostfix
    $("#progressContainer").append(progressBar)

  ###*
  # Handler called when the task couldn't be added or started by the server
  # @method onError
  # @type {Object}
  # @param payload message payload
  ###
  onError: (payload) =>
    taskId = payload.taskId
    details = payload.details
    taskResult = @taskResultPrefix + taskId + @taskResultInfix + details + @taskResultPostfix
    $("#progressContainer").append(taskResult)

  ###*
  # Handler called when the task is malformed - cannot be evaluated to js object
  # @method onInvalid
  ###
  onInvalid: () =>
    alert("Provided task is malformed");

  ###*
  # Handler called when task has been completed and the result is available
  # @method onResult
  # @type {Object}
  # @param payload message payload
  ###
  onResult: (payload) =>
    taskId = payload.taskId
    result = payload.result
    taskResult = @taskResultPrefix + taskId + @taskResultInfix + result + @taskResultPostfix
    $("#progressBar_" + taskId).replaceWith(taskResult)

  ###*
  # Handler called when task progress needs to be updated
  # @method onResult
  # @type {Object}
  # @param payload message payload
  ###
  onProgress: (payload) =>
    taskId = payload.taskId
    progress = payload.progress
    @increaseProgress($("#progressBar_" + taskId)[0], progress)

admin = new Admin()

admin.addEventListener 'started', (payload) =>
  console.log('Event: started')
  admin.onStarted payload

admin.addEventListener 'error', (payload) =>
  console.log('Event: error')
  admin.onError payload

admin.addEventListener 'invalid', () =>
  console.log('Event: invalid')
  admin.onInvalid()

admin.addEventListener 'result', (payload) =>
  console.log('Event: result')
  admin.onResult payload

admin.addEventListener 'progress', (payload) =>
  console.log('Event: progress')
  admin.onProgress payload
