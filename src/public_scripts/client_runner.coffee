clientEndpoint = 'http://localhost/client'
socket = io.connect clientEndpoint

client = new Client(socket)
