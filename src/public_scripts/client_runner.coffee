clientEndpoint = 'http://localhost/client'
socket = io.connect clientEndpoint

client = Client(socket)
