require 'socket'

host = 'localhost'
port = 8000
protocol = "HTTP/1.0\r\n\r\n"

puts "Enter string to send to server (echo.php)..."
input = gets
request = "GET /echo.php?message=" + input + protocol

socket = TCPSocket.open(host, port) # Open socket connection to port 8000 of localhost using TCP socket
socket.write(request) # Send request
print socket.read # Read response from server (echo.php)
socket.close # Close the socket
